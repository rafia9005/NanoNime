package anime

import (
	"io"
	"net/http"
	"net/url"
	"strings"
	"time"

	"nanonime/internal/pkg/config"
	"nanonime/internal/pkg/logger"

	"github.com/labstack/echo/v4"
)

type Controller struct {
	baseURL string
	timeout time.Duration
	client  *http.Client
	logger  *logger.Logger
}

func NewController() *Controller {
	baseURL := config.GetString("anime_api.base_url")
	if baseURL == "" {
		panic("anime base url not found")
	}

	timeout := config.GetInt("anime_api.timeout")
	if timeout == 0 {
		timeout = 30
	}

	client := &http.Client{
		Timeout: time.Duration(timeout) * time.Second,
		CheckRedirect: func(req *http.Request, via []*http.Request) error {
			return http.ErrUseLastResponse
		},
	}

	log, _ := logger.NewLogger(logger.DefaultConfig(), "anime")

	return &Controller{
		baseURL: baseURL,
		timeout: time.Duration(timeout) * time.Second,
		client:  client,
		logger:  log,
	}
}

// ProxyHandler handles reverse proxy to otakudesu API
func (c *Controller) ProxyHandler(ctx echo.Context) error {
	// Get the path after /api/v1/anime
	// Example: /api/v1/anime/home -> /otakudesu/home
	requestPath := ctx.Request().URL.Path

	// Remove /api/v1/anime prefix
	targetPath := strings.TrimPrefix(requestPath, "/api/v1/anime")

	// If empty, default to root
	if targetPath == "" || targetPath == "/" {
		targetPath = "/otakudesu"
	} else {
		targetPath = "/otakudesu" + targetPath
	}

	// Build target URL
	targetURL, err := url.Parse(c.baseURL + targetPath)
	if err != nil {
		c.logger.Error("Failed to parse target URL", "error", err, "path", targetPath)
		return ctx.JSON(http.StatusInternalServerError, map[string]interface{}{
			"error":   "Invalid target URL",
			"message": err.Error(),
		})
	}

	// Copy query parameters
	targetURL.RawQuery = ctx.Request().URL.RawQuery

	// Create new request
	proxyReq, err := http.NewRequest(ctx.Request().Method, targetURL.String(), ctx.Request().Body)
	if err != nil {
		c.logger.Error("Failed to create proxy request", "error", err)
		return ctx.JSON(http.StatusInternalServerError, map[string]interface{}{
			"error":   "Failed to create proxy request",
			"message": err.Error(),
		})
	}

	// Copy headers
	for key, values := range ctx.Request().Header {
		for _, value := range values {
			proxyReq.Header.Add(key, value)
		}
	}

	// Set/Override specific headers
	proxyReq.Header.Set("X-Forwarded-For", ctx.RealIP())
	proxyReq.Header.Set("X-Forwarded-Proto", ctx.Scheme())
	proxyReq.Header.Set("X-Forwarded-Host", ctx.Request().Host)

	// Log request
	c.logger.Info("Proxying request",
		"method", ctx.Request().Method,
		"from", requestPath,
		"to", targetURL.String(),
		"ip", ctx.RealIP(),
	)

	// Execute request
	resp, err := c.client.Do(proxyReq)
	if err != nil {
		c.logger.Error("Proxy request failed", "error", err, "url", targetURL.String())
		return ctx.JSON(http.StatusBadGateway, map[string]interface{}{
			"error":   "Failed to reach anime API",
			"message": err.Error(),
		})
	}
	defer resp.Body.Close()

	// Copy response headers
	for key, values := range resp.Header {
		for _, value := range values {
			ctx.Response().Header().Add(key, value)
		}
	}

	// Set status code
	ctx.Response().WriteHeader(resp.StatusCode)

	// Copy response body
	_, err = io.Copy(ctx.Response().Writer, resp.Body)
	if err != nil {
		c.logger.Error("Failed to copy response body", "error", err)
		return err
	}

	c.logger.Info("Proxy response",
		"status", resp.StatusCode,
		"url", targetURL.String(),
	)

	return nil
}

// HealthCheck checks if the anime API is reachable
func (c *Controller) HealthCheck(ctx echo.Context) error {
	targetURL := c.baseURL + "/health"

	req, err := http.NewRequest("GET", targetURL, nil)
	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, map[string]interface{}{
			"status":  "error",
			"message": "Failed to create health check request",
		})
	}

	resp, err := c.client.Do(req)
	if err != nil {
		return ctx.JSON(http.StatusServiceUnavailable, map[string]interface{}{
			"status":  "down",
			"api_url": c.baseURL,
			"message": "Anime API is not reachable",
			"error":   err.Error(),
		})
	}
	defer resp.Body.Close()

	return ctx.JSON(http.StatusOK, map[string]interface{}{
		"status":  "up",
		"api_url": c.baseURL,
		"code":    resp.StatusCode,
	})
}

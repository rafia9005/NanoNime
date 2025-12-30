package manga

import (
	"encoding/json"
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
	baseURL := config.GetString("manga_api.base_url")
	if baseURL == "" {
		panic("manga base url not found")
	}

	timeout := config.GetInt("manga_api.timeout")
	if timeout == 0 {
		timeout = 30
	}

	client := &http.Client{
		Timeout: time.Duration(timeout) * time.Second,
		CheckRedirect: func(req *http.Request, via []*http.Request) error {
			return http.ErrUseLastResponse
		},
	}

	log, _ := logger.NewLogger(logger.DefaultConfig(), "manga")

	return &Controller{
		baseURL: baseURL,
		timeout: time.Duration(timeout) * time.Second,
		client:  client,
		logger:  log,
	}
}

// ProxyHandler handles reverse proxy to manga API
func (c *Controller) ProxyHandler(ctx echo.Context) error {
	// Get the path after /api/v1/manga
	requestPath := ctx.Request().URL.Path

	// Remove /api/v1/manga prefix
	targetPath := strings.TrimPrefix(requestPath, "/api/v1/manga")
	if targetPath == "" {
		targetPath = "/"
	}
	if !strings.HasPrefix(targetPath, "/") {
		targetPath = "/" + targetPath
	}
	proxyPath := "/api/manga" + targetPath

	// Build target URL
	targetURL, err := url.Parse(c.baseURL + proxyPath)
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

	// Copy headers (ONLY Authorization and Content-Type to be safe)
	if auth := ctx.Request().Header.Get("Authorization"); auth != "" {
		proxyReq.Header.Set("Authorization", auth)
	}
	if ct := ctx.Request().Header.Get("Content-Type"); ct != "" {
		proxyReq.Header.Set("Content-Type", ct)
	}

	// Log request
	c.logger.Info("Proxying request",
		"method", ctx.Request().Method,
		"from", requestPath,
		"to", targetURL.String(),
	)

	// Execute request
	resp, err := c.client.Do(proxyReq)
	if err != nil {
		c.logger.Error("Proxy request failed", "error", err, "url", targetURL.String())
		return ctx.JSON(http.StatusBadGateway, map[string]interface{}{
			"error":   "Failed to reach manga API",
			"message": err.Error(),
		})
	}
	defer resp.Body.Close()

	// THIS IS THE FIX:
	// We do NOT copy headers from the upstream response.
	// We decode the body (assuming JSON) and send it back cleanly.
	// The middleware in app.go will attach the correct CORS headers.

	var result interface{}
	// Check if content type is JSON
	contentType := resp.Header.Get("Content-Type")
	if strings.Contains(contentType, "application/json") {
		if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
			c.logger.Error("Failed to decode upstream JSON", "error", err)
			return ctx.JSON(http.StatusBadGateway, map[string]interface{}{
				"error": "Invalid JSON from upstream",
			})
		}
		return ctx.JSON(resp.StatusCode, result)
	}

	// Fallback for non-JSON (like images or raw text), use Stream but be careful with headers
	// For now, let's assume API always returns JSON. If not, we might need a specific handler.
	// But to be safe, if not JSON, we copy simple body WITHOUT headers.
	return ctx.Stream(resp.StatusCode, contentType, resp.Body)
}

// HealthCheck checks if the manga API is reachable
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
			"message": "Manga API is not reachable",
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

// ImageProxyHandler proxies valid image requests to bypass CORS and Referer checks
func (c *Controller) ImageProxyHandler(ctx echo.Context) error {
	imageURL := ctx.QueryParam("url")
	if imageURL == "" {
		return ctx.JSON(http.StatusBadRequest, map[string]string{"error": "Missing url parameter"})
	}

	// Validate URL
	parsedURL, err := url.Parse(imageURL)
	if err != nil || (parsedURL.Scheme != "http" && parsedURL.Scheme != "https") {
		return ctx.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid URL"})
	}

	req, err := http.NewRequest("GET", imageURL, nil)
	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, map[string]string{"error": "Failed to create request"})
	}

	// Set headers to look like a browser
	req.Header.Set("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
	req.Header.Set("Accept", "image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8")
	
	// Execute Request
	resp, err := c.client.Do(req)
	if err != nil {
		c.logger.Error("Failed to fetch image", "url", imageURL, "error", err)
		return ctx.JSON(http.StatusBadGateway, map[string]string{"error": "Failed to fetch image"})
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		// Log but try to return what we got if it's an image? No, safer to error.
		return ctx.JSON(http.StatusBadGateway, map[string]interface{}{
			"error": "Upstream returned non-200 status", 
			"code": resp.StatusCode,
		})
	}

	// Stream response back
	contentType := resp.Header.Get("Content-Type")
	if contentType == "" {
		contentType = "application/octet-stream"
	}
	
	// Set caching for better performance
	ctx.Response().Header().Set("Cache-Control", "public, max-age=86400")

	return ctx.Stream(http.StatusOK, contentType, resp.Body)
}

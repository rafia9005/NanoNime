package handler

import (
	"fmt"
	"nanonime/internal/pkg/bus"
	"nanonime/internal/pkg/jwt"
	"nanonime/internal/pkg/logger"
	"nanonime/internal/pkg/utils"
	"nanonime/modules/auth/domain/service"
	"nanonime/modules/users/domain/entity"
	"nanonime/modules/users/dto/request"
	"nanonime/modules/users/dto/response"
	"net/http"

	"github.com/labstack/echo"
)

// AuthHandler struct handles HTTP request for auth.
type AuthHandler struct {
	authService *service.AuthService
	log         *logger.Logger
	event       *bus.EventBus
	jwt         jwt.JWT
	r           *utils.Response
}

// NewAuthHandler creates a new auth handler.
func NewAuthHandler(log *logger.Logger, event *bus.EventBus, authService *service.AuthService, jwt jwt.JWT) *AuthHandler {
	return &AuthHandler{
		authService: authService,
		log:         log,
		event:       event,
		jwt:         jwt,
		r:           &utils.Response{},
	}
}

// Initialize Event Handle.
func (h *AuthHandler) Handle(event bus.Event) {
	fmt.Printf("User created: %v", event.Payload)
}

// Register handles user registration.
func (h *AuthHandler) Register(c echo.Context) error {
	h.log.Info("Handling register request")

	req := new(request.RegisterRequest)
	if err := c.Bind(req); err != nil {
		h.log.Error("Failed to bind request:", err)
		return h.r.ErrorResponse(c, http.StatusBadRequest, err.Error())
	}

	if err := c.Validate(req); err != nil {
		h.log.Error("Validation failed:", err)
		return h.r.ErrorResponse(c, http.StatusBadRequest, err.Error())
	}

	h.log.Debug("Request validated successfully:", req)

	user := entity.NewUser(req.Name, req.Username, req.Email, req.Password)
	err := h.authService.CreateUser(c.Request().Context(), user)
	if err != nil {
		if err == service.ErrEmailAlreadyUsed {
			h.log.Warn("Email already in use:", req.Email)
			return h.r.ErrorResponse(c, http.StatusConflict, "Email already in use")
		}
		h.log.Error("Failed to create user:", err)
		return h.r.ErrorResponse(c, http.StatusInternalServerError, err.Error())
	}

	h.log.Debug("User created successfully:", user)

	h.event.Publish(bus.Event{Type: "user.created", Payload: user})
	h.log.Debug("Event 'user.created' published successfully")

	return h.r.SuccessResponse(c, map[string]interface{}{
		"user": response.FromEntity(user),
	}, "User registered successfully")
}

// Login handles user login.
func (h *AuthHandler) Login(c echo.Context) error {
	h.log.Info("Handling login request")

	req := new(request.LoginRequest)
	if err := c.Bind(req); err != nil {
		h.log.Error("Failed to bind request:", err)
		return h.r.ErrorResponse(c, http.StatusBadRequest, err.Error())
	}

	if err := c.Validate(req); err != nil {
		h.log.Error("Validation failed:", err)
		return h.r.ErrorResponse(c, http.StatusBadRequest, err.Error())
	}

	h.log.Debug("Request validated successfully:", req)

	user, err := h.authService.ProcessLogin(c.Request().Context(), req.Identity, req.Password)
	if err != nil {
		if err == service.ErrUserNotFound || err == service.ErrInvalidPassword {
			h.log.Warn("Invalid identity or password for:", req.Identity)
			return h.r.ErrorResponse(c, http.StatusUnauthorized, "Invalid identity or password")
		}
		h.log.Error("Failed to process login:", err)
		return h.r.ErrorResponse(c, http.StatusInternalServerError, err.Error())
	}

	h.log.Debug("User authenticated successfully:", user)

	tokenData := map[string]interface{}{
		"user_id":  user.ID,
		"name":     user.Name,
		"username": user.Username,
		"email":    user.Email,
	}

	token, err := h.jwt.GenerateToken(tokenData)
	if err != nil {
		h.log.Error("Failed to generate token:", err)
		return h.r.ErrorResponse(c, http.StatusInternalServerError, err.Error())
	}

	return h.r.SuccessResponse(c, map[string]interface{}{
		"token": token,
		"user":  response.FromEntity(user),
	}, "Login successful")
}

// RegisterRoutes sets up the auth routes.
func (h *AuthHandler) RegisterRoutes(e *echo.Echo, basePath string) {
	group := e.Group(basePath + "/auth")
	group.POST("/register", h.Register)
	group.POST("/login", h.Login)
}

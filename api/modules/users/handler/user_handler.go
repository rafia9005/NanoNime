// internal/modules/user/interfaces/handler/user_handler.go

package handler

import (
	"fmt"
	"nanonime/internal/pkg/bus"
	"nanonime/internal/pkg/logger"
	"nanonime/internal/pkg/middleware"
	"nanonime/internal/pkg/utils"
	"nanonime/modules/users/domain/entity"
	"nanonime/modules/users/domain/service"
	"nanonime/modules/users/dto/request"
	"nanonime/modules/users/dto/response"
	"net/http"
	"strconv"

	"github.com/dgrijalva/jwt-go"
	"github.com/labstack/echo"
)

// UserHandler handles HTTP requests for users
type UserHandler struct {
	userService *service.UserService
	log         *logger.Logger
	event       *bus.EventBus
	resp        *utils.Response
}

// NewUserHandler creates a new user handler
func NewUserHandler(log *logger.Logger, event *bus.EventBus, userService *service.UserService) *UserHandler {
	return &UserHandler{
		userService: userService,
		log:         log,
		event:       event,
		resp:        &utils.Response{},
	}
}

// Event Bus Event user created
func (h *UserHandler) Handle(event bus.Event) {
	fmt.Printf("User created: %v", event.Payload)
}

// GetAllUsers godoc
// @Summary Get list of users
// @Tags Users
// @Produce json
// @Success 200 {array} response.UserResponse
// @Failure 500 {object} map[string]string
// @Router /users [get]
func (h *UserHandler) GetAllUsers(c echo.Context) error {
	ctx := c.Request().Context()

	users, err := h.userService.GetAllUsers(ctx)
	if err != nil {
		return h.resp.InternalServerErrorResponse(c, err.Error())
	}

	return h.resp.SuccessResponse(c, response.FromEntities(users), "")
}

// GetUser godoc
// @Summary Get a user by ID
// @Tags Users
// @Produce json
// @Param id path int true "User ID"
// @Success 200 {object} response.UserResponse
// @Failure 400 {object} map[string]string
// @Failure 404 {object} map[string]string
// @Failure 500 {object} map[string]string
// @Router /users/{id} [get]
func (h *UserHandler) GetUser(c echo.Context) error {
	ctx := c.Request().Context()

	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid user ID"})
	}

	user, err := h.userService.GetUserByID(ctx, uint(id))
	if err != nil {
		if err == service.ErrUserNotFound {
			return c.JSON(http.StatusNotFound, map[string]string{"error": "User not found"})
		}
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
	}

	return c.JSON(http.StatusOK, response.FromEntity(user))
}

// CreateUser godoc
// @Summary Create a new user
// @Tags Users
// @Accept json
// @Produce json
// @Param payload body request.CreateUserRequest true "Create user payload"
// @Success 201 {object} response.UserResponse
// @Failure 400 {object} map[string]string
// @Failure 409 {object} map[string]string
// @Failure 500 {object} map[string]string
// @Router /users [post]
func (h *UserHandler) CreateUser(c echo.Context) error {
	ctx := c.Request().Context()

	req := new(request.CreateUserRequest)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": err.Error()})
	}

	if err := c.Validate(req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": err.Error()})
	}

	user := entity.NewUser(req.Name, req.Username, req.Email, req.Password)
	// set role if provided (validation ensures it's either 'admin' or 'user')
	if req.Role != "" {
		user.Role = req.Role
	}
	err := h.userService.CreateUser(ctx, user)
	if err != nil {
		if err == service.ErrEmailAlreadyUsed {
			return c.JSON(http.StatusConflict, map[string]string{"error": "Email already in use"})
		}
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
	}

	// event bus publish
	h.event.Publish(bus.Event{Type: "user.created", Payload: user})
	return c.JSON(http.StatusCreated, response.FromEntity(user))
}

// UpdateUser godoc
// @Summary Update an existing user
// @Tags Users
// @Accept json
// @Produce json
// @Param id path int true "User ID"
// @Param payload body request.UpdateUserRequest true "Update payload"
// @Success 200 {object} response.UserResponse
// @Failure 400 {object} map[string]string
// @Failure 404 {object} map[string]string
// @Failure 500 {object} map[string]string
// @Router /users/{id} [put]
func (h *UserHandler) UpdateUser(c echo.Context) error {
	ctx := c.Request().Context()

	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid user ID"})
	}

	req := new(request.UpdateUserRequest)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": err.Error()})
	}

	if err := c.Validate(req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": err.Error()})
	}

	user, err := h.userService.GetUserByID(ctx, uint(id))
	if err != nil {
		if err == service.ErrUserNotFound {
			return c.JSON(http.StatusNotFound, map[string]string{"error": "User not found"})
		}
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
	}

	user.Name = req.Name
	user.Email = req.Email
	if req.Password != "" {
		user.Password = req.Password
	}
	if req.Role != "" {
		user.Role = req.Role
	}

	err = h.userService.UpdateUser(ctx, user)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
	}

	return c.JSON(http.StatusOK, response.FromEntity(user))
}

// DeleteUser godoc
// @Summary Delete a user by ID
// @Tags Users
// @Param id path int true "User ID"
// @Success 204 {object} nil
// @Failure 400 {object} map[string]string
// @Failure 404 {object} map[string]string
// @Failure 500 {object} map[string]string
// @Router /users/{id} [delete]
func (h *UserHandler) DeleteUser(c echo.Context) error {
	ctx := c.Request().Context()

	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid user ID"})
	}

	err = h.userService.DeleteUser(ctx, uint(id))
	if err != nil {
		if err == service.ErrUserNotFound {
			return c.JSON(http.StatusNotFound, map[string]string{"error": "User not found"})
		}
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
	}

	return c.NoContent(http.StatusNoContent)
}

// GetMe godoc
// @Summary      Get current user profile
// @Description  Get authenticated user's profile
// @Tags         users
// @Produce      json
// @Success      200 {object} utils.Response
// @Failure      401 {object} utils.Response
// @Failure      404 {object} utils.Response
// @Failure      500 {object} utils.Response
// @Security     BearerAuth
// @Router       /user/token [get]

func (h *UserHandler) GetMe(c echo.Context) error {
	ctx := c.Request().Context()
	claimsRaw := c.Get("user")
	fmt.Printf("[DEBUG] claimsRaw type: %T, value: %#v\n", claimsRaw, claimsRaw)

	var claims map[string]interface{}
	switch v := claimsRaw.(type) {
	case map[string]interface{}:
		claims = v
		fmt.Println("[DEBUG] claims as map[string]interface{}:", claims)
	case jwt.MapClaims:
		claims = map[string]interface{}(v)
		fmt.Println("[DEBUG] claims as jwt.MapClaims:", claims)
	default:
		fmt.Println("[DEBUG] Invalid token claims type:", claimsRaw)
		return h.resp.UnauthorizedResponse(c, "Invalid token claims")
	}

	userIDValue, ok := claims["user_id"]
	fmt.Printf("[DEBUG] userIDValue: %v, exists: %v\n", userIDValue, ok)
	if !ok {
		return h.resp.UnauthorizedResponse(c, "User ID not found in token")
	}

	var userID uint
	switch v := userIDValue.(type) {
	case float64:
		userID = uint(v)
		fmt.Println("[DEBUG] userID from float64:", userID)
	case string:
		parsed, err := strconv.ParseUint(v, 10, 32)
		if err != nil {
			fmt.Println("[DEBUG] Error parsing userID string:", err)
			return h.resp.UnauthorizedResponse(c, "Invalid user ID in token")
		}
		userID = uint(parsed)
		fmt.Println("[DEBUG] userID from string:", userID)
	default:
		fmt.Println("[DEBUG] Invalid user ID type:", userIDValue)
		return h.resp.UnauthorizedResponse(c, "Invalid user ID type in token")
	}

	user, err := h.userService.GetUserByID(ctx, userID)
	if err != nil {
		if err == service.ErrUserNotFound {
			fmt.Println("[DEBUG] User not found for ID:", userID)
			return h.resp.NotFoundResponse(c, "User not found")
		}
		fmt.Println("[DEBUG] Internal server error:", err)
		return h.resp.InternalServerErrorResponse(c, err.Error())
	}
	fmt.Println("[DEBUG] Found user:", user)
	return h.resp.SuccessResponse(c, response.FromEntityMe(user), "success")
}

// RegisterRoutes registers the user routes
func (h *UserHandler) RegisterRoutes(e *echo.Echo, basePath string) {
	group := e.Group(basePath+"/users", middleware.Auth)

	group.GET("", h.GetAllUsers)
	group.GET("/:id", h.GetUser)
	group.POST("", h.CreateUser)
	group.PUT("/:id", h.UpdateUser)
	group.DELETE("/:id", h.DeleteUser)

	e.GET(basePath+"/user/token", h.GetMe, middleware.Auth)
}

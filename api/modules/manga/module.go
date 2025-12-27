package manga

import (
	"nanonime/internal/pkg/bus"
	"nanonime/internal/pkg/logger"

	"github.com/labstack/echo/v4"
	"gorm.io/gorm"
)

// Module implements the application Module interface for the manga module
type Module struct {
	db         *gorm.DB
	logger     *logger.Logger
	event      *bus.EventBus
	controller *Controller
}

// Name returns the name of the module
func (m *Module) Name() string {
	return "manga"
}

// Initialize initializes the module
func (m *Module) Initialize(db *gorm.DB, log *logger.Logger, event *bus.EventBus) error {
	m.db = db
	m.logger = log
	m.event = event

	m.logger.Info("Initializing manga module")

	// Initialize manga controller (proxy to manga API)
	m.controller = NewController()
	m.logger.Debug("Manga controller initialized")

	m.logger.Info("Manga module initialized successfully")
	return nil
}

// RegisterRoutes registers the module's routes
func (m *Module) RegisterRoutes(e *echo.Echo, basePath string) {
	m.logger.Info("Registering manga routes at %s/manga", basePath)

	// Create manga group: /api/v1/manga
	mangaGroup := e.Group(basePath + "/manga")

	// Health check endpoint
	mangaGroup.GET("/health", m.controller.HealthCheck)

	// Proxy all other requests to manga API
	mangaGroup.Any("/*", m.controller.ProxyHandler)

	m.logger.Debug("Manga routes registered successfully")
}

// Migrations returns the module's migrations
func (m *Module) Migrations() error {
	m.logger.Info("Manga module has no database migrations")
	return nil
}

// Logger returns the module's logger
func (m *Module) Logger() *logger.Logger {
	return m.logger
}

// NewModule creates a new manga module
func NewModule() *Module {
	return &Module{}
}

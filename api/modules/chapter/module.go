package chapter

import (
	"nanonime/internal/pkg/bus"
	"nanonime/internal/pkg/logger"

	"github.com/labstack/echo"
	"gorm.io/gorm"
)

// Module implements the application Module interface for the chapter module
type Module struct {
	db         *gorm.DB
	logger     *logger.Logger
	event      *bus.EventBus
	controller *Controller
}

// Name returns the name of the module
func (m *Module) Name() string {
	return "chapter"
}

// Initialize initializes the module
func (m *Module) Initialize(db *gorm.DB, log *logger.Logger, event *bus.EventBus) error {
	m.db = db
	m.logger = log
	m.event = event

	m.logger.Info("Initializing chapter module")

	// Initialize chapter controller (proxy to chapter API)
	m.controller = NewController()
	m.logger.Debug("Chapter controller initialized")

	m.logger.Info("Chapter module initialized successfully")
	return nil
}

// RegisterRoutes registers the module's routes
func (m *Module) RegisterRoutes(e *echo.Echo, basePath string) {
	m.logger.Info("Registering chapter routes at %s/chapter", basePath)

	// Create chapter group: /api/v1/chapter
	chapterGroup := e.Group(basePath + "/chapter")

	// Health check endpoint
	chapterGroup.GET("/health", m.controller.HealthCheck)

	// Proxy all other requests to chapter API
	chapterGroup.Any("/*", m.controller.ProxyHandler)

	m.logger.Debug("Chapter routes registered successfully")
}

// Migrations returns the module's migrations
func (m *Module) Migrations() error {
	m.logger.Info("Chapter module has no database migrations")
	return nil
}

// Logger returns the module's logger
func (m *Module) Logger() *logger.Logger {
	return m.logger
}

// NewModule creates a new chapter module
func NewModule() *Module {
	return &Module{}
}

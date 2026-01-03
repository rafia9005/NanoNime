package anime

import (
	"nanonime/internal/pkg/bus"
	"nanonime/internal/pkg/logger"

	"github.com/labstack/echo/v4"
	"gorm.io/gorm"
)

// Module implements the application Module interface for the anime module
type Module struct {
	db         *gorm.DB
	logger     *logger.Logger
	event      *bus.EventBus
	controller *Controller
}

// Name returns the name of the module
func (m *Module) Name() string {
	return "anime"
}

// Initialize initializes the module
func (m *Module) Initialize(db *gorm.DB, log *logger.Logger, event *bus.EventBus) error {
	m.db = db
	m.logger = log
	m.event = event

	m.logger.Info("Initializing anime module")

	// Initialize anime controller (proxy to otakudesu API)
	m.controller = NewController()
	m.logger.Debug("Anime controller initialized")

	m.logger.Info("Anime module initialized successfully")
	return nil
}

// RegisterRoutes registers the module's routes
func (m *Module) RegisterRoutes(e *echo.Echo, basePath string) {
	m.logger.Info("Registering anime routes at %s/anime", basePath)

	// Create anime group: /api/v1/anime
	animeGroup := e.Group(basePath + "/anime")

	// Health check endpoint
	animeGroup.GET("/health", m.controller.HealthCheck)

	// Image proxy
	animeGroup.GET("/image", m.controller.ImageProxyHandler)

	// Genres (Mock)
	animeGroup.GET("/genres", m.controller.GetGenres)

	// Proxy all other requests to otakudesu API
	// Examples:
	//   GET /api/v1/anime/home -> http://localhost:3001/otakudesu/home
	//   GET /api/v1/anime/search?q=naruto -> http://localhost:3001/otakudesu/search?q=naruto
	//   GET /api/v1/anime/anime/:id -> http://localhost:3001/otakudesu/anime/:id
	animeGroup.Any("/*", m.controller.ProxyHandler)

	m.logger.Debug("Anime routes registered successfully")
}

// Migrations returns the module's migrations
func (m *Module) Migrations() error {
	m.logger.Info("Anime module has no database migrations")
	return nil
}

// Logger returns the module's logger
func (m *Module) Logger() *logger.Logger {
	return m.logger
}

// NewModule creates a new anime module
func NewModule() *Module {
	return &Module{}
}

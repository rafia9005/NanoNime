.PHONY: run dev stop clean help install build check setup

# Colors
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m

.DEFAULT_GOAL := help

## help: Display this help message
help:
	@echo "$(BLUE)╔════════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║              Nanonime API - Makefile Commands                  ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(GREEN)Available commands:$(NC)"
	@echo ""
	@echo "  make run         - Run both Air (Go) and npm (Anime API) with hot reload"
	@echo "  make dev         - Alias for run"
	@echo "  make air         - Run only Air (Go API)"
	@echo "  make npm         - Run only npm (Anime API)"
	@echo "  make stop        - Stop all running processes"
	@echo "  make install     - Install all dependencies"
	@echo "  make build       - Build both projects"
	@echo "  make clean       - Clean build artifacts"
	@echo "  make check       - Check dependencies"
	@echo "  make setup       - Initial setup"
	@echo ""

## run: Run both Air and npm with hot reload
run:
	@./run-dev.sh

## dev: Alias for run
dev: run

## air: Run only Air (Go API)
air:
	@echo "$(GREEN)🚀 Starting Go API with Air...$(NC)"
	@air

## npm: Run only npm (Anime API)
npm:
	@echo "$(BLUE)🚀 Starting Anime API with npm...$(NC)"
	@cd endpoint/anime && npm run dev

## install: Install dependencies
install:
	@echo "$(GREEN)📦 Installing Go dependencies...$(NC)"
	@go mod download
	@echo ""
	@echo "$(BLUE)📦 Installing npm dependencies...$(NC)"
	@cd endpoint/anime && npm install
	@echo ""
	@echo "$(GREEN)✅ All dependencies installed!$(NC)"

## build: Build both projects
build:
	@echo "$(GREEN)🔨 Building Go API...$(NC)"
	@go build -o ./tmp/main .
	@echo ""
	@echo "$(BLUE)🔨 Building Anime API...$(NC)"
	@cd endpoint/anime && npm run build
	@echo ""
	@echo "$(GREEN)✅ Build complete!$(NC)"

## clean: Clean build artifacts
clean:
	@echo "$(YELLOW)🧹 Cleaning build artifacts...$(NC)"
	@rm -rf tmp/
	@rm -rf endpoint/anime/dist/
	@rm -f build-errors.log
	@echo "$(GREEN)✅ Clean complete!$(NC)"

## stop: Stop all running processes
stop:
	@echo "$(RED)🛑 Stopping all processes...$(NC)"
	@pkill -9 -f "^air$$" 2>/dev/null || true
	@pkill -9 -f "tsx watch" 2>/dev/null || true
	@pkill -9 -f "npm run dev" 2>/dev/null || true
	@lsof -ti:8080 2>/dev/null | xargs kill -9 2>/dev/null || true
	@lsof -ti:3001 2>/dev/null | xargs kill -9 2>/dev/null || true
	@echo "$(GREEN)✅ All processes stopped!$(NC)"

## check: Check dependencies
check:
	@echo "$(BLUE)🔍 Checking dependencies...$(NC)"
	@echo ""
	@command -v go >/dev/null 2>&1 && echo "$(GREEN)✅ Go installed$(NC)" || echo "$(RED)❌ Go not installed$(NC)"
	@command -v air >/dev/null 2>&1 && echo "$(GREEN)✅ Air installed$(NC)" || echo "$(YELLOW)⚠️  Air not installed$(NC)"
	@command -v node >/dev/null 2>&1 && echo "$(GREEN)✅ Node.js installed$(NC)" || echo "$(RED)❌ Node.js not installed$(NC)"
	@command -v npm >/dev/null 2>&1 && echo "$(GREEN)✅ npm installed$(NC)" || echo "$(RED)❌ npm not installed$(NC)"
	@[ -f config.toml ] && echo "$(GREEN)✅ config.toml exists$(NC)" || echo "$(YELLOW)⚠️  config.toml not found$(NC)"
	@[ -d endpoint/anime/node_modules ] && echo "$(GREEN)✅ npm dependencies installed$(NC)" || echo "$(YELLOW)⚠️  npm dependencies not installed$(NC)"
	@echo ""

## setup: Initial setup
setup:
	@echo "$(BLUE)🔧 Setting up Nanonime API...$(NC)"
	@echo ""
	@if [ ! -f config.toml ]; then \
		echo "$(YELLOW)📄 Creating config.toml...$(NC)"; \
		cp config-example.toml config.toml; \
		echo "$(GREEN)✅ config.toml created!$(NC)"; \
		echo ""; \
	fi
	@$(MAKE) install
	@echo ""
	@echo "$(GREEN)╔════════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(GREEN)║                  ✅ Setup Complete!                            ║$(NC)"
	@echo "$(GREEN)╚════════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(YELLOW)Next steps:$(NC)"
	@echo "  1. Update config.toml with your settings"
	@echo "  2. Run: $(GREEN)make run$(NC)"
	@echo ""

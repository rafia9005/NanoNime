#!/bin/bash

# Nanonime API - Development Runner
# Runs both Air (Go) and npm (Anime API) with proper cleanup on exit

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Process IDs
AIR_PID=""
NPM_PID=""

# Cleanup function
cleanup() {
    echo ""
    echo -e "${RED}🛑 Stopping all services...${NC}"

    # Kill Air process
    if [ ! -z "$AIR_PID" ]; then
        kill -TERM $AIR_PID 2>/dev/null || true
        wait $AIR_PID 2>/dev/null || true
    fi

    # Kill npm process and all its children
    if [ ! -z "$NPM_PID" ]; then
        # Kill the entire process group
        pkill -TERM -P $NPM_PID 2>/dev/null || true
        kill -TERM $NPM_PID 2>/dev/null || true
        wait $NPM_PID 2>/dev/null || true
    fi

    # Fallback: kill by name
    pkill -9 -f "air" 2>/dev/null || true
    pkill -9 -f "tsx watch" 2>/dev/null || true
    pkill -9 -f "npm run dev" 2>/dev/null || true

    # Kill by port
    lsof -ti:8080 2>/dev/null | xargs kill -9 2>/dev/null || true
    lsof -ti:3001 2>/dev/null | xargs kill -9 2>/dev/null || true

    echo -e "${GREEN}✅ All services stopped${NC}"
    exit 0
}

# Trap signals
trap cleanup SIGINT SIGTERM EXIT

# Header
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           Starting Nanonime API Development Servers            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if config.toml exists
if [ ! -f "config.toml" ]; then
    echo -e "${YELLOW}⚠️  config.toml not found!${NC}"
    if [ -f "config-example.toml" ]; then
        echo -e "${BLUE}📄 Creating config.toml from config-example.toml...${NC}"
        cp config-example.toml config.toml
        echo -e "${GREEN}✅ config.toml created!${NC}"
        echo -e "${YELLOW}⚠️  Please update config.toml with your settings${NC}"
        echo ""
    fi
fi

# Check if Air is installed
if ! command -v air &> /dev/null; then
    echo -e "${YELLOW}⚠️  Air is not installed!${NC}"
    echo -e "${BLUE}📦 Installing Air...${NC}"
    go install github.com/air-verse/air@latest
    echo -e "${GREEN}✅ Air installed!${NC}"
    echo ""
fi

# Check if npm dependencies are installed
if [ ! -d "endpoint/anime/node_modules" ]; then
    echo -e "${YELLOW}⚠️  npm dependencies not installed!${NC}"
    echo -e "${BLUE}📦 Installing npm dependencies...${NC}"
    cd endpoint/anime
    npm install
    cd ../..
    echo -e "${GREEN}✅ npm dependencies installed!${NC}"
    echo ""
fi

echo -e "${GREEN}🚀 Starting services...${NC}"
echo -e "${YELLOW}   • Go API (Air): http://localhost:8080${NC}"
echo -e "${YELLOW}   • Anime API (npm): http://localhost:3001${NC}"
echo ""
echo -e "${YELLOW}💡 Press Ctrl+C to stop all services${NC}"
echo ""

# Start Air in background
air 2>&1 | sed "s/^/$(echo -e ${GREEN})[Air]$(echo -e ${NC}) /" &
AIR_PID=$!

# Start npm in background
cd endpoint/anime
npm run dev 2>&1 | sed "s/^/$(echo -e ${BLUE})[npm]$(echo -e ${NC}) /" &
NPM_PID=$!
cd ../..

# Wait for any process to exit
wait -n $AIR_PID $NPM_PID

# If we get here, one process died, cleanup everything
cleanup

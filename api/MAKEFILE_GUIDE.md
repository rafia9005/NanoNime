# Makefile Guide - Nanonime API

Quick guide for using the Makefile to manage the Nanonime API development.

## 🚀 Quick Start

```bash
# First time setup
make setup

# Run development servers
make run

# Stop: Press Ctrl+C
```

---

## 📋 Available Commands

### Development

```bash
# Run both Air (Go) and npm (Anime API)
make run
make dev      # Alias for run

# Run only Go API
make air

# Run only Anime API  
make npm
```

### Setup & Installation

```bash
# Initial setup (install deps + create config)
make setup

# Install all dependencies
make install

# Check if dependencies are installed
make check
```

### Build & Clean

```bash
# Build both projects
make build

# Clean build artifacts
make clean
```

### Stop Processes

```bash
# Stop all running processes
make stop

# Or just press Ctrl+C when running
```

### Help

```bash
# Show all available commands
make help
make          # Default shows help
```

---

## 🔧 How It Works

### `make run`

Executes `./run-dev.sh` which:
1. Checks dependencies (Air, npm, config.toml)
2. Starts Air (Go API) on port 8080
3. Starts npm dev (Anime API) on port 3001
4. Monitors both processes
5. On Ctrl+C: Kills both processes and all children

**Output:**
```
╔════════════════════════════════════════════════════════════════╗
║           Starting Nanonime API Development Servers            ║
╚════════════════════════════════════════════════════════════════╝

🚀 Starting services...
   • Go API (Air): http://localhost:8080
   • Anime API (npm): http://localhost:3001

💡 Press Ctrl+C to stop all services

[Air] Starting server...
[npm] > dev
[npm] > tsx watch src/index.ts
[Air] Server running on :8080
[npm] Server listening on port 3001
```

### `make stop`

Forcefully kills all processes:
- Air processes
- tsx watch processes
- npm run dev processes
- Anything using port 8080 or 3001

```bash
make stop
```

---

## 📊 Process Management

### Signal Handling

The `run-dev.sh` script properly handles:
- **SIGINT** (Ctrl+C)
- **SIGTERM** (kill command)
- **EXIT** (script exit)

All signals trigger cleanup that kills:
1. Air process and its children
2. npm process and its children
3. Fallback: kill by process name
4. Fallback: kill by port number

### Why Shell Script?

Makefile has limitations with:
- Process group management
- Signal handling  
- Variable expansion (`$$` issues)

So we use `run-dev.sh` for complex process management.

---

## 🎯 Common Workflows

### First Time Setup

```bash
# 1. Clone project
git clone <repo>
cd nanonime/api

# 2. Setup (creates config, installs deps)
make setup

# 3. Edit config.toml
nano config.toml

# 4. Run development servers
make run
```

### Daily Development

```bash
# Start servers
make run

# Edit files → Auto reload!
# Air reloads Go code
# npm dev reloads TypeScript code

# Stop servers
# Press Ctrl+C

# Start again
make run
```

### Troubleshooting

```bash
# Check if everything is installed
make check

# If processes won't stop
make stop

# Clean and rebuild
make clean
make build

# Check running processes
lsof -i :8080
lsof -i :3001

# Kill manually if needed
pkill -9 -f "air"
pkill -9 -f "tsx watch"
```

---

## 🔍 Behind the Scenes

### Makefile

- Simple interface
- Calls `run-dev.sh` for complex tasks
- Uses ANSI colors for output

### run-dev.sh

```bash
#!/bin/bash

# 1. Setup cleanup trap
trap cleanup SIGINT SIGTERM EXIT

# 2. Check dependencies
# 3. Start processes
air &
AIR_PID=$!

npm run dev &
NPM_PID=$!

# 4. Wait for processes
wait -n $AIR_PID $NPM_PID

# 5. Cleanup on exit
cleanup() {
    kill $AIR_PID $NPM_PID
    pkill -9 -f "tsx watch"
    # ... cleanup
}
```

---

## ⚙️ Configuration

### Ports

| Service | Port | Config |
|---------|------|--------|
| Go API | 8080 | config.toml |
| Anime API | 3001 | endpoint/anime/src/index.ts |

### Change Ports

**Go API:**
```toml
# config.toml
[server]
port = "8080"  # Change this
```

**Anime API:**
```typescript
// endpoint/anime/src/index.ts
const PORT = process.env.PORT || 3001; // Change this
```

---

## 🐛 Troubleshooting

### Problem: "Port already in use"

```bash
# Find process using port
lsof -ti:8080
lsof -ti:3001

# Kill it
make stop

# Or manually
kill -9 $(lsof -ti:8080)
kill -9 $(lsof -ti:3001)
```

### Problem: "Air not found"

```bash
# Install Air
go install github.com/air-verse/air@latest

# Add to PATH
export PATH=$PATH:$(go env GOPATH)/bin

# Or use make install
make install
```

### Problem: "npm modules not found"

```bash
# Install npm dependencies
cd endpoint/anime
npm install

# Or use make install
make install
```

### Problem: "Processes won't stop"

```bash
# Force stop
make stop

# Check if still running
ps aux | grep air
ps aux | grep tsx

# Nuclear option
pkill -9 -f "air|tsx|npm"
```

---

## 📝 Tips

1. **Always use `make run`** instead of running Air/npm separately
2. **Use Ctrl+C** to stop - it's the cleanest way
3. **`make stop`** is the nuclear option - use if Ctrl+C doesn't work
4. **Check ports** with `lsof -i :8080` before running
5. **Keep terminal open** - closing terminal might leave processes running

---

## 🎉 Best Practices

✅ **DO:**
- Use `make run` for development
- Press Ctrl+C to stop
- Use `make check` to verify setup
- Use `make clean` before committing

❌ **DON'T:**
- Run air and npm separately (use `make run`)
- Close terminal without stopping (use Ctrl+C)
- Forget to stop before changing ports
- Leave processes running when not developing

---

**Last Updated:** January 2025  
**Version:** 1.0.0

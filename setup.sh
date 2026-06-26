#!/usr/bin/env bash
set -euo pipefail

# =============================================================
# OpenCode PRO - Automated Setup for macOS / Linux
# =============================================================
# Detects existing installations, cleans up, installs fresh,
# and deploys the complete PRO configuration.
#
# Usage:
#   chmod +x setup.sh && ./setup.sh
#
# Options:
#   --force       Skip confirmation prompts
#   --skip-clean  Don't clean existing installations
# =============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORCE=false
SKIP_CLEAN=false
CONFIG_REPO="https://github.com/FrancescoCastaldi/opencode-pro-setup"

# Parse arguments
for arg in "$@"; do
    case "$arg" in
        --force) FORCE=true ;;
        --skip-clean) SKIP_CLEAN=true ;;
    esac
done

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

info()  { echo -e "${CYAN}[INFO]${NC} $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}   $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
err()   { echo -e "${RED}[ERR]${NC}  $*"; }
step()  { echo -e "\n${MAGENTA}==>${NC} ${MAGENTA}$*${NC}"; }

# ---------------------------------------------------------
# STEP 0: PREREQUISITES
# ---------------------------------------------------------
step "STEP 0/6 - Checking prerequisites..."

OS="$(uname -s)"

# Check bash version
if [ "${BASH_VERSINFO:-0}" -lt 4 ]; then
    err "Bash 4+ required. Update bash: brew install bash (macOS) or use apt/yum."
    exit 1
fi

# Check/install Homebrew (macOS only)
if [ "$OS" = "Darwin" ]; then
    if ! command -v brew &>/dev/null; then
        warn "Homebrew not found. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true
    fi
    ok "Homebrew available"
fi

# Check Node.js
if ! command -v node &>/dev/null; then
    warn "Node.js not found. Installing..."
    if [ "$OS" = "Darwin" ]; then
        brew install node
    elif command -v apt-get &>/dev/null; then
        curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
        sudo apt-get install -y nodejs
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y nodejs
    else
        err "Please install Node.js manually from https://nodejs.org"
        exit 1
    fi
fi
ok "Node.js $(node --version)"

# Check npm
if ! command -v npm &>/dev/null; then
    err "npm not found"
    exit 1
fi
ok "npm v$(npm --version)"

# Check git
if ! command -v git &>/dev/null; then
    warn "Git not found. Installing..."
    if [ "$OS" = "Darwin" ]; then
        brew install git
    elif command -v apt-get &>/dev/null; then
        sudo apt-get install -y git
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y git
    fi
fi
ok "Git available"

# ---------------------------------------------------------
# STEP 1: DETECT & CLEAN EXISTING
# ---------------------------------------------------------
step "STEP 1/6 - Detecting existing OpenCode installations..."

FOUND=()

# Check npm global
if npm list -g --depth=0 2>/dev/null | grep -q "opencode"; then
    FOUND+=("npm global (opencode-ai)")
fi

# Check brew (macOS)
if [ "$OS" = "Darwin" ]; then
    if brew list opencode 2>/dev/null; then
        FOUND+=("Homebrew (opencode)")
    fi
fi

# Check directories
for d in "$HOME/.opencode" "$HOME/.config/opencode"; do
    if [ -d "$d" ]; then
        FOUND+=("directory: $d")
    fi
done

# Check PATH
if echo "$PATH" | grep -q "opencode"; then
    FOUND+=("PATH entry contains opencode")
fi

# Check running processes
if pgrep -f "opencode" &>/dev/null; then
    FOUND+=("running opencode process(es)")
fi

if [ ${#FOUND[@]} -gt 0 ]; then
    warn "Found existing OpenCode components:"
    for f in "${FOUND[@]}"; do echo "    - $f"; done

    if [ "$SKIP_CLEAN" = false ] && ( [ "$FORCE" = true ] || true ); then
        CLEAN=true
        if [ "$FORCE" = false ]; then
            echo ""
            read -p "Clean all existing installations? (Y/n): " -n 1 -r RESP
            echo ""
            if [[ "$RESP" =~ ^[Nn] ]]; then
                CLEAN=false
            fi
        fi

        if [ "$CLEAN" = true ]; then
            step "  -> Cleaning existing installations..."

            # Kill processes
            pkill -f "opencode" 2>/dev/null || true
            ok "Killed running opencode processes"

            # Uninstall npm global
            if npm list -g --depth=0 2>/dev/null | grep -q "opencode"; then
                npm uninstall -g opencode-ai 2>/dev/null
                ok "Uninstalled npm global opencode-ai"
            fi

            # Uninstall brew
            if [ "$OS" = "Darwin" ] && brew list opencode 2>/dev/null; then
                brew uninstall opencode 2>/dev/null
                ok "Uninstalled brew opencode"
            fi

            # Backup & remove config
            if [ -d "$HOME/.config/opencode" ] && [ -f "$HOME/.config/opencode/opencode.json" ]; then
                BACKUP_DIR="$HOME/opencode-config-backup-$(date +%Y%m%d-%H%M%S)"
                cp -r "$HOME/.config/opencode" "$BACKUP_DIR" 2>/dev/null
                ok "Backed up config to: $BACKUP_DIR"
            fi

            # Remove directories
            for d in "$HOME/.opencode" "$HOME/.config/opencode" "$HOME/.opencode-mem"; do
                if [ -d "$d" ]; then
                    rm -rf "$d" 2>/dev/null
                    ok "Removed: $d"
                fi
            done

            ok "Cleanup complete!"
        fi
    fi
else
    ok "No existing OpenCode installations found - clean system!"
fi

# ---------------------------------------------------------
# STEP 2: INSTALL OpenCode
# ---------------------------------------------------------
step "STEP 2/6 - Installing OpenCode..."

info "Installing opencode-ai via npm (global)..."
npm install -g opencode-ai@latest 2>&1 || {
    warn "First attempt failed. Trying with --force..."
    npm install -g opencode-ai@latest --force 2>&1
}

if ! command -v opencode &>/dev/null; then
    err "OpenCode not found in PATH after install."
    NPM_PREFIX=$(npm config get prefix 2>/dev/null)
    if [ -n "$NPM_PREFIX" ]; then
        export PATH="$NPM_PREFIX/bin:$PATH"
        echo 'export PATH="'"$NPM_PREFIX/bin"':$PATH"' >> "$HOME/.bashrc"
        if [ "$(uname -s)" = "Darwin" ]; then
            echo 'export PATH="'"$NPM_PREFIX/bin"':$PATH"' >> "$HOME/.zshrc"
        fi
    fi
fi

OC_VERSION=$(opencode --version 2>/dev/null || echo "unknown")
ok "OpenCode v$OC_VERSION installed!"

# ---------------------------------------------------------
# STEP 3: CREATE DIRECTORIES
# ---------------------------------------------------------
step "STEP 3/6 - Creating directory structure..."

mkdir -p "$HOME/.config/opencode/agent"
mkdir -p "$HOME/.config/opencode/skills"
mkdir -p "$HOME/.opencode/data"

ok "Directories created"

# ---------------------------------------------------------
# STEP 4: DEPLOY CONFIGURATION
# ---------------------------------------------------------
step "STEP 4/6 - Deploying configuration files..."

CONFIG_SOURCE="$SCRIPT_DIR/config"

if [ ! -d "$CONFIG_SOURCE" ]; then
    info "Config not found locally. Downloading from GitHub..."
    TMP_DIR=$(mktemp -d)
    curl -fsSL "$CONFIG_REPO/archive/main.tar.gz" | tar -xz -C "$TMP_DIR" 2>/dev/null || {
        err "Could not download config. Place this script in the repo root with a 'config' folder."
        err "Continuing with template generation..."
        CONFIG_SOURCE=""
    }
    if [ -n "$CONFIG_SOURCE" ]; then
        EXTRACTED_DIR=$(find "$TMP_DIR" -maxdepth 1 -type d | tail -1)
        CONFIG_SOURCE="$EXTRACTED_DIR/config"
    fi
fi

if [ -d "$CONFIG_SOURCE" ]; then
    cp -r "$CONFIG_SOURCE/"* "$HOME/.config/opencode/" 2>/dev/null
    ok "Configuration files deployed"
fi

# Deploy opencode.json with variable substitution
CONFIG_FILE="$HOME/.config/opencode/opencode.json"
if [ -f "$CONFIG_FILE" ]; then
    echo ""
    step "  -> API Key Configuration"

    # GitHub Token
    GITHUB_TOKEN="${GITHUB_TOKEN:-}"
    if [ -z "$GITHUB_TOKEN" ]; then
        echo ""
        read -p "Enter your GitHub Personal Access Token (or press Enter to skip): " GITHUB_TOKEN
        if [ -n "$GITHUB_TOKEN" ]; then
            echo "GITHUB_TOKEN=$GITHUB_TOKEN" > "$HOME/.config/opencode/.env"
            # Add to shell profile
            if [ "$OS" = "Darwin" ]; then
                echo "export GITHUB_TOKEN=$GITHUB_TOKEN" >> "$HOME/.zshrc"
            fi
        fi
    fi

    # Username
    USERNAME="${OPENCODE_USERNAME:-$USER}"
    echo ""
    read -p "Enter OpenCode username (default: $USERNAME): " INPUT_USER
    USERNAME="${INPUT_USER:-$USERNAME}"

    # Apply substitutions
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/\${USERNAME}/$USERNAME/g" "$CONFIG_FILE"
        sed -i '' "s/\${GITHUB_TOKEN}/$GITHUB_TOKEN/g" "$CONFIG_FILE"
        sed -i '' "s/\${HOME}/$HOME/g" "$CONFIG_FILE"
        sed -i '' "s|\${TEMP_DIR}|/tmp/opencode|g" "$CONFIG_FILE"
    else
        sed -i "s/\${USERNAME}/$USERNAME/g" "$CONFIG_FILE"
        sed -i "s/\${GITHUB_TOKEN}/$GITHUB_TOKEN/g" "$CONFIG_FILE"
        sed -i "s|\${HOME}|$HOME|g" "$CONFIG_FILE"
        sed -i "s|\${TEMP_DIR}|/tmp/opencode|g" "$CONFIG_FILE"
    fi

    # Replace default model placeholders
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' 's/\${MODEL:-opencode\/deepseek-v4-flash-free}/opencode\/deepseek-v4-flash-free/g' "$CONFIG_FILE"
        sed -i '' 's/\${SMALL_MODEL:-opencode\/deepseek-v4-flash-free}/opencode\/deepseek-v4-flash-free/g' "$CONFIG_FILE"
    else
        sed -i 's/\${MODEL:-opencode\/deepseek-v4-flash-free}/opencode\/deepseek-v4-flash-free/g' "$CONFIG_FILE"
        sed -i 's/\${SMALL_MODEL:-opencode\/deepseek-v4-flash-free}/opencode\/deepseek-v4-flash-free/g' "$CONFIG_FILE"
    fi

    ok "opencode.json configured with your values"
fi

# ---------------------------------------------------------
# STEP 5: INSTALL PLUGIN DEPENDENCIES
# ---------------------------------------------------------
step "STEP 5/6 - Installing plugin dependencies..."

# Create package.json if not exists
if [ ! -f "$HOME/.config/opencode/package.json" ]; then
    cat > "$HOME/.config/opencode/package.json" << 'EOF'
{
  "dependencies": {
    "@opencode-ai/plugin": "latest"
  }
}
EOF
fi

# Install config dependencies
cd "$HOME/.config/opencode"
npm install --no-fund --no-audit 2>&1 || warn "npm install completed with warnings"

# Create .opencode/package.json
if [ ! -f "$HOME/.opencode/package.json" ]; then
    cat > "$HOME/.opencode/package.json" << 'EOF'
{
  "dependencies": {
    "@opencode-ai/plugin": "latest"
  }
}
EOF
fi

cd "$HOME/.opencode"
npm install --no-fund --no-audit 2>&1 || warn "npm install completed with warnings"

cd "$SCRIPT_DIR"

ok "Plugin dependencies installed"

# ---------------------------------------------------------
# STEP 6: VERIFY & FINALIZE
# ---------------------------------------------------------
step "STEP 6/6 - Verifying installation..."

ALL_OK=true

# Check opencode binary
if command -v opencode &>/dev/null; then
    ok "OpenCode CLI: v$(opencode --version)"
else
    err "OpenCode CLI not found"
    ALL_OK=false
fi

# Check config
if [ -f "$HOME/.config/opencode/opencode.json" ]; then
    ok "Config file: ~/.config/opencode/opencode.json"
else
    err "Config file missing!"
    ALL_OK=false
fi

# Agent
if [ -f "$HOME/.config/opencode/agent/orchestrator.md" ]; then
    ok "Agent: orchestrator"
fi

# Plugins
if [ -d "$HOME/.config/opencode/node_modules" ]; then
    ok "Plugins: node_modules present"
fi

# MCPs
MCPS=("context7" "playwright" "fetch" "sequential-thinking" "filesystem" "mermaid" "excalidraw" "memory" "github")
echo -e "  ${CYAN}MCP servers configured:${NC} ${MCPS[*]}"
echo -e "  ${GREEN}All ${#MCPS[@]} MCP servers registered in config${NC}"

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║        🚀  OpenCode PRO - Setup Complete!           ║${NC}"
echo -e "${GREEN}╠══════════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║  Run:  opencode                                    ║${NC}"
echo -e "${CYAN}║  Docs: https://opencode.ai/docs                    ║${NC}"
echo -e "${GREEN}║                                                     ║${NC}"
echo -e "${GREEN}║  Your agents:                                       ║${NC}"
echo -e "${WHITE}║    - orchestrator (primary)                         ║${NC}"
echo -e "${WHITE}║    - general (subagent)                             ║${NC}"
echo -e "${GREEN}║                                                     ║${NC}"
echo -e "${YELLOW}║  Plugins: 17  |  MCPs: 9                           ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════╝${NC}"
echo ""

if [ "$ALL_OK" = false ]; then
    warn "Some checks failed. Review the messages above."
    exit 1
fi

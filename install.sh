#!/usr/bin/env bash
# Maestro One-Line Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/moquette/dotfiles/main/install.sh | bash
#
# What this does:
#   1. Clones the repo to ~/.dotfiles (or updates if exists)
#   2. Creates ~/.zshrc symlink pointing to the orchestrator
#   3. Sources the orchestrator to bootstrap everything
#
# The orchestrator then auto-discovers CLOUD_FOLDER from existing symlinks
# or falls back to the default iCloud location.

set -e

REPO_URL="${MAESTRO_REPO_URL:-https://github.com/moquette/dotfiles.git}"
INSTALL_DIR="${MAESTRO_INSTALL_DIR:-$HOME/.dotfiles}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log() { echo -e "${CYAN}→${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; exit 1; }

# Check for required commands
command -v git >/dev/null 2>&1 || error "Git is required. Install Xcode Command Line Tools: xcode-select --install"

# Clone or update the repository
if [[ -d "$INSTALL_DIR/.git" ]]; then
  log "Updating existing Maestro installation..."
  git -C "$INSTALL_DIR" pull --ff-only 2>/dev/null || warn "Could not update (uncommitted changes?)"
  success "Repository updated"
else
  if [[ -d "$INSTALL_DIR" ]]; then
    warn "Directory $INSTALL_DIR exists but is not a git repo"
    log "Backing up to ${INSTALL_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
    mv "$INSTALL_DIR" "${INSTALL_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
  fi
  log "Cloning Maestro to $INSTALL_DIR..."
  git clone "$REPO_URL" "$INSTALL_DIR" || error "Failed to clone repository"
  success "Repository cloned"
fi

# Backup existing ~/.zshrc if it's not already our symlink
ORCHESTRATOR="$INSTALL_DIR/zshrc.symlink"
if [[ -f ~/.zshrc && ! -L ~/.zshrc ]]; then
  log "Backing up existing ~/.zshrc..."
  mv ~/.zshrc ~/.zshrc.backup."$(date +%Y%m%d_%H%M%S)"
  success "Backed up ~/.zshrc"
elif [[ -L ~/.zshrc ]]; then
  current_target="$(readlink ~/.zshrc)"
  if [[ "$current_target" != "$ORCHESTRATOR" ]]; then
    log "Updating ~/.zshrc symlink..."
  fi
fi

# Create symlink
ln -sf "$ORCHESTRATOR" ~/.zshrc
success "Created ~/.zshrc → $ORCHESTRATOR"

# Source the orchestrator
log "Bootstrapping Maestro..."
echo ""
# Use zsh to source since the orchestrator is zsh-specific
if command -v zsh >/dev/null 2>&1; then
  SHELL=/bin/zsh zsh -c "source ~/.zshrc"
else
  warn "zsh not found - orchestrator will run on next shell startup"
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Maestro installed successfully!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  Next steps:"
echo "    1. Start a new shell or run: source ~/.zshrc"
echo "    2. Set up your cloud folder (if not using iCloud default):"
echo "       export CLOUD_FOLDER=\"/path/to/your/cloud/Dotfiles\""
echo "    3. Run: dots status"
echo ""
echo "  Cloud folder location (auto-detected or default):"
echo "    ~/Library/Mobile Documents/com~apple~CloudDocs/Dotfiles"
echo ""
echo "  Documentation: https://github.com/moquette/dotfiles#readme"
echo ""

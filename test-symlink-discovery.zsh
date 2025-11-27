#!/usr/bin/env zsh
# Test script for convention-based symlink discovery

# Create a temporary test directory
TEST_DIR="/tmp/dots-test-$$"
CLOUD_FOLDER="$TEST_DIR/cloud"
HOME_DIR="$TEST_DIR/home"

echo "🧪 Testing convention-based symlink discovery..."
echo ""

# Setup test environment
mkdir -p "$CLOUD_FOLDER/system"
mkdir -p "$HOME_DIR"

# Create test files
touch "$CLOUD_FOLDER/system/aliases.symlink"
touch "$CLOUD_FOLDER/system/gitconfig.symlink"
mkdir -p "$CLOUD_FOLDER/system/ssh.symlink"
touch "$CLOUD_FOLDER/system/ssh.symlink/config"

# Create nested directory test
mkdir -p "$CLOUD_FOLDER/system/config-nvim.symlink/lua"
touch "$CLOUD_FOLDER/system/config-nvim.symlink/init.lua"

# Create an edge case file (should be in explicit array)
touch "$CLOUD_FOLDER/Code.symlink"

# Test Phase 1: Explicit array processing
echo "Phase 1: Testing explicit CUSTOM_SYMLINKS..."
CUSTOM_SYMLINKS=(
  "$CLOUD_FOLDER/Code.symlink|$HOME_DIR/Code"  # No leading dot
  "$CLOUD_FOLDER/system/config-nvim.symlink|$HOME_DIR/.config/nvim"  # Nested target
)

typeset -A processed_sources
for entry in "${CUSTOM_SYMLINKS[@]}"; do
  local src="${entry%%|*}"
  local dst="${entry##*|}"
  processed_sources[$src]=1
  echo "  ✓ Explicit: $(basename $src) → $dst"
done
echo ""

# Test Phase 2: Auto-discovery
echo "Phase 2: Testing auto-discovery..."
# shellcheck disable=SC2206,SC2296,SC1036,SC1088
local symlink_files=($CLOUD_FOLDER/**/*.symlink(N) $CLOUD_FOLDER/**/*.symlink/(N))

echo "  Found ${#symlink_files[@]} items:"
for src in "${symlink_files[@]}"; do
  if [[ -n "${processed_sources[$src]}" ]]; then
    # shellcheck disable=SC2296,SC1087,SC2248
    local basename="${${src:t}%.symlink}"
    echo "  ⊘ Skip (duplicate): $basename (already in explicit array)"
    continue
  fi
  
  processed_sources[$src]=1
  # shellcheck disable=SC2296,SC1087,SC2248
  local basename="${${src:t}%.symlink}"
  local dst="$HOME_DIR/.$basename"
  echo "  ✓ Auto-discover: $basename → $dst"
done
echo ""

# Cleanup
rm -rf "$TEST_DIR"

echo "✅ Test completed successfully!"
echo ""
echo "Next steps:"
echo "  1. Review test output above"
echo "  2. If looks good, follow MIGRATION.md to rename files"
echo "  3. Test with: rm ~/.dots/symlinks && source ~/.zshrc"

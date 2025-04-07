#!/usr/bin/env bash
set -euo pipefail

# Central configuration for dotfiles directory. 
# Use existing DOTFILES_DIR if set, 
# otherwise default to ~/.dotfiles
DOTFILES_DIR="${DOTFILES_DIR:-${HOME}/.dotfiles}"
export DOTFILES_DIR

#!/usr/bin/env bash
set -euo pipefail

# Central configuration for dotfiles directory. 
# Use existing DOTFILES_DIR if set, 
# otherwise default to ~/.dotfiles
DOTFILES_DIR="${DOTFILES_DIR:-${HOME}/.dotfiles}"
export DOTFILES_DIR

# Initialize INITIAL_PROMPT_SHOWN to an empty value (acts as a flag for the first prompt display)
INITIAL_PROMPT_SHOWN="${INITIAL_PROMPT_SHOWN:-}"
export INITIAL_PROMPT_SHOWN

#!/usr/bin/env bash
# Apply strict error handling in non-interactive mode only
if [[ $- != *i* ]]; then
  set -euo pipefail
else
  # Optionally, set a trap for ERR to log errors without exiting in interactive shells
  trap 'echo "An error occurred on line $LINENO." >&2' ERR
fi

# Central configuration for dotfiles directory. 
# Use existing DOTFILES_DIR if set, 
# otherwise default to ~/.dotfiles
DOTFILES_DIR="${DOTFILES_DIR:-${HOME}/.dotfiles}"
export DOTFILES_DIR

# Initialize INITIAL_PROMPT_SHOWN to an empty value (acts as a flag for the first prompt display)
INITIAL_PROMPT_SHOWN="${INITIAL_PROMPT_SHOWN:-}"
export INITIAL_PROMPT_SHOWN

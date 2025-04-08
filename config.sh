#!/usr/bin/env bash
# Apply strict error handling in non-interactive mode only
if [[ $- != *i* ]]; then
  set -euo pipefail
else
  # In interactive mode, only log errors if DEBUG_ERRORS is true
  if [[ "${DEBUG_ERRORS:-false}" == "true" ]]; then
    trap 'echo "An error occurred on line $LINENO." >&2' ERR
  fi
fi

# Central configuration for dotfiles directory. 
# Use existing DOTFILES_DIR if set, 
# otherwise default to ~/.dotfiles
DOTFILES_DIR="${DOTFILES_DIR:-${HOME}/.dotfiles}"
export DOTFILES_DIR

# SSH-related configuration for Local SSH directory
# This is used to define the location for storing SSH keys and configurations
# If you don't need SSH config files, you can comment out this section
#SSH_DIR="${SSH_DIR:-"${HOME}/Library/Mobile Documents/com~apple~CloudDocs/Dotfiles/Dotlocal/ssh"}"
SSH_DIR="${SSH_DIR:-"${HOME}/Private/Dotlocal/ssh"}"
export SSH_DIR

# === Local Configuration File ===
# This section defines and exports the LOCALRC_FILE variable, which stores the path to
# a local configuration file (usually containing secret or environment variables). 
# If the LOCALRC_FILE variable is not already set, it defaults to "$HOME/Private/Dotlocal/localrc".
# The variable is then exported to make it available globally for any child processes or scripts.
#LOCALRC_FILE="${LOCALRC_FILE:-"${HOME}/Library/Mobile Documents/com~apple~CloudDocs/Dotfiles/Dotlocal/localrc"}"
LOCALRC_FILE="${LOCALRC_FILE:-"${HOME}/Private/Dotlocal/localrc"}"
export LOCALRC_FILE

# Initialize INITIAL_PROMPT_SHOWN to an empty 
# value (acts as a flag for the first prompt display)
INITIAL_PROMPT_SHOWN="${INITIAL_PROMPT_SHOWN:-}"
export INITIAL_PROMPT_SHOWN

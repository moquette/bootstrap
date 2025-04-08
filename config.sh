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
#LOCAL_SSH_DIR="${LOCAL_SSH_DIR:-"${HOME}/Library/Mobile Documents/com~apple~CloudDocs/Dotfiles/Dotlocal/ssh"}"
LOCAL_SSH_DIR="${LOCAL_SSH_DIR:-"${HOME}/Private/Dotlocal/ssh"}"
export LOCAL_SSH_DIR

# === Local Configuration File ===
# This section defines and exports the LOCAL_RC_FILE variable, which stores the path to
# a local configuration file (usually containing secret or environment variables). 
# If the LOCAL_RC_FILE variable is not already set, it defaults to "$HOME/Private/Dotlocal/localrc".
# The variable is then exported to make it available globally for any child processes or scripts.
#LOCAL_RC_FILE="${LOCAL_RC_FILE:-"${HOME}/Library/Mobile Documents/com~apple~CloudDocs/Dotfiles/Dotlocal/localrc"}"
LOCAL_RC_FILE="${LOCAL_RC_FILE:-"${HOME}/Private/Dotlocal/localrc"}"
export LOCAL_RC_FILE

# Initialize INITIAL_PROMPT_SHOWN to an empty 
# value (acts as a flag for the first prompt display)
INITIAL_PROMPT_SHOWN="${INITIAL_PROMPT_SHOWN:-}"
export INITIAL_PROMPT_SHOWN

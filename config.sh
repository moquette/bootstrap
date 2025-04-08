#!/usr/bin/env bash
# Strict mode if not interactive, else trap errors if DEBUG_ERRORS=true
[[ $- != *i* ]] && set -euo pipefail || \
  [[ "${DEBUG_ERRORS:-false}" == "true" ]] && \
  trap 'echo "An error occurred on line $LINENO." >&2' ERR

# Set the base directory for dotfiles. Defaults to ~/.dotfiles if not already defined.
export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

# Define the SSH configuration directory. Defaults to ~/Private/Dotlocal/ssh.
# Adjust this path if you store SSH keys/configs elsewhere.
export SSH_DIR="${SSH_DIR:-$HOME/Private/Dotlocal/ssh}"

# Path to the local RC file containing private environment variables or secrets.
# Defaults to ~/Private/Dotlocal/localrc.
export LOCALRC_FILE="${LOCALRC_FILE:-$HOME/Private/Dotlocal/localrc}"

# A flag variable used to track whether the initial prompt has been shown.
# Defaults to an empty string if unset.
export INITIAL_PROMPT_SHOWN="${INITIAL_PROMPT_SHOWN:-}"
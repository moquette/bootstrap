#!/usr/bin/env bash
# Use Bash with strict error handling:
# -e: Exit immediately if a command exits with a non-zero status
# -u: Treat unset variables as an error and exit
# -o pipefail: Return the exit status of the last command in the pipeline that failed
set -euo pipefail

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
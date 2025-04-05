#!/bin/bash
# filepath: /Users/moquette/Code/bootstrap/setup_sudo.sh

setup_sudo() {
  if ! sudo -n true 2>/dev/null; then
    echo "Passwordless sudo is not enabled. Please enter your password to proceed."
    sudo -v
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
  fi
  echo "Passwordless sudo setup complete."
}

setup_sudo

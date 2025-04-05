#!/bin/bash
# filepath: /Users/moquette/Code/bootstrap/install_homebrew.sh

source ./bootstrap.conf

install_homebrew() {
  if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "Homebrew installation completed."
  else
    echo "Homebrew is already installed."
  fi
}

install_homebrew

#!/bin/bash
# filepath: /Users/moquette/Code/bootstrap/install_brewfile.sh

source ./bootstrap.conf

install_brewfile() {
  if [[ -f ./Brewfile ]]; then
    echo "Installing packages from Brewfile..."
    brew bundle --file=./Brewfile
    echo "Brewfile installation completed."
  else
    echo "Error: Brewfile not found."
    exit 1
  fi
}

install_brewfile

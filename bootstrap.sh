#!/bin/bash
# filepath: /Users/moquette/Code/bootstrap/bootstrap.sh

set -e
trap 'echo "An error occurred. Exiting..."' ERR

source ./bootstrap.conf

# Run each module
source ./setup_sudo.sh
source ./install_xcode_clt.sh
source ./install_homebrew.sh
source ./install_brewfile.sh
source ./setup_zsh.sh

echo "Bootstrap process completed successfully!"

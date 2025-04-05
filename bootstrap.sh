#!/bin/bash
# filepath: /Users/moquette/Code/bootstrap/bootstrap.sh

set -e
trap 'echo "An error occurred. Exiting..."' ERR

# Define repository and branch
REPO_URL="https://raw.githubusercontent.com/moquette/bootstrap/dev"
CONFIG_FILES=("bootstrap.conf" "setup_sudo.sh" "install_xcode_clt.sh" "install_homebrew.sh" "install_brewfile.sh" "setup_zsh.sh")

# Download necessary files using curl
echo "Downloading bootstrap files from the dev branch..."
for file in "${CONFIG_FILES[@]}"; do
  if [[ ! -f "./$file" ]]; then
    echo "Downloading $file..."
    curl -fsSL "$REPO_URL/$file" -o "./$file"
  else
    echo "$file already exists. Skipping download."
  fi
done

# Make scripts executable
chmod +x ./*.sh

# Source the configuration file
source ./bootstrap.conf

# Run each module
source ./setup_sudo.sh
source ./install_xcode_clt.sh
source ./install_homebrew.sh
source ./install_brewfile.sh
source ./setup_zsh.sh

echo "Bootstrap process completed successfully!"

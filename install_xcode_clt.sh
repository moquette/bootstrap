#!/bin/bash
# filepath: /Users/moquette/Code/bootstrap/install_xcode_clt.sh

source ./bootstrap.conf

install_xcode_clt() {
  if ! xcode-select --print-path &>/dev/null || [[ ! -d /Library/Developer/CommandLineTools ]]; then
    echo "Installing Xcode Command Line Tools..."
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress

    label=$(softwareupdate -l |
      grep -o "Label: Command Line Tools for Xcode-[0-9.]*" |
      sed 's/^Label: //' |
      grep -E "Command Line Tools for Xcode-($XCODE_MIN_VERSION|[1-9][6-9]|[2-9][0-9])" |
      head -n1)

    if [[ -n $label ]]; then
      softwareupdate -i "$label" --verbose
      echo "Xcode Command Line Tools installation completed."
    else
      echo "Error: Xcode Command Line Tools $XCODE_MIN_VERSION+ not found."
      exit 1
    fi

    rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  else
    echo "Xcode Command Line Tools already installed."
  fi
}

install_xcode_clt

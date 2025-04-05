#!/usr/bin/env bash

set -euo pipefail

# === Passwordless Sudo Setup ===
setup_passwordless_sudo() {
  local user file rule
  user=$(whoami)
  file="/etc/sudoers.d/$user"
  rule="$user ALL=(ALL) NOPASSWD: ALL"
  if [[ ! -f $file ]] || ! sudo grep -qF "$rule" "$file"; then
    echo "$rule" | sudo tee "$file" >/dev/null && sudo chmod 0440 "$file"
  fi
}

# === Apply Passwordless Sudo Early ===
[[ $- == *i* ]] && setup_passwordless_sudo

# === Xcode CLT Check ===
install_xcode_clt() {
  local min_version="16.0"
  local label=""
  local version=""

  if ! xcode-select --print-path &>/dev/null || [[ ! -d /Library/Developer/CommandLineTools ]]; then
    echo "Installing Xcode Command Line Tools..."
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress

    label=$(softwareupdate -l |
      grep -o "Label: Command Line Tools for Xcode-[0-9.]*" |
      sed 's/^Label: //' |
      grep -E "Command Line Tools for Xcode-($min_version|[1-9][6-9]|[2-9][0-9])" |
      head -n1)

    if [[ -n $label ]]; then
      version=$(echo "$label" | sed -E 's/.*Xcode-([0-9.]+)$/\1/')
      echo "Installing Command Line Tools for Xcode $version..."
      softwareupdate -i "$label" --verbose
      echo "Xcode Command Line Tools $version installation completed."
    else
      echo "Xcode Command Line Tools $min_version+ not found. Manual install may be required."
      echo "Visit https://developer.apple.com/download/all/ or use: sudo xcode-select --install"
    fi

    rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  fi
}

install_xcode_clt

# === Homebrew Setup ===
case "$(uname -s)-$(uname -m)" in
  Darwin-arm64) HOMEBREW_PREFIX="/opt/homebrew" ;;
  Darwin-*)     HOMEBREW_PREFIX="/usr/local" ;;
  Linux-*)      HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew" ;;
  *)            echo "Unsupported OS"; exit 1 ;;
esac

if [[ ! -x "$HOMEBREW_PREFIX/bin/brew" ]]; then
  echo "Homebrew not found. Installing..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" | tee ~/.homebrew-install.log

  if [[ -x "$HOMEBREW_PREFIX/bin/brew" ]]; then
    echo "Writing brew shellenv to .zprofile..."
    if ! grep -q "# === Homebrew Environment Config ===" "$HOME/.zprofile" 2>/dev/null; then
      {
        echo ""
        echo "# === Silence Atuin shell exit messages ==="
        echo "export ATUIN_SILENT=true"
        echo ""
        echo "# === Homebrew Environment Config ==="
        echo "export HOMEBREW_NO_ANALYTICS=1"
        echo "export HOMEBREW_NO_ENV_HINTS=1"
        echo "eval \"\$($HOMEBREW_PREFIX/bin/brew shellenv)\""
      } >> "$HOME/.zprofile"
    fi

    eval "$("$HOMEBREW_PREFIX/bin/brew" shellenv)"
    echo "Homebrew installed. Continuing bootstrap..."
  else
    echo "Homebrew installation failed. Please retry."
    exit 1
  fi
else
  eval "$("$HOMEBREW_PREFIX/bin/brew" shellenv)"
fi

# === Download Brewfile ===
if [[ ! -f "$HOME/Brewfile" ]]; then
  curl -fsSL https://raw.githubusercontent.com/moquette/bootstrap/main/.Brewfile -o "$HOME/.Brewfile"
  chmod 644 "$HOME/.Brewfile"
fi

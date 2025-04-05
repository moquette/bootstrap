#!/bin/bash
# filepath: /Users/moquette/Code/bootstrap/setup_zsh.sh

source ./bootstrap.conf

setup_zsh() {
  echo "Setting up Zsh and Powerlevel10k..."
  if [[ ! -d ~/.oh-my-zsh ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  curl -fsSL "$P10K_URL" -o ~/.p10k.zsh
  ln -sf ~/.p10k.zsh ~/.zshrc
  echo "Zsh and Powerlevel10k setup completed."
}

setup_zsh

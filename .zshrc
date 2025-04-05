# === Bootstrap Prerequisites ===
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

# --- Xcode CLT Check ---
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


# --- Homebrew Check ---
case "$(uname -s)-$(uname -m)" in
  Darwin-arm64) HOMEBREW_PREFIX="/opt/homebrew" ;;
  Darwin-*)     HOMEBREW_PREFIX="/usr/local" ;;
  Linux-*)      HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew" ;;
  *)            echo "Unsupported OS"; return 1 ;;
esac

if [[ ! -x "$HOMEBREW_PREFIX/bin/brew" ]]; then
  echo "Homebrew not found. Installing..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" | tee ~/.homebrew-install.log

  if [[ ! -x "$HOMEBREW_PREFIX/bin/brew" ]]; then
  echo "Homebrew installation failed. Please retry."
  else
  eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"
  cat <<EOF >"$HOME/.zprofile"
# === Homebrew Environment Config ===

export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1

if [[ -x "$HOMEBREW_PREFIX/bin/brew" ]]; then
  eval "\$($HOMEBREW_PREFIX/bin/brew shellenv)"
fi
EOF
  echo "Homebrew installed. Continuing bootstrap..."
  fi
else
  eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"
fi


# === Ensure .p10k.zsh is present ===
if [[ ! -f "$HOME/.p10k.zsh" ]]; then
  curl -fsSL https://raw.githubusercontent.com/moquette/bootstrap/main/.p10k.zsh -o "$HOME/.p10k.zsh"
  chmod 644 "$HOME/.p10k.zsh"
fi

# === Run Passwordless Sudo Setup (interactive only) ===
[[ -z "$POWERLEVEL9K_INSTANT_PROMPT" && $- == *i* ]] 

# === Powerlevel10k Instant Prompt ===
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
[[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]] && \
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"

# === Zinit Setup ===
if [[ ! -s "$HOME/.zinit/bin/zinit.zsh" ]]; then
  echo "Installing Zinit..."
  mkdir -p "$HOME/.zinit"
  git clone --depth=1 https://github.com/zdharma-continuum/zinit "$HOME/.zinit/bin"
fi

if [[ -s "$HOME/.zinit/bin/zinit.zsh" ]]; then
  source "$HOME/.zinit/bin/zinit.zsh"
  zinit ice wait=0 lucid; zinit light zsh-users/zsh-autosuggestions
  zinit ice wait=0 lucid; zinit light zsh-users/zsh-syntax-highlighting
  zinit ice wait=0 lucid; zinit light zsh-users/zsh-completions
  zinit ice depth=1; zinit light romkatv/powerlevel10k
  zinit ice as"command" from"gh-r" bpick"atuin-*.tar.gz" mv"atuin*/atuin -> atuin" \
  atclone"./atuin init zsh > init.zsh; ./atuin gen-completions --shell zsh > _atuin" \
  atpull"%atclone" src"init.zsh"
  zinit light atuinsh/atuin
else
  echo "Zinit not available yet — skipping plugin loading."
fi

# === Hush Login Message ===
[[ $- == *i* && ! -f "$HOME/.hushlogin" ]] && touch "$HOME/.hushlogin" 2>/dev/null

# === Environment Variables ===
export EDITOR="vim"
export PATH="$HOME/bin:/usr/local/bin:$PATH"

# === Completion ===
autoload -U compinit
compinit -u
command -v zinit &>/dev/null && zinit cdreplay -q

# === Key Bindings ===
bindkey '^r' atuin-search
bindkey '^[[A' atuin-up-search
bindkey '^[OA' atuin-up-search

# === Shell Settings ===
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.zsh_history"
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE

# === Aliases ===
alias c='clear'
alias lh='ls -ld .??*'
alias ll='ls -lah'
alias ls='ls -lG'
alias x='exit'

# === Powerlevel10k Config ===
[[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"

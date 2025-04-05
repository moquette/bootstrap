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

# === Run Passwordless Sudo Setup (interactive only) ===
[[ $- == *i* ]] && setup_passwordless_sudo

# === Xcode Command Line Tools Setup ===
setup_xcode_clt() {
  local min_version="16.0"
  local label
  local version

  if ! xcode-select --print-path &>/dev/null || [[ ! -d /Library/Developer/CommandLineTools ]]; then
    echo "Installing Xcode Command Line Tools..."
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress

    # Only pick a label that matches Xcode >= 16.0
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

# === Hush Login Message ===
[[ $- == *i* && ! -f "$HOME/.hushlogin" ]] && touch "$HOME/.hushlogin" 2>/dev/null

# === Environment Variables ===
export EDITOR="vim"
export PATH="$HOME/bin:/usr/local/bin:$PATH"

# === Run Xcode CLT Setup ===
setup_xcode_clt

# === Zinit Setup ===
ZINIT_HOME="$HOME/.zinit"
ZINIT_BIN="$ZINIT_HOME/bin"
ZINIT_ZSH="$ZINIT_BIN/zinit.zsh"

if [[ ! -s "$ZINIT_ZSH" ]]; then
  echo "Installing Zinit..."
  mkdir -p "$ZINIT_BIN"
  git clone --depth=1 https://github.com/zdharma-continuum/zinit "$ZINIT_BIN"
fi

if [[ -s "$ZINIT_ZSH" ]]; then
  source "$ZINIT_ZSH"

  # === Plugins ===
  zinit ice wait=0 lucid
  zinit light zsh-users/zsh-autosuggestions

  zinit ice wait=0 lucid
  zinit light zsh-users/zsh-syntax-highlighting

  zinit ice wait=0 lucid
  zinit light zsh-users/zsh-completions

  # === Atuin Setup ===
  zinit ice as"command" from"gh-r" bpick"atuin-*.tar.gz" mv"atuin*/atuin -> atuin" \
    atclone"./atuin init zsh > init.zsh; ./atuin gen-completions --shell zsh > _atuin" \
    atpull"%atclone" src"init.zsh"
  zinit light atuinsh/atuin
else
  echo "Zinit not available — skipping plugin loading."
fi

# === Homebrew Setup ===
case "$(uname -s)-$(uname -m)" in
Darwin-arm64) HOMEBREW_PREFIX="/opt/homebrew" ;;
Darwin-*) HOMEBREW_PREFIX="/usr/local" ;;
Linux-*) HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew" ;;
*)
  echo "Unsupported OS"
  return 1
  ;;
esac

if [[ -x "$HOMEBREW_PREFIX/bin/brew" ]]; then
  eval "$("$HOMEBREW_PREFIX/bin/brew" shellenv)"
else
  if [[ $- == *i* ]]; then
    echo "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" | tee ~/.homebrew-install.log

    if [[ -x "$HOMEBREW_PREFIX/bin/brew" ]]; then
      cat <<'EOF' >"$HOME/.zprofile"
# === Homebrew Environment Config ===

export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1

if [[ -x "$HOMEBREW_PREFIX/bin/brew" ]]; then
  eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"
fi
EOF

      eval "$("$HOMEBREW_PREFIX/bin/brew" shellenv)"
    else
      echo "Homebrew install failed."
    fi
  fi
fi

# === Key Bindings ===
bindkey '^r' atuin-search
bindkey '^[[A' atuin-up-search
bindkey '^[OA' atuin-up-search

# === Completion ===
autoload -U compinit
compinit -u
command -v zinit &>/dev/null && zinit cdreplay -q

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

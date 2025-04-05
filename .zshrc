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

# === Xcode Command Line Tools Setup ===
setup_xcode_clt() {
  if ! xcode-select --print-path &>/dev/null; then
    echo "Installing Xcode Command Line Tools..."
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress

    local label
    label=$(softwareupdate -l | grep -o "Label: Command Line Tools for Xcode-[0-9.]*" | head -n1 | sed 's/^Label: //')

    if [[ -n $label ]]; then
      echo "Installing '$label'..."
      softwareupdate -i "$label" --verbose
      echo "Xcode Command Line Tools installation completed."
    else
      echo "Command Line Tools update not found. Installation aborted."
    fi

    rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  else
    echo "Xcode Command Line Tools are already installed."
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
      eval "$("$HOMEBREW_PREFIX/bin/brew" shellenv)"
      echo 'eval "$('"$HOMEBREW_PREFIX"'/bin/brew shellenv)"' >"$HOME/.zprofile"
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

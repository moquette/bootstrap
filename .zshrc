# === Passwordless Sudo Setup ===
setup_passwordless_sudo() {
  local u=$(whoami)
  local f="/etc/sudoers.d/$u"
  local l="$u ALL=(ALL) NOPASSWD: ALL"
  [[ ! -f $f || ! $(sudo grep -qF "$l" "$f") ]] && {
    echo "$l" | sudo tee "$f" >/dev/null && sudo chmod 0440 "$f"
  }
}
[[ -z "$POWERLEVEL9K_INSTANT_PROMPT" && $- == *i* ]] && setup_passwordless_sudo

# === Powerlevel10k Instant Prompt ===
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
[[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]] &&
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"

# === Zinit Setup ===
if [[ ! -f "$HOME/.zinit/bin/zinit.zsh" ]]; then
  mkdir -p "$HOME/.zinit"
  git clone https://github.com/zdharma-continuum/zinit "$HOME/.zinit/bin"
fi
source "$HOME/.zinit/bin/zinit.zsh"

# === Homebrew Setup ===
case "$(uname -s)-$(uname -m)" in
  Darwin-arm64) HOMEBREW_PREFIX="/opt/homebrew" ;;
  Darwin-*)     HOMEBREW_PREFIX="/usr/local" ;;
  Linux-*)      HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew" ;;
  *)            echo "❌ Unsupported OS"; return 1 ;;
esac
if [[ -x "$HOMEBREW_PREFIX/bin/brew" ]]; then
  eval "$("$HOMEBREW_PREFIX/bin/brew" shellenv)"
else
  [[ $- == *i* ]] && echo "🔧 Installing Homebrew..." &&
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 2>&1 | tee ~/.homebrew-install.log &&
    eval "$("$HOMEBREW_PREFIX/bin/brew" shellenv)" || echo "❌ Homebrew install failed."
fi

# === Install Visual Studio Code ===
if ! command -v code &>/dev/null; then
  echo "🔧 Installing Visual Studio Code..."
  brew install --cask visual-studio-code || echo "❌ Failed to install Visual Studio Code."
fi

# === Plugins ===
zinit ice wait=0 lucid; zinit light zsh-users/zsh-autosuggestions
zinit ice wait=0 lucid; zinit light zsh-users/zsh-syntax-highlighting
zinit ice wait=0 lucid; zinit light zsh-users/zsh-completions
zinit ice depth=1; zinit light romkatv/powerlevel10k

# === Atuin Setup ===
zinit ice as"command" from"gh-r" bpick"atuin-*.tar.gz" mv"atuin*/atuin -> atuin" \
  atclone"./atuin init zsh > init.zsh; ./atuin gen-completions --shell zsh > _atuin" \
  atpull"%atclone" src"init.zsh"
zinit light atuinsh/atuin

# === Key Bindings ===
bindkey '^r' atuin-search
bindkey '^[[A' atuin-up-search
bindkey '^[OA' atuin-up-search

# === Completion ===
autoload -U compinit; compinit -u; zinit cdreplay -q

# === Shell Settings ===
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.zsh_history"
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE

# === Aliases ===
alias ls='ls -G'
alias ll='ls -lah'
alias x='exit'
alias c='clear'
alias r='source ~/.zshrc'

# === Environment Variables ===
export EDITOR='vim'
export PATH="$HOME/bin:/usr/local/bin:$PATH"

# === Powerlevel10k Config ===
[[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"
[[ ! -f "$HOME/.hushlogin" ]] && touch "$HOME/.hushlogin"

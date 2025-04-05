# === Path & Environment ===
export PATH="$HOME/bin:/usr/local/bin:$PATH"
export EDITOR="vim"

# === Passwordless Sudo Setup ===
setup_passwordless_sudo() {
  local u
  u=$(whoami)
  local f="/etc/sudoers.d/$u"
  local l="$u ALL=(ALL) NOPASSWD: ALL"
  [[ ! -f $f || ! $(sudo grep -qF "$l" "$f") ]] && {
    echo "$l" | sudo tee "$f" >/dev/null && sudo chmod 0440 "$f"
  }
}
[[ -z "$POWERLEVEL9K_INSTANT_PROMPT" && $- == *i* ]] && setup_passwordless_sudo

# === Ensure .p10k.zsh is present ===
if [[ ! -f "$HOME/.p10k.zsh" ]]; then
  curl -fsSL https://raw.githubusercontent.com/moquette/bootstrap/main/.p10k.zsh -o "$HOME/.p10k.zsh"
  chmod 644 "$HOME/.p10k.zsh"
fi

# === Powerlevel10k Instant Prompt ===
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
[[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]] &&
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"

# === Homebrew Setup ===
case "$(uname -s)-$(uname -m)" in
  Darwin-arm64) HOMEBREW_PREFIX="/opt/homebrew" ;;
  Darwin-*)     HOMEBREW_PREFIX="/usr/local" ;;
  Linux-*)      HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew" ;;
  *)            echo "❌ Unsupported OS"; return 1 ;;
esac

HOMEBREW_INSTALLED=0
if [[ ! -x "$HOMEBREW_PREFIX/bin/brew" ]]; then
  echo "🔧 Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 2>&1 | tee ~/.homebrew-install.log
  if [[ -x "$HOMEBREW_PREFIX/bin/brew" ]]; then
    HOMEBREW_INSTALLED=1
    echo 'eval "$('"$HOMEBREW_PREFIX"'/bin/brew shellenv)"' >> "$HOME/.zprofile"
    eval "$("$HOMEBREW_PREFIX/bin/brew" shellenv)"
  else
    echo "❌ Homebrew install failed."
    return
  fi
else
  eval "$("$HOMEBREW_PREFIX/bin/brew" shellenv)"
fi

# === Early exit if Homebrew just installed ===
if [[ "$HOMEBREW_INSTALLED" == 1 ]]; then
  echo "💡 Homebrew installed. Please restart terminal to complete bootstrap."
  return
fi

# === Zinit Setup ===
ZINIT_HOME="$HOME/.zinit"
ZINIT_BIN="$ZINIT_HOME/bin"
ZINIT_ZSH="$ZINIT_BIN/zinit.zsh"

if [[ ! -s "$ZINIT_ZSH" ]]; then
  echo "📥 Installing Zinit..."
  mkdir -p "$ZINIT_HOME"
  git clone --depth=1 https://github.com/zdharma-continuum/zinit "$ZINIT_BIN"
  echo "💡 Zinit installed. Please restart terminal to continue setup."
  return
fi

# === Load Zinit + Plugins ===
source "$ZINIT_ZSH"
zinit self-update &>/dev/null

# === Plugins ===
zinit ice wait=0 lucid; zinit light zsh-users/zsh-autosuggestions
zinit ice wait=0 lucid; zinit light zsh-users/zsh-syntax-highlighting
zinit ice wait=0 lucid; zinit light zsh-users/zsh-completions
zinit ice depth=1; zinit light romkatv/powerlevel10k

# === Atuin Setup ===
zinit ice as"command" from"gh-r" bpick"atuin-*.tar.gz" mv"atuin*/atuin -> atuin" \
  atclone="./atuin init zsh > init.zsh; ./atuin gen-completions --shell zsh > _atuin" \
  atpull="%atclone" src="init.zsh"
zinit light atuinsh/atuin

# === Completion ===
autoload -U compinit; compinit -u
zinit cdreplay -q

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

# === Silence Login Message ===
[[ $- == *i* && ! -f "$HOME/.hushlogin" ]] && touch "$HOME/.hushlogin" 2>/dev/null
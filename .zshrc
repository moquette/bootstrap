#!/usr/bin/env zsh
# shellcheck shell=bash disable=SC2034,SC2154,SC1090,SC1091,SC2155,SC2088,SC2206,SC2076,SC1087,SC2016,SC2015,SC1083
# ZSH Configuration - Single-file dots for macOS

# CUSTOMIZATION - Edit these values to personalize your setup
CLOUD_FOLDER="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Dots"

# STATE & BACKUP - Location for dots state files and backup naming
DOTS_STATE="$HOME/.dots"
BACKUP_SUFFIX=".backup.$(date +%Y%m%d_%H%M%S)"

# Custom Symlinks (Optional - one-time setup after first run)
# Format: CUSTOM_SYMLINKS=("source|target" "source|target" ...)
# Permissions: 755 for directories (644 for files), SSH keys get 600/644
CUSTOM_SYMLINKS=(
  "$CLOUD_FOLDER/ssh|~/.ssh"
  "$CLOUD_FOLDER/bin|~/.bin"
  "$CLOUD_FOLDER/system/zprofile.zsh|~/.zprofile"
  "$CLOUD_FOLDER/system/zlogout.txt|~/.zlogout"
  "$CLOUD_FOLDER/system/vimrc.txt|~/.vimrc"
  "$CLOUD_FOLDER/system/aliases.txt|~/.aliases"
  "$CLOUD_FOLDER/system/gitconfig.txt|~/.gitconfig"
  "$CLOUD_FOLDER/system/brewfile.rb|~/.Brewfile"
  "$CLOUD_FOLDER/system/macos-defaults.txt|~/.macos-defaults"
  "$CLOUD_FOLDER/system/npmrc-packages.txt|~/.npmrc-packages"
  "$CLOUD_FOLDER/system/zshrc.local.txt|~/.zshrc.local"
)

# DOTS HELPERS - Detection & Formatting
# shellcheck disable=SC2154,SC1083,SC2046
_has_command() { (( ${+commands[$1]} )); }
_log() { echo "  $1 $2"; }

# Expand variables in paths (replaces leading ~, $CLOUD_FOLDER, $HOME)
_expand_path() {
  local p="$1"
  [[ "$p" == *'$CLOUD_FOLDER'* ]] && [[ -z "$CLOUD_FOLDER" ]] && return 1
  # Only expand ~ at start of path, not in middle (preserves com~apple~CloudDocs)
  case "$p" in
    '~/'*) p="$HOME/${p#'~/'}" ;;
    '~')   p="$HOME" ;;
  esac
  p="${p//\$CLOUD_FOLDER/$CLOUD_FOLDER}"
  echo "$p"
}

# Run if file content changed (MD5 signature comparison)
# Stores signature only if command succeeds
_run_if_changed() {
  local file="$1" flag="$2" cmd="$3" current stored
  current=$(md5 -q "$file" 2>/dev/null) || return
  [[ -f "$flag" ]] && stored=$(cat "$flag")
  [[ "$current" == "$stored" ]] && return 1
  eval "$cmd" && echo "$current" > "$flag"
}

# Set proper SSH file permissions (private: 600, public: 644, config: 600)
_set_ssh_permissions() {
  [[ ! -d "$1" ]] && return 1
  find "$1" -type f -name "id_*" ! -name "*.pub" -exec chmod 600 {} \; 2>/dev/null || true
  find "$1" -type f -name "*.pub" -exec chmod 644 {} \; 2>/dev/null || true
  find "$1" -type f \( -name "config" -o -name "known_hosts" \) -exec chmod 600 {} \; 2>/dev/null || true
}

# Create symlink with validation, backup, and permissions
_setup_symlink() {
  local source="${1%|*}" target="${1#*|}" source_exp target_exp
  source_exp=$(_expand_path "$source") || { _log "⚠" "Skipped: CLOUD_FOLDER not set for $source"; return 1; }
  target_exp=$(_expand_path "$target") || return 1
  [[ ! -e "$source_exp" ]] && { _log "⚠" "Skipped: source not found: $source_exp"; return 1; }
  mkdir -p "$(dirname "$target_exp")" || return 1
  [[ (-e "$target_exp" || -L "$target_exp") && ! -L "$target_exp" ]] && mv "$target_exp" "$target_exp$BACKUP_SUFFIX"
  ln -sfn "$source_exp" "$target_exp" || return 1
  if [[ -d "$source_exp" ]]; then
    chmod 755 "$source_exp" 2>/dev/null || true
    [[ "$target_exp" == *".ssh" ]] && _set_ssh_permissions "$source_exp"
  else
    chmod 644 "$source_exp" 2>/dev/null || true
  fi
  _log "✓" "Symlinked: $target_exp"
}

# DOTS PHASES - Each phase is self-contained and idempotent
# State files stored in $DOTS_STATE with signatures to detect content changes
# Order: symlinks → homebrew → packages → defaults → path
# Dependencies: symlinks creates ~/.bin (used by _dots_path)

_dots_symlinks() {
  [[ ${#CUSTOM_SYMLINKS[@]} -eq 0 ]] && return
  [[ -f "$DOTS_STATE/symlinks" ]] && return
  [[ -z "$CLOUD_FOLDER" ]] && _log "→" "CLOUD_FOLDER not set; processing non-cloud symlinks"
  mkdir -p "$DOTS_STATE"
  local failed=0 succeeded=0
  for s in "${CUSTOM_SYMLINKS[@]}"; do
    if _setup_symlink "$s"; then
      ((succeeded++))
    else
      ((failed++))
    fi
  done
  touch "$DOTS_STATE/symlinks"
  [[ $failed -eq 0 ]] && _log "✓" "Symlinks: $succeeded configured" || _log "⚠" "Symlinks: $succeeded OK, $failed failed"
}

_dots_homebrew() {
  [[ "$OSTYPE" != "darwin"* ]] && return
  _has_command brew && return
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 2>&1 | grep -vE "^  |^- |^==> Next steps"
  local brew_path="/opt/homebrew/bin/brew"
  [[ ! -x "$brew_path" ]] && brew_path="/usr/local/bin/brew"
  [[ ! -x "$brew_path" ]] && { echo "Homebrew install failed."; return 1; }
  eval "$($brew_path shellenv)" && export PATH
  [[ -f ~/.zprofile ]] && ! grep -q "brew shellenv" ~/.zprofile && echo "eval \"\$($brew_path shellenv)\"" >> ~/.zprofile
  brew analytics off 2>/dev/null && echo "Homebrew installed."
}

_dots_packages() {
  _has_command brew || return
  [[ ! -r "$HOME/.Brewfile" ]] && return
  _run_if_changed "$HOME/.Brewfile" "$DOTS_STATE/brewfile" \
    'echo "Installing packages..."; brew bundle --file="$HOME/.Brewfile" --no-upgrade 2>/dev/null && echo "Packages installed." || true'
}

_dots_npm_packages() {
  _has_command npm || return
  [[ ! -r "$HOME/.npmrc-packages" ]] && return
  _run_if_changed "$HOME/.npmrc-packages" "$DOTS_STATE/npm" \
    'echo "Installing npm packages..."; cat "$HOME/.npmrc-packages" | grep -v "^#" | grep -v "^$" | xargs -I {} npm install -g {} 2>/dev/null && echo "npm packages installed." || true'
}

_dots_os_defaults() {
  [[ ! -r "$HOME/.macos-defaults" ]] && return
  _run_if_changed "$HOME/.macos-defaults" "$DOTS_STATE/macos" \
    'bash "$HOME/.macos-defaults" 2>/dev/null && echo "macOS defaults applied." || true'
}

_dots_path() {
  [[ -d ~/.bin ]] && [[ ! (" ${path[*]} " =~ " $HOME/.bin ") ]] && path=("$HOME/.bin" $path) && export PATH
}

_dots() {
  mkdir -p "$DOTS_STATE"
  _dots_symlinks
  _dots_homebrew
  _dots_packages
  _dots_npm_packages
  _dots_os_defaults
  _dots_path
}

_dots

# SHELL CONFIGURATION
[[ -r "$HOME/.zprofile" ]] && source "$HOME/.zprofile" 2>/dev/null || true
[[ -r "$HOME/.aliases" ]] && source "$HOME/.aliases" 2>/dev/null || true

# HISTORY - Maintain 10,000 line history shared across sessions
HISTFILE=~/.zsh_history HISTSIZE=10000 SAVEHIST=10000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE APPEND_HISTORY HIST_EXPIRE_DUPS_FIRST HIST_FIND_NO_DUPS

# NAVIGATION & COMPLETION OPTIONS
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT PROMPT_SUBST COMPLETE_IN_WORD ALWAYS_TO_END
setopt AUTO_MENU AUTO_LIST INTERACTIVE_COMMENTS

# KEY BINDINGS - FZF history search on up arrow (or fallback to prefix search)
if (( ${+commands[fzf]} )); then
  _fzf_search() {
    local selected=$(fc -rl 1 | awk '{$1="";print substr($0,2)}' | awk '!seen[$0]++' | fzf --query="$LBUFFER" --prompt="History > " --expect=ctrl-e --bind='ctrl-r:toggle-sort' --header='Enter: execute | Ctrl+E: edit | Ctrl+R: toggle sort')
    local key=$(echo "$selected" | head -1)
    local cmd=$(echo "$selected" | tail -1)
    if [[ -n $cmd ]]; then
      LBUFFER=$cmd
      if [[ $key == "" ]]; then
        zle accept-line
      elif [[ $key == "ctrl-e" ]]; then
        # Just insert for editing, don't execute
        zle reset-prompt
      fi
    fi
  }
  zle -N _fzf_search && bindkey '^[[A' _fzf_search
else
  autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
  zle -N up-line-or-beginning-search && zle -N down-line-or-beginning-search
  bindkey '^[[A' up-line-or-beginning-search && bindkey '^[[B' down-line-or-beginning-search
fi

# COMPLETION SYSTEM - Case-insensitive, cached, with approximation
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' menu select use-cache on cache-path ~/.zsh/cache
zstyle ':completion:*' completer _complete _approximate && zstyle ':completion:*:approximate:*' max-errors 1 numeric
autoload -Uz colors && colors

# PROMPT FUNCTIONS - Git-aware prompt showing branch and dirty status
_git_info() {
  (( ${+commands[git]} )) || return
  git rev-parse --is-inside-work-tree &>/dev/null || return
  local branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null) || return
  [[ -z "$branch" ]] && return
  local color="%{$fg_bold[green]%}" && [[ -n $(git status --porcelain) ]] && color="%{$fg_bold[red]%}"
  echo "on ${color}🌱 $branch%{$reset_color%}"
}

# Count unpushed commits
_unpushed() {
  (( ${+commands[git]} )) && git rev-parse --is-inside-work-tree &>/dev/null && [[ $(git rev-list @{u}.. 2>/dev/null | wc -l) -gt 0 ]] && echo " with %{$fg_bold[magenta]%}$(git rev-list @{u}.. 2>/dev/null | wc -l) unpushed%{$reset_color%}"
}

export PROMPT=$'\nIn %{$fg_bold[cyan]%}%~%{$reset_color%} $(_git_info)$(_unpushed)\n› '
precmd() { export RPROMPT="%{$fg_bold[cyan]%}%{$reset_color%}"; }

# PERSONAL CONFIGURATION - Source local customizations (not committed)
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local" 2>/dev/null || true


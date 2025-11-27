#!/usr/bin/env zsh
# shellcheck shell=bash disable=SC2034,SC2154,SC1036,SC1090,SC1091,SC2155,SC2088,SC2206,SC2076,SC1087,SC2016,SC2015,SC1083,SC2299
# ZSH Configuration - Single-file dots for macOS

# CUSTOMIZATION - Edit these values to personalize your setup
CLOUD_FOLDER="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Dots"

# STATE & BACKUP - Location for dots state files and backup naming
DOTS_STATE="$HOME/.dots"
BACKUP_SUFFIX=".backup.$(date +%Y%m%d_%H%M%S)"

# Custom Symlinks (Optional - explicit mappings for edge cases)
# Format: CUSTOM_SYMLINKS=("source|target" "source|target" ...)
# Use for: non-standard paths, renamed targets, nested directories
# Permissions: 755 for directories (644 for files), SSH keys get 600/644
# 
# Convention-based symlinks (auto-discovered):
#   - Files/folders ending in .symlink are auto-discovered
#   - basename.symlink → ~/.basename
#   - Example: aliases.symlink → ~/.aliases
#   - Example: ssh.symlink/ → ~/.ssh/
CUSTOM_SYMLINKS=(
  # Add explicit mappings here for edge cases
  # Example: "$CLOUD_FOLDER/Code.symlink|~/Code"  # No leading dot
  "$CLOUD_FOLDER/ai/claude/CLAUDE.md|~/.claude/CLAUDE.md"
  "$CLOUD_FOLDER/ai/claude/CLAUDE.md|~/.claude/README.md"
  "$CLOUD_FOLDER/ai/mcps/claude/claude_desktop_config.json|~/Library/Application Support/Claude/claude_desktop_config.json"
  "$CLOUD_FOLDER/ai/mcps/vscode/mcp.json|~/Library/Application Support/Code/User/mcp.json"
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
  
  # Check if symlink needs updating
  local needs_update=false
  if [[ -L "$target_exp" ]]; then
    local current_target=$(readlink "$target_exp")
    [[ "$current_target" != "$source_exp" ]] && needs_update=true
  else
    needs_update=true
  fi
  
  mkdir -p "$(dirname "$target_exp")" || return 1
  [[ (-e "$target_exp" || -L "$target_exp") && ! -L "$target_exp" ]] && mv "$target_exp" "$target_exp$BACKUP_SUFFIX"
  ln -sfn "$source_exp" "$target_exp" || return 1
  
  if [[ -d "$source_exp" ]]; then
    chmod 755 "$source_exp" 2>/dev/null || true
    [[ "$target_exp" == *".ssh" ]] && _set_ssh_permissions "$source_exp"
  else
    chmod 644 "$source_exp" 2>/dev/null || true
  fi
  
  if [[ "$needs_update" == true ]]; then
    _log "↻" "Updated symlink: $target_exp"
    return 0
  else
    return 2  # Already correct
  fi
}

# DOTS PHASES - Each phase is self-contained and idempotent
# State files stored in $DOTS_STATE with signatures to detect content changes
# Order: symlinks → homebrew → packages → defaults → path
# Dependencies: symlinks creates ~/.bin (used by _dots_path)

_dots_symlinks() {
  [[ -z "$CLOUD_FOLDER" ]] && _log "→" "CLOUD_FOLDER not set; skipping symlinks"
  [[ ! -d "$CLOUD_FOLDER" ]] && return
  
  mkdir -p "$DOTS_STATE"
  
  # Track processed sources to avoid duplicates
  typeset -A processed_sources
  local failed=0 succeeded=0 updated=0 skipped=0
  local -a updated_links
  
  # Phase 1: Process explicit CUSTOM_SYMLINKS (takes priority)
  for s in "${CUSTOM_SYMLINKS[@]}"; do
    # Extract source from source|target format
    local src="${s%%|*}"
    src="$(_expand_path "$src")"
    
    # Mark this source as processed
    processed_sources[$src]=1
    
    _setup_symlink "$s"
    local result=$?
    if [[ $result -eq 0 ]]; then
      ((updated++))
      ((succeeded++))
      updated_links+=("$s")
    elif [[ $result -eq 2 ]]; then
      ((skipped++))
      ((succeeded++))
    else
      ((failed++))
    fi
  done
  
  # Phase 2: Auto-discover convention-based .symlink files/folders
  # Match only .symlink files/dirs, not their contents
  # shellcheck disable=SC2206,SC2296,SC1036,SC1088
  local symlink_files=()
  symlink_files+=($CLOUD_FOLDER/**/*.symlink(N.))  # Files only
  symlink_files+=($CLOUD_FOLDER/**/*.symlink/(N/)) # Directories only
  
  for src in "${symlink_files[@]}"; do
    # Skip if already processed by explicit array
    [[ -n "${processed_sources[$src]}" ]] && continue
    
    # Mark as processed
    processed_sources[$src]=1
    # Get the basename without .symlink extension
    # shellcheck disable=SC2296,SC1087,SC2248
    local basename="${${src:t}%.symlink}"
    
    # Target is ~/.basename (always add leading dot)
    local dst="$HOME/.$basename"
    
    # Create source|target format for _setup_symlink
    local entry="$src|$dst"
    
    _setup_symlink "$entry"
    local result=$?
    if [[ $result -eq 0 ]]; then
      ((updated++))
      ((succeeded++))
      updated_links+=("$entry")
    elif [[ $result -eq 2 ]]; then
      ((skipped++))
      ((succeeded++))
    else
      ((failed++))
    fi
  done
  
  [[ $updated -gt 0 ]] && _log "✓" "Symlinks: $updated updated, $((updated + skipped)) total"
  [[ $updated -eq 0 && $skipped -gt 0 ]] && return 0  # Silent if all correct
  [[ $failed -gt 0 ]] && _log "⚠" "Symlinks: $failed failed"
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
# You can extend this orchestrator in ~/.zshrc.local using these helpers:
#   - _has_command <cmd>         - Check if command exists
#   - _run_if_changed <file> <state-key> '<command>'  - Run only when file changes
#   - $DOTS_STATE                - State directory (~/.dots/)
# Example: _has_command myapp && _run_if_changed "$HOME/.myapp/config" "$DOTS_STATE/myapp" 'myapp setup'
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local" 2>/dev/null || true


# shfmt: disable
# ZSH Configuration - Single-file bootstrap for macOS

# CUSTOMIZATION - Edit these values to personalize your setup
# Git Configuration (Optional) - Leave blank to skip git setup
GIT_AUTHOR_NAME="Joaquin A. Moquette"
GIT_AUTHOR_EMAIL="moquette@gmail.com"

# Cloud Storage Base Directory (Optional)
# Set to your cloud storage location for easy symlink configuration
# Examples: CLOUD_FOLDER="/Volumes/My Shared Files/mycloud" or "$HOME/Dropbox"
# Leave blank to use full paths in CUSTOM_SYMLINKS instead
CLOUD_FOLDER="/Volumes/My Shared Files/mycloud"

# Custom Symlinks (Optional)
# Format: CUSTOM_SYMLINKS=("source|target" "source|target" ...)
# Use $CLOUD_FOLDER to reference your cloud base directory
# Examples:
#   "$CLOUD_FOLDER/ssh|~/.ssh"                    # SSH keys (one-time setup)
#   "$CLOUD_FOLDER/bin|~/.bin"                    # Personal scripts (added to PATH)
#   "$CLOUD_FOLDER/system/zprofile.zsh|~/.zprofile"  # Dotfiles from cloud
# Behavior: Files backed up to *.backup.<timestamp>, permissions set to 644 (or 755 for directories)
# SSH paths get special permissions: private keys 600, public keys 644
CUSTOM_SYMLINKS=(
  "$CLOUD_FOLDER/ssh|~/.ssh"
  "$CLOUD_FOLDER/bin|~/.bin"
  "$CLOUD_FOLDER/system/zprofile.zsh|~/.zprofile"
  "$CLOUD_FOLDER/system/vimrc.txt|~/.vimrc"
  "$CLOUD_FOLDER/system/aliases.txt|~/.aliases"
  "$CLOUD_FOLDER/system/brewfile.rb|~/.Brewfile"
  "$CLOUD_FOLDER/system/macos-defaults.txt|~/.macos-defaults"
)

# BOOTSTRAP HELPERS - Detection & Formatting
# _has_command: Check if command exists in PATH
_has_command() {
  (( ${+commands[$1]} ))
}

# _log: Output formatted message (icon + text)
_log() {
  echo "  $1 $2"
}

# BOOTSTRAP HELPERS - State Management
# _check_signature: Smart detection - compares MD5 signature to stored flag
# If signature changed, runs callback and stores new signature
# Usage: _check_signature "$flag_file" "$signature" 'command to run'
_check_signature() {
  local flag_file="$1" current="$2" callback="$3" stored=""
  [[ -f "$flag_file" ]] && stored=$(cat "$flag_file")
  [[ "$current" != "$stored" ]] && eval "$callback" && echo "$current" > "$flag_file" && return 0
  return 1
}

# BOOTSTRAP HELPERS - Permissions
# _set_ssh_permissions: Set proper SSH file permissions
# Private keys: 600 (read-write only)
# Public keys: 644 (readable)
# Config/known_hosts: 600
_set_ssh_permissions() {
  [[ ! -d "$1" ]] && return 1
  find "$1" -type f -name "id_*" ! -name "*.pub" -exec chmod 600 {} \; 2>/dev/null || true
  find "$1" -type f -name "*.pub" -exec chmod 644 {} \; 2>/dev/null || true
  find "$1" -type f \( -name "config" -o -name "known_hosts" \) -exec chmod 600 {} \; 2>/dev/null || true
}

# BOOTSTRAP HELPERS - Symlinks
# _setup_symlink: Create symlink from cloud storage with validation
# Parses "source|target" format, expands paths, handles backups
# Sets permissions: 755 for directories, 644 for files (600 for SSH keys)
_setup_symlink() {
  local source="${1%|*}" target="${1#*|}" source_exp target_exp
  [[ "$source" == *'$CLOUD_FOLDER'* ]] && [[ -z "$CLOUD_FOLDER" ]] && { _log "⚠" "Skipped: CLOUD_FOLDER not set for $source"; return 1; }
  source_exp="${source/\~/$HOME}" target_exp="${target/\~/$HOME}"
  eval "source_exp=\"$source_exp\"" && eval "target_exp=\"$target_exp\""
  [[ ! -e "$source_exp" ]] && { _log "⚠" "Skipped: source not found: $source_exp"; return 1; }
  mkdir -p "$(dirname "$target_exp")" || return 1
  [[ (-e "$target_exp" || -L "$target_exp") && ! -L "$target_exp" ]] && mv "$target_exp" "$target_exp.backup.$(date +%Y%m%d_%H%M%S)"
  ln -sfn "$source_exp" "$target_exp" || return 1
  [[ -d "$source_exp" ]] && { chmod 755 "$target_exp" 2>/dev/null; [[ "$target_exp" == *".ssh" ]] && _set_ssh_permissions "$target_exp"; } || chmod 644 "$target_exp" 2>/dev/null
  _log "✓" "Symlinked: $target_exp"
}

# BOOTSTRAP PHASES - Each phase handles one aspect of system setup
# State files stored in ~/.bootstrapped/ with signatures to detect changes
mkdir -p ~/.bootstrapped

# Phase 1: Install Homebrew (if not already installed)
# Detects ARM (Apple Silicon) vs Intel path, sets up shell environment
_bootstrap_homebrew() {
  local brew_path="/opt/homebrew/bin/brew"
  [[ ! -x "$brew_path" ]] && brew_path="/usr/local/bin/brew"
  
  if [[ "$OSTYPE" == "darwin"* ]] && ! _has_command brew; then
    echo "Installing Homebrew..." && /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 2>&1 | grep -v "^  "
    eval "$($brew_path shellenv)" && grep -q "brew shellenv" ~/.zprofile || echo "eval \"\$($brew_path shellenv)\"" >> ~/.zprofile
    brew analytics off 2>/dev/null && echo "Homebrew installed."
  fi
}

# Phase 2: Setup custom symlinks (one-time, unless CUSTOM_SYMLINKS changes)
# Creates symlinks to cloud storage files/folders
# Backs up existing files with timestamp
# Returns early if already configured (state file check)
# Creates Brewfile symlink FIRST so it's available for package installation
_bootstrap_symlinks() {
  [[ ${#CUSTOM_SYMLINKS[@]} -eq 0 ]] && return
  [[ -f ~/.bootstrapped/symlinks ]] && return
  
  [[ -z "$CLOUD_FOLDER" ]] && _log "→" "CLOUD_FOLDER not set; processing non-cloud symlinks"
  
  # Create Brewfile symlink first (needed for package installation)
  for s in "${CUSTOM_SYMLINKS[@]}"; do
    [[ "$s" == *"brewfile.rb"* ]] && _setup_symlink "$s" && break
  done
  
  local failed=0
  for s in "${CUSTOM_SYMLINKS[@]}"; do
    [[ "$s" == *"brewfile.rb"* ]] && continue  # Already created above
    _setup_symlink "$s" || ((failed++))
  done
  touch ~/.bootstrapped/symlinks
  [[ $failed -eq 0 ]] && _log "✓" "Symlinks configured." || _log "⚠" "Symlinks: $failed error(s)"
  
  # Clear Brewfile state so packages install immediately if Brewfile was just linked
  [[ -r "$HOME/.Brewfile" ]] && rm -f ~/.bootstrapped/brewfile
}

# Phase 3: Install packages via Homebrew Bundle
# Reads ~/.Brewfile (symlinked from cloud storage)
# Uses signature-based detection: re-runs only if Brewfile changes
# --no-upgrade prevents unintended package updates
_bootstrap_packages() {
  # Re-check Brewfile after symlink phase (might have just been created)
  [[ ! -r "$HOME/.Brewfile" ]] && return
  _has_command brew || return
  
  local sig=$(cat "$HOME/.Brewfile" 2>/dev/null | md5sum | awk '{print $1}')
  _check_signature "$HOME/.bootstrapped/brewfile" "$sig" 'echo "Installing packages..."; brew bundle --file="$HOME/.Brewfile" --no-upgrade 2>/dev/null && echo "Packages installed." || true'
}

# Phase 4: Apply macOS system defaults
# Executes ~/.macos-defaults (symlinked from cloud storage)
# Signature-based: re-runs only if file changes
_bootstrap_defaults() {
  _has_command bash && [[ -r "$HOME/.macos-defaults" ]] || return
  local sig=$(cat "$HOME/.macos-defaults" 2>/dev/null | md5sum | awk '{print $1}')
  _check_signature "$HOME/.bootstrapped/macos" "$sig" 'bash "$HOME/.macos-defaults" 2>/dev/null && echo "macOS defaults applied." || true'
}

# Phase 5: Configure Git user (one-time or when credentials change)
# Sets global git user.name and user.email from CUSTOMIZATION section
# Skips if both GIT_AUTHOR_NAME and GIT_AUTHOR_EMAIL are empty
_bootstrap_git() {
  _has_command git && ([[ -n "$GIT_AUTHOR_NAME" ]] || [[ -n "$GIT_AUTHOR_EMAIL" ]]) || return
  local sig="${GIT_AUTHOR_NAME}|${GIT_AUTHOR_EMAIL}"
  _check_signature "$HOME/.bootstrapped/git" "$sig" '[[ -n "$GIT_AUTHOR_NAME" ]] && git config --global user.name "$GIT_AUTHOR_NAME"; [[ -n "$GIT_AUTHOR_EMAIL" ]] && git config --global user.email "$GIT_AUTHOR_EMAIL"; echo "Git configured."'
}

# Phase 6: Add ~/.bin to PATH (if directory exists)
# Prioritizes ~/.bin over other PATH entries for personal scripts
# Only runs once per session (runtime check, not state-based)
_bootstrap_path() {
  [[ -d ~/.bin ]] && [[ ! (" ${path[*]} " =~ " $HOME/.bin ") ]] && path=("$HOME/.bin" $path) && export PATH
}

# BOOTSTRAP ORCHESTRATOR
# Calls each phase in sequence (Homebrew → Symlinks → Packages → Defaults → Git → PATH)
# Homebrew creates Brewfile symlink, then packages installs from it
# Each phase returns early if not needed, making bootstrap idempotent
_bootstrap() {
  _bootstrap_homebrew
  _bootstrap_symlinks
  _bootstrap_packages
  _bootstrap_defaults
  _bootstrap_git
  _bootstrap_path
}

# Run bootstrap on every shell initialization
# Side effects are minimal: most phases return early on subsequent runs
_bootstrap

# SHELL RUNTIME CONFIGURATION
# Auto-source personal config files (symlinked from cloud storage)
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
    local selected=$(fc -rl 1 | awk '{$1="";print substr($0,2)}' | awk '!seen[$0]++' | fzf --reverse --query="$LBUFFER" --prompt="History > " --bind='ctrl-r:toggle-sort' --header='Ctrl+R: toggle sort')
    [[ -n $selected ]] && LBUFFER=$selected && zle accept-line
    zle reset-prompt
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
  git -C . rev-parse --is-inside-work-tree &>/dev/null || return
  local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) && [[ -n "$branch" ]] || return
  local color="%{$fg_bold[green]%}" && [[ -n $(git status --porcelain) ]] && color="%{$fg_bold[red]%}"
  echo "on ${color}🌱 $branch%{$reset_color%}"
}

# Count unpushed commits
_unpushed() {
  (( ${+commands[git]} )) && git -C . rev-parse --is-inside-work-tree &>/dev/null && [[ $(git rev-list @{u}.. 2>/dev/null | wc -l) -gt 0 ]] && echo " with %{$fg_bold[magenta]%}$(git rev-list @{u}.. 2>/dev/null | wc -l) unpushed%{$reset_color%}"
}

# PROMPT - Shows directory (cyan), git branch (green if clean, red if dirty), unpushed count (magenta)
export PROMPT=$'\nIn %{$fg_bold[cyan]%}%1/%\/%{$reset_color%} $(_git_info)$(_unpushed)\n› '
precmd() { export RPROMPT="%{$fg_bold[cyan]%}%{$reset_color%}"; }

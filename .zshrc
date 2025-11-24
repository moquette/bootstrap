# shfmt: disable
# ============================================================================
# ZSH Configuration
# A single-file setup for Zsh shell environment.
# ============================================================================

# ============================================================================
# CUSTOMIZATION SECTION - Edit these blocks to personalize your setup
# ============================================================================

# ----------------------------------------------------------------------------
# Git Configuration (Optional)
# Set git user name and email
# Leave blank to skip git setup
# Credential helper (osxkeychain) is managed by the system
# Examples:
#   GIT_AUTHOR_NAME="John Doe"
#   GIT_AUTHOR_EMAIL="john@example.com"
# ----------------------------------------------------------------------------
GIT_AUTHOR_NAME="Joaquin A. Moquette"
GIT_AUTHOR_EMAIL="moquette@gmail.com"

# ----------------------------------------------------------------------------
# Cloud Storage Base Directory (Optional)
# Set to your primary cloud storage location for easy symlink configuration
# Examples:
#   CLOUD_FOLDER="/Volumes/My Shared Files/mycloud"
#   CLOUD_FOLDER="$HOME/Dropbox"
#   CLOUD_FOLDER="$HOME/iCloud Drive"
# Leave blank to use full paths in CUSTOM_SYMLINKS instead
# ----------------------------------------------------------------------------
CLOUD_FOLDER="/Volumes/My Shared Files/mycloud"

# ----------------------------------------------------------------------------
# Custom Symlinks (Optional)
# Set up file/directory symlinks from cloud storage using format:
#   CUSTOM_SYMLINKS=("source|target" "source|target" ...)
# Use $CLOUD_FOLDER to reference your cloud storage base directory
# 
# Examples - SSH keys (one-time setup):
#   "$CLOUD_FOLDER/ssh|~/.ssh"
#   "~/Dropbox/ssh_keys|~/.ssh"
#   "~/Library/Mobile Documents/com~apple~CloudDocs/ssh_keys|~/.ssh"
#
# Examples - Personal scripts/binaries (added to PATH):
#   "$CLOUD_FOLDER/bin|~/.bin"         # ~/.bin added to PATH with priority
#
# Examples - Dotfiles:
#   "$CLOUD_FOLDER/system/zprofile.zsh|~/.zprofile"
#   "$CLOUD_FOLDER/git/config|~/.gitconfig"
#   "$CLOUD_FOLDER/tmux/tmuxconf|~/.tmuxconf"
#
# Behavior:
#   - Existing files/directories backed up to *.backup.<timestamp>
#   - Files set to 644 (read-write), directories to 755 (executable)
#   - SSH paths get special permissions: private keys 600, public keys 644
#   - One-time setup per entry; modify array to add new symlinks
#   - Sources must exist; targets created as needed
# Leave empty array to skip symlink setup
# ----------------------------------------------------------------------------
CUSTOM_SYMLINKS=(
  "$CLOUD_FOLDER/ssh|~/.ssh"
  "$CLOUD_FOLDER/bin|~/.bin"
  "$CLOUD_FOLDER/system/zprofile.zsh|~/.zprofile"
  "$CLOUD_FOLDER/system/vimrc.txt|~/.vimrc"
  "$CLOUD_FOLDER/system/aliases.txt|~/.aliases"
  "$CLOUD_FOLDER/system/brewfile.rb|~/.Brewfile"
)

# ============================================================================
# PACKAGE MANAGEMENT
# ============================================================================
# Packages are now managed via Brewfile (symlinked from cloud storage).
# Install with: brew bundle --file=~/.Brewfile
# See: $CLOUD_FOLDER/system/brewfile.rb

# ----------------------------------------------------------------------------
# Hushlogin - Suppress macOS login message
# Uncomment the line below to enable (creates ~/.hushlogin on first run)
# ----------------------------------------------------------------------------
# [ -f ~/.hushlogin ] || { touch ~/.hushlogin && echo '~/.hushlogin created.'; }

# ----------------------------------------------------------------------------
# Shell Aliases
# Aliases are now sourced from ~/.aliases (symlinked to cloud storage).
# Edit aliases.txt in your cloud storage to customize.
# See: $CLOUD_FOLDER/system/aliases.txt
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# macOS Defaults Configuration
# Customize keyboard, trackpad, Finder, Safari, and other system settings.
# Comment out any sections you don't want to apply.
# ----------------------------------------------------------------------------
MACOS_DEFAULTS=(
  # Keyboard & Input
  "defaults write -g ApplePressAndHoldEnabled -bool false"
  "defaults write NSGlobalDomain KeyRepeat -int 1"

  # Trackpad & Mouse
  "defaults write NSGlobalDomain com.apple.trackpad.scaling -float 3.0"
  "defaults write NSGlobalDomain com.apple.trackpad.scrolling -float 1.0"
  "defaults write NSGlobalDomain com.apple.mouse.scaling -float 2.5"
  "defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true"
  "defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1"
  "defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true"
  "defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true"

  # Finder
  "defaults write com.apple.Finder FXPreferredViewStyle clmv"
  "defaults write com.apple.finder NewWindowTarget -string 'PfLo'"
  "defaults write com.apple.finder NewWindowTargetPath -string 'file://${HOME}/'"

  # Hot Corners - Bottom-right starts screen saver
  "defaults write com.apple.dock wvous-br-corner -int 5"
  "defaults write com.apple.dock wvous-br-modifier -int 0"

  # Safari Developer Tools
  "defaults write com.apple.Safari.SandboxBroker ShowDevelopMenu -bool true"
  "defaults write com.apple.Safari.plist IncludeDevelopMenu -bool true"
  "defaults write com.apple.Safari.plist WebKitDeveloperExtrasEnabledPreferenceKey -bool true"
  "defaults write com.apple.Safari.plist com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true"
  "defaults write NSGlobalDomain WebKitDeveloperExtras -bool true"

  # TextEdit
  "defaults write com.apple.TextEdit NSShowAppCentricOpenPanelInsteadOfUntitledFile -bool false"
  "defaults write com.apple.TextEdit RichText -int 0"
)

# ============================================================================
# END OF CUSTOMIZATION SECTION
# ============================================================================

# ============================================================================
# BOOTSTRAP HELPER FUNCTIONS
# Utility functions for bootstrap operations
# --------

# Check if command exists
_has_command() {
  (( ${+commands[$1]} ))
}

# Output helpers for consistent messaging
_bootstrap_success() {
  echo "  ✓ $1"
}

_bootstrap_error() {
  echo "  ✗ $1"
}

_bootstrap_warning() {
  echo "  ⚠ $1"
}

_bootstrap_info() {
  echo "  → $1"
}

# Smart signature-based state management
# Compares stored signature with current and runs callback if different
_check_signature() {
  local flag_file="$1"
  local current_signature="$2"
  local callback="$3"
  
  local stored_signature=""
  if [ -f "$flag_file" ]; then
    stored_signature=$(cat "$flag_file")
  fi
  
  if [ "$current_signature" != "$stored_signature" ]; then
    eval "$callback"
    echo "$current_signature" > "$flag_file"
    return 0
  fi
  return 1
}

# Set SSH permissions on a directory
_set_ssh_permissions() {
  local ssh_dir="$1"
  
  if [[ ! -d "$ssh_dir" ]]; then
    return 1
  fi
  
  find "$ssh_dir" -type f -name "id_*" ! -name "*.pub" -exec chmod 600 {} \; 2>/dev/null || true
  find "$ssh_dir" -type f -name "*.pub" -exec chmod 644 {} \; 2>/dev/null || true
  find "$ssh_dir" -type f \( -name "config" -o -name "known_hosts" \) -exec chmod 600 {} \; 2>/dev/null || true
}

# ============================================================================
# END OF BOOTSTRAP HELPERS
# ============================================================================

# ============================================================================
# BOOTSTRAP PHASE
# ============================================================================

# Bootstrap State Directory
mkdir -p ~/.bootstrapped

# Symlink helper function (used by _bootstrap)
_setup_symlink() {
  local symlink_entry="$1"
  local source target
  
  # Parse source|target format
  source="${symlink_entry%|*}"
  target="${symlink_entry#*|}"
  
  # Expand ~ and variables in paths
  source="${source/\~/$HOME}"
  target="${target/\~/$HOME}"
  eval "source=\"$source\""
  eval "target=\"$target\""
  
  # Validate source exists
  if [[ ! -e "$source" ]]; then
    _bootstrap_warning "Skipped: source not found: $source"
    return 1
  fi
  
  # Create parent directory for target if needed
  local target_dir="$(dirname "$target")"
  if [[ ! -d "$target_dir" ]]; then
    mkdir -p "$target_dir" || { _bootstrap_error "Failed to create directory: $target_dir"; return 1; }
  fi
  
  # Backup existing target if it's not already a symlink
  if [[ -e "$target" ]] || [[ -L "$target" ]]; then
    if [[ ! -L "$target" ]]; then
      mv "$target" "$target.backup.$(date +%Y%m%d_%H%M%S)"
      _bootstrap_info "Backed up existing: $target → $target.backup.*"
    else
      # Remove old symlink if it exists
      rm -f "$target"
    fi
  fi
  
  # Create symlink
  ln -sfn "$source" "$target" || { _bootstrap_error "Failed to create symlink: $target"; return 1; }
  
  # Set permissions on target (644 for files, 755 for directories)
  if [[ -d "$source" ]]; then
    chmod 755 "$target" 2>/dev/null || true
    
    # For SSH directories, set stricter permissions on contents
    if [[ "$target" == *".ssh" ]] || [[ "$target" == "$HOME/.ssh" ]]; then
      _set_ssh_permissions "$target"
    fi
  else
    chmod 644 "$target" 2>/dev/null || true
  fi
  
  _bootstrap_success "Symlinked: $target → $source"
  return 0
}

# Main bootstrap orchestration function
_bootstrap() {
  # Homebrew Setup
  _setup_homebrew_path() {
    local brew_path
    [[ -x /opt/homebrew/bin/brew ]] && brew_path="/opt/homebrew/bin/brew" || brew_path="/usr/local/bin/brew"
    
    if ! grep -q "brew shellenv" ~/.zprofile 2>/dev/null; then
      echo "" >> ~/.zprofile
      echo "eval \"\$($brew_path shellenv)\"" >> ~/.zprofile
    fi
    
    eval "$($brew_path shellenv)"
  }

  if [[ "$OSTYPE" == "darwin"* ]] && ! _has_command brew; then
    if [[ -x /opt/homebrew/bin/brew ]] || [[ -x /usr/local/bin/brew ]]; then
      _setup_homebrew_path
    else
      echo "Installing Homebrew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      _setup_homebrew_path
      echo "Homebrew installed successfully."
      brew analytics off 2>/dev/null
      echo "Homebrew analytics disabled."
    fi
  fi

  # Homebrew Bundle (Install packages from Brewfile)
  if _has_command brew && [[ -r "$HOME/.Brewfile" ]]; then
    local brewfile_signature=$(cat "$HOME/.Brewfile" 2>/dev/null | md5sum | awk '{print $1}')
    local brewfile_flag="$HOME/.bootstrapped/brewfile"
    
    if _check_signature "$brewfile_flag" "$brewfile_signature" 'echo "Installing packages from Brewfile..."; brew bundle --file="$HOME/.Brewfile" --no-upgrade 2>/dev/null && echo "Homebrew bundle installed successfully." || echo "Homebrew bundle installation completed with warnings."'; then
      :
    fi
  fi

  # macOS Defaults Configuration
  if [[ "$OSTYPE" == "darwin"* ]] && [ ${#MACOS_DEFAULTS[@]} -gt 0 ]; then
    local defaults_signature="${MACOS_DEFAULTS[*]}"
    local defaults_flag="$HOME/.bootstrapped/macos"
    
    if _check_signature "$defaults_flag" "$defaults_signature" 'echo "Configuring macOS defaults..."; for default_cmd in "${MACOS_DEFAULTS[@]}"; do eval "$default_cmd"; done; echo "macOS defaults configured. Restart apps for changes to take effect."'; then
      :
    fi
  fi

  # Custom Symlinks Setup
  if [ ${#CUSTOM_SYMLINKS[@]} -gt 0 ] && [ ! -f ~/.bootstrapped/symlinks ]; then
    echo "Setting up custom symlinks..."
    
    local failed_count=0
    for symlink_entry in "${CUSTOM_SYMLINKS[@]}"; do
      _setup_symlink "$symlink_entry" || ((failed_count++))
    done
    
    touch ~/.bootstrapped/symlinks
    
    if [[ $failed_count -eq 0 ]]; then
      echo "Custom symlinks configured successfully."
    else
      echo "Custom symlinks setup completed with $failed_count error(s). Check paths in CUSTOM_SYMLINKS."
    fi
  fi

  # Git Configuration
  if _has_command git && ([[ -n "$GIT_AUTHOR_NAME" ]] || [[ -n "$GIT_AUTHOR_EMAIL" ]]); then
    local git_signature="${GIT_AUTHOR_NAME}|${GIT_AUTHOR_EMAIL}"
    local git_flag="$HOME/.bootstrapped/git"
    
    if _check_signature "$git_flag" "$git_signature" 'echo "Configuring git..."; [[ -n "$GIT_AUTHOR_NAME" ]] && git config --global user.name "$GIT_AUTHOR_NAME" && echo "  Set git user.name to: $GIT_AUTHOR_NAME"; [[ -n "$GIT_AUTHOR_EMAIL" ]] && git config --global user.email "$GIT_AUTHOR_EMAIL" && echo "  Set git user.email to: $GIT_AUTHOR_EMAIL"; echo "Git configuration complete."'; then
      :
    fi
  fi

  # Add ~/.bin to PATH if it exists
  if [[ -d ~/.bin ]] && [[ ! (" ${path[*]} " =~ " $HOME/.bin ") ]]; then
    path=("$HOME/.bin" $path)
    export PATH
  fi
}

# Run bootstrap on shell initialization
_bootstrap

# ============================================================================
# SOURCE PERSONAL ZPROFILE IF IT EXISTS
# ============================================================================
# Automatically source personal zprofile after bootstrap (so symlinks are in place)
# This is optional and only runs if ~/.zprofile exists AND is readable
[[ -r "$HOME/.zprofile" ]] && source "$HOME/.zprofile" 2>/dev/null || true

# ============================================================================
# SOURCE ALIASES IF AVAILABLE
# ============================================================================
# Auto-source custom aliases after bootstrap (so symlink is in place)
# This is optional and only runs if ~/.aliases exists AND is readable
[[ -r "$HOME/.aliases" ]] && source "$HOME/.aliases" 2>/dev/null || true

# ----------------------------------------------------------------------------
# History Configuration
# ----------------------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# ----------------------------------------------------------------------------
# Shell Options
# ----------------------------------------------------------------------------
# History options
setopt SHARE_HISTORY          # Share history between sessions
setopt HIST_IGNORE_DUPS       # Don't record duplicate commands
setopt HIST_IGNORE_SPACE      # Don't record commands starting with space
setopt APPEND_HISTORY         # Append to history file
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicates first when trimming history
setopt HIST_FIND_NO_DUPS      # Don't show duplicates when searching

# Navigation options
setopt AUTO_CD                # Change directory without cd command
setopt AUTO_PUSHD             # Push directories onto stack automatically
setopt PUSHD_IGNORE_DUPS      # Don't push duplicate directories
setopt PUSHD_SILENT           # Don't print directory stack after pushd/popd

# Prompt options
setopt PROMPT_SUBST           # Enable parameter expansion in prompts

# Completion options
setopt COMPLETE_IN_WORD       # Complete from both ends of word
setopt ALWAYS_TO_END          # Move cursor to end after completion
setopt AUTO_MENU              # Show completion menu on successive tab press
setopt AUTO_LIST              # Automatically list choices on ambiguous completion

# Misc options
setopt INTERACTIVE_COMMENTS   # Allow comments in interactive shell

# ----------------------------------------------------------------------------
# Key Bindings
# ----------------------------------------------------------------------------
# FZF-based history search on arrow up
if (( ${+commands[fzf]} )); then
  _fzf_history_search() {
    setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null
    local selected=$(fc -rl 1 | awk '{$1="";print substr($0,2)}' | \
      awk '!seen[$0]++' | \
      fzf --reverse --no-sort --exact \
          --query="$LBUFFER" \
          --prompt="History > " \
          --preview='echo {}' --preview-window=down:3:wrap \
          --bind='ctrl-r:toggle-sort' \
          --header='Ctrl+R: toggle sort | Enter: execute')
    if [[ -n $selected ]]; then
      LBUFFER=$selected
      zle accept-line
    fi
    zle reset-prompt
  }
  zle -N _fzf_history_search
  bindkey '^[[A' _fzf_history_search  # Up arrow
else
  # Fallback to prefix search if fzf not available
  autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
  zle -N up-line-or-beginning-search
  zle -N down-line-or-beginning-search
  bindkey '^[[A' up-line-or-beginning-search
  bindkey '^[[B' down-line-or-beginning-search
fi

# ----------------------------------------------------------------------------
# Completion System
# ----------------------------------------------------------------------------
autoload -Uz compinit && compinit

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Highlight current selection in menu
zstyle ':completion:*' menu select

# Use colors in completion
zstyle ':completion:*' list-colors ''

# Cache completion for faster loading
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# Group completions by type
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%B%d%b'

# Enable approximate completion
zstyle ':completion:*' completer _complete _approximate
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Load colors
autoload -Uz colors && colors

# ----------------------------------------------------------------------------
# Prompt Functions
# ----------------------------------------------------------------------------

# Git command setup
if (( ${+commands[git]} )); then
  git="$commands[git]"
else
  git="/usr/bin/git"
fi

# Show git branch with color based on dirty status
git_dirty() {
  ! $git status -s &>/dev/null && echo "" && return
  
  local branch=$(git_prompt_info) || return
  local color="%{$fg_bold[green]%}"
  [[ -n $($git status --porcelain) ]] && color="%{$fg_bold[red]%}"
  
  echo "on ${color}🌱 $branch%{$reset_color%}"
}

# Get git branch name
git_prompt_info() {
  local ref=$($git symbolic-ref HEAD 2>/dev/null) || return
  echo "${ref#refs/heads/}"
}

# Show unpushed commits count
need_push() {
  ! $git rev-parse --is-inside-work-tree &>/dev/null && return
  
  local count=$($git cherry -v @{u} 2>/dev/null | wc -l | tr -d ' ')
  [[ $count -gt 0 ]] && echo " with %{$fg_bold[magenta]%}$count unpushed%{$reset_color%}"
}

# Show current directory name
directory_name() {
  echo "%{$fg_bold[cyan]%}%1/%\/%{$reset_color%}"
}

# ----------------------------------------------------------------------------
# Prompt Configuration
# ----------------------------------------------------------------------------
export PROMPT=$'\nIn $(directory_name) $(git_dirty)$(need_push)\n› '

set_prompt() {
  export RPROMPT="%{$fg_bold[cyan]%}%{$reset_color%}"
}

precmd() {
  set_prompt
}

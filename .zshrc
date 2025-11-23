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
# Set git user name, email, and credential helper
# Leave blank to skip git setup
# Examples:
#   GIT_AUTHOR_NAME="John Doe"
#   GIT_AUTHOR_EMAIL="john@example.com"
#   GIT_CREDENTIAL_HELPER="osxkeychain"  # macOS default, or use "store", "manager"
# On macOS, osxkeychain is built-in and recommended
# Leave GIT_CREDENTIAL_HELPER empty to skip credential helper setup
# ----------------------------------------------------------------------------
GIT_AUTHOR_NAME=""
GIT_AUTHOR_EMAIL=""
GIT_CREDENTIAL_HELPER="osxkeychain"

# ----------------------------------------------------------------------------
# SSH Configuration (Optional)
# Set to your preferred location to symlink SSH keys from cloud storage
# Examples:
#   CUSTOM_SSH_DIR="$HOME/Dropbox/ssh_keys"
#   CUSTOM_SSH_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/ssh_keys"
# Leave blank to skip SSH setup
# ----------------------------------------------------------------------------
CUSTOM_SSH_DIR=""

# ----------------------------------------------------------------------------
# Custom Bin Directory (Optional)
# Set to your preferred location to symlink personal scripts/binaries from cloud storage
# Examples:
#   CUSTOM_BIN_DIR="$HOME/Dropbox/bin"
#   CUSTOM_BIN_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/bin"
# Leave blank to skip custom bin setup
# Note: ~/.bin will be added to PATH with priority over system directories
# ----------------------------------------------------------------------------
CUSTOM_BIN_DIR=""

# ----------------------------------------------------------------------------
# Essential Packages to Install via Homebrew
# Add or remove packages as needed. Set to empty array to skip installation.
# ----------------------------------------------------------------------------
ESSENTIAL_PACKAGES=(
  node        # JavaScript runtime
  fzf         # Fuzzy finder for better history search
)

# ----------------------------------------------------------------------------
# Hushlogin - Suppress macOS login message
# Uncomment the line below to enable (creates ~/.hushlogin on first run)
# ----------------------------------------------------------------------------
# [ -f ~/.hushlogin ] || { touch ~/.hushlogin && echo '~/.hushlogin created.'; }

# ----------------------------------------------------------------------------
# Shell Aliases - Customize to your preferences
# Edit these alias definitions directly. Format: alias name='command'
# To add a new alias, add a line like: alias myalias='my command'
# To modify an alias, change the value after the = sign
# Common pattern: alias short_name='actual command you want to run'
alias .='cd ~'
alias ..='..'
alias ls='ls -lh'
alias l='ls -lh'
alias la='ls -lAh'
alias ld='ls -lah | grep "^d"'
alias lf='ls -lah | grep "^-"'
alias ll='ls -lah | grep "^l"'
alias lh='ls -ldh .*'
alias l.='ls -ldh .*'
alias c='clear'
alias r='clear && exec zsh'
alias x='exit'
alias ea='vim ~/.zshrc'

# ----------------------------------------------------------------------------
# Vim Configuration
# Customize these settings to match your preferences
# These settings will be written to ~/.vimrc on first run
# ----------------------------------------------------------------------------
VIM_CONFIG='
" Basic Settings
set number              " Show line numbers
set relativenumber      " Show relative line numbers
set cursorline          " Highlight current line
set ruler               " Show cursor position
set showcmd             " Show command in bottom bar
set wildmenu            " Visual autocomplete for command menu
set showmatch           " Highlight matching brackets
set incsearch           " Search as characters are entered
set hlsearch            " Highlight search matches
set ignorecase          " Case insensitive search
set smartcase           " Case sensitive when uppercase present
set autoindent          " Auto indent
set smartindent         " Smart indent
set expandtab           " Use spaces instead of tabs
set tabstop=4           " Number of spaces per tab
set shiftwidth=4        " Number of spaces for auto indent
set softtabstop=4       " Number of spaces for tab in insert mode
set wrap                " Wrap long lines
set linebreak           " Break lines at word boundaries
set scrolloff=5         " Keep 5 lines above/below cursor
set backspace=indent,eol,start  " Backspace over everything
set clipboard=unnamed   " Use system clipboard
set mouse=a             " Enable mouse support
syntax on               " Enable syntax highlighting
filetype plugin indent on  " Enable filetype detection
'

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

# ----------------------------------------------------------------------------
# Bootstrap State Directory
# Central location for all bootstrap signature files
# ----------------------------------------------------------------------------
[ -d ~/.bootstrapped ] || { mkdir -p ~/.bootstrapped && echo '~/.bootstrapped created.'; }

# ----------------------------------------------------------------------------
# Vim Configuration (Bootstrap Phase)
# Consumes VIM_CONFIG from customization section
# ----------------------------------------------------------------------------
if [ ! -f ~/.vimrc ]; then
  cat > ~/.vimrc << EOF
$VIM_CONFIG
EOF
  echo '~/.vimrc created with sensible defaults.'
fi

# ----------------------------------------------------------------------------
# Homebrew Setup
# ----------------------------------------------------------------------------
_setup_homebrew_path() {
  local brew_path
  [[ -x /opt/homebrew/bin/brew ]] && brew_path="/opt/homebrew/bin/brew" || brew_path="/usr/local/bin/brew"
  
  if ! grep -q "brew shellenv" ~/.zprofile 2>/dev/null; then
    echo "" >> ~/.zprofile
    echo "eval \"\$($brew_path shellenv)\"" >> ~/.zprofile
  fi
  
  eval "$($brew_path shellenv)"
}

if [[ "$OSTYPE" == "darwin"* ]] && ! (( ${+commands[brew]} )); then
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

# ----------------------------------------------------------------------------
# Essential Packages Auto-Install (Smart Detection)
# Consumes ESSENTIAL_PACKAGES array from customization section
# Automatically detects when packages are added/removed and re-installs
# ----------------------------------------------------------------------------
if (( ${+commands[brew]} )) && [ ${#ESSENTIAL_PACKAGES[@]} -gt 0 ]; then
  # Create a signature of the current package list
  local packages_signature="${ESSENTIAL_PACKAGES[*]}"
  local packages_flag="$HOME/.bootstrapped/packages"
  local stored_signature=""
  
  # Read stored signature if it exists
  if [ -f "$packages_flag" ]; then
    stored_signature=$(cat "$packages_flag")
  fi
  
  # Install if signature changed (packages added/removed) or flag doesn't exist
  if [ "$packages_signature" != "$stored_signature" ]; then
    echo "Installing essential packages..."
    for package in "${ESSENTIAL_PACKAGES[@]}"; do
      if ! brew list "$package" &>/dev/null; then
        echo "  Installing $package..."
        brew install "$package"
      fi
    done
    
    # Store the current signature to detect future changes
    echo "$packages_signature" > "$packages_flag"
    echo "Essential packages installed."
  fi
fi

# ----------------------------------------------------------------------------
# macOS Defaults Configuration (Bootstrap Phase)
# Consumes MACOS_DEFAULTS array from customization section
# Automatically detects when defaults are added/removed/modified and re-applies
# Comment out lines in MACOS_DEFAULTS to skip specific settings
# ----------------------------------------------------------------------------
if [[ "$OSTYPE" == "darwin"* ]] && [ ${#MACOS_DEFAULTS[@]} -gt 0 ]; then
  # Create a signature of the current defaults list
  local defaults_signature="${MACOS_DEFAULTS[*]}"
  local defaults_flag="$HOME/.bootstrapped/macos"
  local stored_signature=""
  
  # Read stored signature if it exists
  if [ -f "$defaults_flag" ]; then
    stored_signature=$(cat "$defaults_flag")
  fi
  
  # Apply if signature changed (defaults added/removed/modified) or flag doesn't exist
  if [ "$defaults_signature" != "$stored_signature" ]; then
    echo "Configuring macOS defaults..."
    
    for default_cmd in "${MACOS_DEFAULTS[@]}"; do
      eval "$default_cmd"
    done
    
    # Store the current signature to detect future changes
    echo "$defaults_signature" > "$defaults_flag"
    echo "macOS defaults configured. Restart apps for changes to take effect."
  fi
fi

# ----------------------------------------------------------------------------
# Custom SSH Directory Setup (Bootstrap Phase)
# Consumes CUSTOM_SSH_DIR from customization section
# --------

if [[ -n "$CUSTOM_SSH_DIR" ]]; then
  if [[ ! -d "$CUSTOM_SSH_DIR" ]]; then
    echo "Warning: CUSTOM_SSH_DIR is set to '$CUSTOM_SSH_DIR' but directory not found."
    echo "SSH directory setup skipped. Create the directory or update CUSTOM_SSH_DIR."
  elif [ ! -f ~/.bootstrapped/ssh ]; then
    # Set proper SSH permissions
    chmod 700 "$CUSTOM_SSH_DIR"

    # Set permissions for private keys (if they exist)
    if ls "$CUSTOM_SSH_DIR"/id_* &>/dev/null; then
      chmod 600 "$CUSTOM_SSH_DIR"/id_*
    fi

    # Set permissions for public keys (if they exist)
    if ls "$CUSTOM_SSH_DIR"/*.pub &>/dev/null; then
      chmod 644 "$CUSTOM_SSH_DIR"/*.pub
    fi

    # Set permissions for config and known_hosts (if they exist)
    [[ -f "$CUSTOM_SSH_DIR/config" ]] && chmod 600 "$CUSTOM_SSH_DIR/config"
    [[ -f "$CUSTOM_SSH_DIR/known_hosts" ]] && chmod 644 "$CUSTOM_SSH_DIR/known_hosts"

    # Backup existing ~/.ssh if it's not a symlink
    if [[ -d ~/.ssh ]] && [[ ! -L ~/.ssh ]]; then
      mv ~/.ssh ~/.ssh.backup.$(date +%Y%m%d_%H%M%S)
      echo "Backed up existing ~/.ssh to ~/.ssh.backup.*"
    fi

    # Create symlink from ~/.ssh to custom directory
    ln -sfn "$CUSTOM_SSH_DIR" ~/.ssh

    # Create flag file
    touch ~/.bootstrapped/ssh
    echo "SSH directory configured: ~/.ssh -> $CUSTOM_SSH_DIR"
    echo "Permissions set: directory=700, private keys=600, public keys=644"
  fi
fi

# ----------------------------------------------------------------------------
# Custom Bin Directory Setup (Bootstrap Phase)
# Consumes CUSTOM_BIN_DIR from customization section
# Creates symlink from ~/.bin to custom directory and adds to PATH
# --------

if [[ -n "$CUSTOM_BIN_DIR" ]]; then
  if [[ ! -d "$CUSTOM_BIN_DIR" ]]; then
    echo "Warning: CUSTOM_BIN_DIR is set to '$CUSTOM_BIN_DIR' but directory not found."
    echo "Custom bin directory setup skipped. Create the directory or update CUSTOM_BIN_DIR."
  elif [ ! -f ~/.bootstrapped/bin ]; then
    # Set proper bin directory permissions
    chmod 755 "$CUSTOM_BIN_DIR"

    # Set permissions for executable files (if they exist)
    if ls "$CUSTOM_BIN_DIR"/* &>/dev/null 2>&1; then
      chmod 755 "$CUSTOM_BIN_DIR"/*
    fi

    # Backup existing ~/.bin if it's not a symlink
    if [[ -d ~/.bin ]] && [[ ! -L ~/.bin ]]; then
      mv ~/.bin ~/.bin.backup.$(date +%Y%m%d_%H%M%S)
      echo "Backed up existing ~/.bin to ~/.bin.backup.*"
    fi

    # Create symlink from ~/.bin to custom directory
    ln -sfn "$CUSTOM_BIN_DIR" ~/.bin

    # Create flag file
    touch ~/.bootstrapped/bin
    echo "Custom bin directory configured: ~/.bin -> $CUSTOM_BIN_DIR"
    echo "Permissions set: directory=755, executables=755"
  fi
fi

# ----------------------------------------------------------------------------
# Git Configuration Setup (Bootstrap Phase)
# Consumes GIT_AUTHOR_NAME, GIT_AUTHOR_EMAIL, GIT_CREDENTIAL_HELPER from customization section
# Only runs if at least name or email is set (both required for meaningful git config)
# Idempotent: safe to run multiple times (git config overwrites existing values)
# --------

if (( ${+commands[git]} )) && ([[ -n "$GIT_AUTHOR_NAME" ]] || [[ -n "$GIT_AUTHOR_EMAIL" ]]); then
  echo "Configuring git..."
  
  if [[ -n "$GIT_AUTHOR_NAME" ]]; then
    git config --global user.name "$GIT_AUTHOR_NAME"
    echo "  Set git user.name to: $GIT_AUTHOR_NAME"
  fi
  
  if [[ -n "$GIT_AUTHOR_EMAIL" ]]; then
    git config --global user.email "$GIT_AUTHOR_EMAIL"
    echo "  Set git user.email to: $GIT_AUTHOR_EMAIL"
  fi
  
  if [[ -n "$GIT_CREDENTIAL_HELPER" ]]; then
    git config --global credential.helper "$GIT_CREDENTIAL_HELPER"
    echo "  Set git credential.helper to: $GIT_CREDENTIAL_HELPER"
  fi
  
  echo "Git configuration complete."
fi

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
# Environment Variables
# ----------------------------------------------------------------------------
# Default editor
export EDITOR='vim'
export VISUAL='vim'

# Consolidate PATH setup - avoid duplicates
# Homebrew is already added via shellenv, so we only add custom directories
typeset -U path  # Remove duplicate entries from path array

if [[ -d ~/.bin ]]; then
  path=("$HOME/.bin" $path)
fi

if [[ -d "$HOME/bin" ]]; then
  path=("$HOME/bin" $path)
fi

if [[ -d "$HOME/.local/bin" ]]; then
  path=("$HOME/.local/bin" $path)
fi

export PATH

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

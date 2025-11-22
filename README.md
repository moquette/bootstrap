# Bootstrap

A single-file, opinionated (yet customizable :) zsh configuration for macOS environments. Designed to bootstrap a fresh system with sensible defaults, essential tools, and productivity features.

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/moquette/bootstrap/main/.zshrc -o ~/.zshrc && source ~/.zshrc
```

That's it. On a fresh macOS system, this will:

- Create `.hushlogin` (suppress login banner)
- Generate `.vimrc` with your customized settings
- Install Homebrew (if needed, requires password)
- Install packages from your `ESSENTIAL_PACKAGES` list
- Configure macOS system defaults from your `MACOS_DEFAULTS` array
- Enable fuzzy history search, git-aware prompt, and more

## What's Included

### 🚀 Auto-Setup (First Run Only)

- **Vim Config**: Your customized editor settings from `VIM_CONFIG`
- **Homebrew**: Auto-installs if missing, with PATH configuration
- **Essential Packages**: Installs packages from your `ESSENTIAL_PACKAGES` array (fzf by default)
- **macOS Defaults**: Keyboard repeat, trackpad scaling, Finder preferences, Safari dev tools, etc.
- **SSH Setup** (Optional): Link SSH keys from cloud storage if `CUSTOM_SSH_DIR` is set

### 📝 Configuration

- **History**: 10,000 lines shared between sessions, deduplication
- **Navigation**: Auto-cd, directory stack management
- **Completion**: Case-insensitive, caching, approximate matching
- **Shell Options**: Best practices for interactive shells

### ⌨️ Key Features

- **FZF History Search**: Press ↑ arrow to fuzzy-search command history with prefix matching
- **Git-Aware Prompt**: Shows branch, dirty status (🟢 clean, 🔴 dirty), and unpushed commits
- **Aliases**: Curated set for navigation, listing, and utilities

### 🎯 Aliases

#### Navigation

```bash
.      # cd ~
..     # cd ..
```

#### File Listing

```bash
ls     # ls -lh (default long format)
l      # ls -lh (long format)
la     # ls -lAh (all files + hidden)
ld     # Directories only
lf     # Files only
ll     # Symlinks only
lh/l.  # Hidden files/directories
```

#### Utilities

```bash
c      # clear
r      # clear && reload zsh
x      # exit
ea     # vim ~/.zshrc (edit config)
```

### 🎨 Prompt

```text
In ~/projects/my-app on 🌱 main
› 
```

- Shows current directory
- Git branch with clean/dirty status
- Indicates unpushed commits
- Clean, minimal design

## Customization

All customization options are at the **top of `~/.zshrc`** in the **CUSTOMIZATION SECTION** for easy access:

### Configuration Sections

1. **Vim Configuration** (`VIM_CONFIG` string)
   - Customize editor settings (tabs, line numbers, search options, etc.)
   - These settings are written to `~/.vimrc` on first run
   - Modify any vim setting to your preferences

2. **Essential Packages** (`ESSENTIAL_PACKAGES` array)
   - Add or remove Homebrew packages to install
   - Set to empty array to skip package installation
   - Example: Add `ripgrep` by adding `ripgrep` to the array

3. **macOS Defaults** (`MACOS_DEFAULTS` array)
   - Keyboard repeat, trackpad sensitivity, Finder preferences, Safari dev tools, etc.
   - Comment out any `defaults write` line to skip that setting
   - Each line is easy to understand and modify

4. **Shell Aliases** (defined directly at the top in CUSTOMIZATION SECTION)
   - Navigation, file listing, and utility aliases
   - Edit the alias definitions directly—just copy/paste new lines
   - To add a new alias: `alias myname='my command'`
   - To modify an existing alias: change the command after the `=` sign

5. **SSH Keys** (`CUSTOM_SSH_DIR` variable - optional)
   - Set this to link SSH keys from cloud storage (Dropbox, iCloud, etc.)
   - Leave blank to skip SSH setup
   - Examples:
     - `CUSTOM_SSH_DIR="$HOME/Dropbox/ssh_keys"`
     - `CUSTOM_SSH_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/ssh_keys"`
   - Auto-creates symlink, sets permissions, backs up existing `~/.ssh`

## Automation & Bootstrap Flags

The script uses flag files to prevent re-running setup steps:

- `~/.zshrc_packages_installed` - Homebrew packages
- `~/.zshrc_macos_configured` - macOS defaults
- `~/.zshrc_ssh_configured` - SSH symlink setup

Delete these files to re-run that phase.

## System Requirements

- **macOS** 10.15+
- **zsh** (default on macOS 10.15+)
- **Homebrew** (auto-installs if needed)

## Notes

- Designed as a **single file** for portability and simplicity
- All setup runs on first shell initialization
- Non-destructive: backs up existing `.ssh` before symlinking
- Idempotent: safe to re-source without issues
- Optimized for fresh system bootstrapping; existing dotfiles not affected

## File Structure

```text
bootstrap/
├── .zshrc                  # Main configuration
├── .editorconfig           # Editor consistency rules
├── .gitignore              # Git ignore rules
├── README.md               # Documentation
└── LICENSE                 # MIT License
```

## What Gets Modified

First run creates/modifies:

- `~/.hushlogin` - Created if missing
- `~/.vimrc` - Created if missing
- `~/.zprofile` - Adds Homebrew shellenv (if needed)
- `~/.zsh/cache/` - Completion cache (auto-created)
- `~/.zshrc_*` - Flag files (prevent re-running setup)

Optional:

- `~/.ssh` - Symlinked to `$CUSTOM_SSH_DIR` if set

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Copyright (c) 2025 Joaquin A. Moquette

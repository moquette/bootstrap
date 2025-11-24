# Bootstrap

A single-file, opinionated (yet customizable :) zsh configuration for macOS environments. Designed to bootstrap a fresh system with sensible defaults, essential tools, and productivity features.

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/moquette/bootstrap/main/.zshrc -o ~/.zshrc && source ~/.zshrc
```

That's it. On a fresh macOS system, this will:

- Generate `.vimrc` with your customized settings
- Install Homebrew (if needed, requires password)
- Install packages from your `ESSENTIAL_PACKAGES` list
- Configure macOS system defaults from your `MACOS_DEFAULTS` array
- Setup git user name and email (if configured)
- Create custom symlinks for dotfiles, SSH keys, and scripts from cloud storage (if configured)
- Enable fuzzy history search, git-aware prompt, and more

## What's Included

### 🚀 Auto-Setup (First Run Only)

- **Vim Config**: Your customized editor settings from `VIM_CONFIG`
- **Homebrew**: Auto-installs if missing, with PATH configuration
- **Essential Packages**: Installs packages from your `ESSENTIAL_PACKAGES` array with smart change detection (re-installs when list changes)
- **macOS Defaults**: Keyboard repeat, trackpad scaling, Finder preferences, Safari dev tools, etc. with smart change detection
- **Git Configuration** (Optional): Sets user name and email if `GIT_AUTHOR_NAME` and `GIT_AUTHOR_EMAIL` are configured
- **Custom Symlinks** (Optional): Creates symlinks for dotfiles, SSH keys, scripts, and other files/directories from cloud storage using the `CUSTOM_SYMLINKS` array

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

1. **Git Configuration** (`GIT_AUTHOR_NAME`, `GIT_AUTHOR_EMAIL` variables - optional)
   - Set these to auto-configure git on first run
   - Leave both blank to skip git setup
   - `GIT_AUTHOR_NAME` - Your git commit author name (e.g., "John Doe")
   - `GIT_AUTHOR_EMAIL` - Your git commit author email (e.g., jane@company.com)
   - One-time setup: runs `git config --global` commands to set values
   - Safe to run multiple times (idempotent)
   - Example configuration:

     ```bash
     GIT_AUTHOR_NAME="Jane Smith"
     GIT_AUTHOR_EMAIL="jane@company.com"
     ```

2. **Cloud Storage Folder** (`CLOUD_FOLDER` variable - optional)
   - Base path to your cloud-synced dotfiles (Dropbox, iCloud, mounted volumes, etc.)
   - Used as a prefix for `CUSTOM_SYMLINKS` entries to reduce path repetition
   - Example configurations:
     - `CLOUD_FOLDER="$HOME/Dropbox/dotfiles"`
     - `CLOUD_FOLDER="$HOME/Library/Mobile Documents/com~apple~CloudDocs/dotfiles"`
     - `CLOUD_FOLDER="/Volumes/My Shared Files/mycloud"`
   - Leave empty if not using cloud storage symlinks

3. **Custom Symlinks** (`CUSTOM_SYMLINKS` array - optional)
   - Create symlinks for files and directories from cloud storage or any source
   - Format: `"source|target"` (pipe-separated)
   - Supports variables like `$HOME` and `$CLOUD_FOLDER`
   - Automatic permission handling:
     - Files: 644 (readable by all, writable by owner)
     - Directories: 755 (full permissions for owner, read+execute for others)
     - SSH directories: special handling (config/known_hosts: 600, keys: 600, public keys: 644)
   - Backs up existing targets to `target.backup.<timestamp>` before symlinking
   - Set to empty array to skip symlink setup
   - Examples:

     ```bash
     CUSTOM_SYMLINKS=(
       "$CLOUD_FOLDER/ssh|~/.ssh"
       "$CLOUD_FOLDER/bin|~/.bin"
       "$CLOUD_FOLDER/gitconfig|~/.gitconfig"
       "$CLOUD_FOLDER/config/nvim|~/.config/nvim"
     )
     ```

4. **Essential Packages** (`ESSENTIAL_PACKAGES` array)
   - Add or remove Homebrew packages to install
   - Set to empty array to skip package installation
   - **Smart detection**: Adding/removing packages automatically triggers re-installation on next shell startup
   - Example: Add `ripgrep` by adding `ripgrep # Description` to the array

5. **Shell Aliases** (defined directly at the top in CUSTOMIZATION SECTION)
   - Navigation, file listing, and utility aliases
   - Edit the alias definitions directly—just copy/paste new lines
   - To add a new alias: `alias myname='my command'`
   - To modify an existing alias: change the command after the `=` sign
   - Changes take effect on next shell startup (sourced from file)

6. **Vim Configuration** (`VIM_CONFIG` string)
   - Customize editor settings (tabs, line numbers, search options, etc.)
   - These settings are written to `~/.vimrc` on first run
   - Modify any vim setting to your preferences

7. **macOS Defaults** (`MACOS_DEFAULTS` array)
   - Keyboard repeat, trackpad sensitivity, Finder preferences, Safari dev tools, etc.
   - Comment out any `defaults write` line to skip that setting
   - **Smart detection**: Modifying the list automatically re-applies on next shell startup
   - Each line is easy to understand and modify

## Automation & Bootstrap Flags

Bootstrap uses a state directory `~/.bootstrapped/` to track which setup steps have been completed. Each step uses smart change detection:

- **`~/.bootstrapped/packages`** - Package list signature
  - Automatically re-runs when you add/remove packages from `ESSENTIAL_PACKAGES`
  - Only installs packages that are missing

- **`~/.bootstrapped/macos`** - macOS defaults signature
  - Automatically re-runs when you add/remove/modify entries in `MACOS_DEFAULTS`
  - Re-applies all configured defaults

- **`~/.bootstrapped/git`** - Git configuration signature
  - Automatically re-runs when you change `GIT_AUTHOR_NAME` or `GIT_AUTHOR_EMAIL`
  - Re-applies git config with updated values

- **`~/.bootstrapped/symlinks`** - Custom symlinks setup flag
  - One-time setup (no re-run needed unless manually deleted)

**To reset a specific component**, delete the corresponding flag file:

```bash
rm ~/.bootstrapped/packages    # Re-run package installation on next shell
rm ~/.bootstrapped/macos       # Re-run macOS defaults on next shell
rm ~/.bootstrapped/git         # Re-run git configuration on next shell
rm ~/.bootstrapped/symlinks    # Re-run symlinks setup on next shell
```

**To reset everything:**

```bash
rm -rf ~/.bootstrapped
```

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
├── .zshrc                  # Main configuration (single-file design)
├── .editorconfig           # Editor consistency rules
├── .gitignore              # Git ignore rules
├── README.md               # Documentation
├── LICENSE                 # MIT License
└── .github/
    └── copilot-instructions.md  # Development guidelines
```

## Bootstrap State Directory

On first run, Bootstrap creates `~/.bootstrapped/` to track setup state:

```text
~/.bootstrapped/
├── packages               # Package list signature (smart detection)
├── macos                  # macOS defaults signature (smart detection)
├── git                    # Git configuration signature (smart detection)
└── symlinks               # Custom symlinks setup flag
```

## What Gets Modified

First run creates/modifies:

- `~/.vimrc` - Created if missing
- `~/.zprofile` - Adds Homebrew shellenv (if needed)
- `~/.zsh/cache/` - Completion cache (auto-created)
- `~/.bootstrapped/` - State directory with signature files

Optional (if configured via `CUSTOM_SYMLINKS`):

- Custom symlinks (e.g., `~/.ssh`, `~/.bin`, `~/.config/nvim`, etc.)
  - Creates parent directories as needed
  - Backs up existing targets to `*.backup.<timestamp>`

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Copyright (c) 2025 Joaquin A. Moquette

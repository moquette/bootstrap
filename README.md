# Bootstrap

A single-file, opinionated (yet customizable :) zsh configuration for macOS environments. Designed to bootstrap a fresh system with sensible defaults, essential tools, and productivity features.

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/moquette/bootstrap/main/.zshrc -o ~/.zshrc && source ~/.zshrc
```

That's it. On a fresh macOS system, this will:

- Create `.hushlogin` (suppress login banner) - *optional, uncomment in customization to enable*
- Generate `.vimrc` with your customized settings
- Install Homebrew (if needed, requires password)
- Install packages from your `ESSENTIAL_PACKAGES` list
- Configure macOS system defaults from your `MACOS_DEFAULTS` array
- Setup git user name, email, and credential helper (if configured)
- Setup SSH keys from cloud storage (if `CUSTOM_SSH_DIR` is configured)
- Setup custom bin directory with personal scripts (if `CUSTOM_BIN_DIR` is configured)
- Enable fuzzy history search, git-aware prompt, and more

## What's Included

### 🚀 Auto-Setup (First Run Only)

- **Vim Config**: Your customized editor settings from `VIM_CONFIG`
- **Homebrew**: Auto-installs if missing, with PATH configuration
- **Essential Packages**: Installs packages from your `ESSENTIAL_PACKAGES` array with smart change detection (re-installs when list changes)
- **macOS Defaults**: Keyboard repeat, trackpad scaling, Finder preferences, Safari dev tools, etc. with smart change detection
- **Git Configuration** (Optional): Sets user name, email, and credential helper if `GIT_AUTHOR_NAME`, `GIT_AUTHOR_EMAIL`, or `GIT_CREDENTIAL_HELPER` are configured
- **SSH Setup** (Optional): Link SSH keys from cloud storage if `CUSTOM_SSH_DIR` is set
- **Custom Bin Directory** (Optional): Link personal scripts from cloud storage if `CUSTOM_BIN_DIR` is set, with priority PATH placement

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

1. **Git Configuration** (`GIT_AUTHOR_NAME`, `GIT_AUTHOR_EMAIL`, `GIT_CREDENTIAL_HELPER` variables - optional)
   - Set these to auto-configure git on first run
   - Leave all blank to skip git setup
   - `GIT_AUTHOR_NAME` - Your git commit author name (e.g., "John Doe")
   - `GIT_AUTHOR_EMAIL` - Your git commit author email (e.g., john at example dot com)
   - `GIT_CREDENTIAL_HELPER` - Credential storage method:
     - `"osxkeychain"` - Recommended for macOS (built-in, secure)
     - `"store"` - Simple file-based storage (less secure)
     - `"manager"` - Git Credential Manager (requires installation)
     - Leave empty to skip credential helper setup
   - One-time setup: runs `git config --global` commands to set values
   - Safe to run multiple times (idempotent - later runs overwrite with same values)
   - Example configuration:

     ```bash
     GIT_AUTHOR_NAME="Jane Smith"
     GIT_AUTHOR_EMAIL="jane@company.com"
     GIT_CREDENTIAL_HELPER="osxkeychain"
     ```

2. **SSH Keys** (`CUSTOM_SSH_DIR` variable - optional)
   - Set this to link SSH keys from cloud storage (Dropbox, iCloud, etc.)
   - Leave blank to skip SSH setup
   - One-time setup: creates symlink, sets permissions, backs up existing `~/.ssh`
   - Examples:
     - `CUSTOM_SSH_DIR="$HOME/Dropbox/ssh_keys"`
     - `CUSTOM_SSH_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/ssh_keys"`

3. **Custom Bin Directory** (`CUSTOM_BIN_DIR` variable - optional)
   - Set this to link personal scripts from cloud storage (Dropbox, iCloud, etc.)
   - Leave blank to skip custom bin setup
   - One-time setup: creates symlink, sets permissions (755), backs up existing `~/.bin`
   - **Priority in PATH**: `~/.bin` is added to PATH first for script priority
   - Examples:
     - `CUSTOM_BIN_DIR="$HOME/Dropbox/bin"`
     - `CUSTOM_BIN_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/bin"`
   - Scripts in this folder become available as commands immediately

4. **Essential Packages** (`ESSENTIAL_PACKAGES` array)
   - Add or remove Homebrew packages to install
   - Set to empty array to skip package installation
   - **Smart detection**: Adding/removing packages automatically triggers re-installation on next shell startup
   - Example: Add `ripgrep` by adding `ripgrep # Description` to the array

5. **Hushlogin** (Optional - commented by default)
   - Uncomment the line to suppress the macOS login message
   - Creates `~/.hushlogin` on first run when uncommented
   - Line in CUSTOMIZATION SECTION: `[ -f ~/.hushlogin ] || { touch ~/.hushlogin && echo '~/.hushlogin created.'; }`

6. **Shell Aliases** (defined directly at the top in CUSTOMIZATION SECTION)
   - Navigation, file listing, and utility aliases
   - Edit the alias definitions directly—just copy/paste new lines
   - To add a new alias: `alias myname='my command'`
   - To modify an existing alias: change the command after the `=` sign
   - Changes take effect on next shell startup (sourced from file)

7. **Vim Configuration** (`VIM_CONFIG` string)
   - Customize editor settings (tabs, line numbers, search options, etc.)
   - These settings are written to `~/.vimrc` on first run
   - Modify any vim setting to your preferences

8. **macOS Defaults** (`MACOS_DEFAULTS` array)
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
  - Automatically re-runs when you change `GIT_AUTHOR_NAME`, `GIT_AUTHOR_EMAIL`, or `GIT_CREDENTIAL_HELPER`
  - Re-applies git config with updated values

- **`~/.bootstrapped/ssh`** - SSH setup flag
  - One-time setup (no re-run needed unless manually deleted)

- **`~/.bootstrapped/bin`** - Custom bin setup flag
  - One-time setup (no re-run needed unless manually deleted)

**To reset a specific component**, delete the corresponding flag file:

```bash
rm ~/.bootstrapped/packages    # Re-run package installation on next shell
rm ~/.bootstrapped/macos       # Re-run macOS defaults on next shell
rm ~/.bootstrapped/git         # Re-run git configuration on next shell
rm ~/.bootstrapped/ssh         # Re-run SSH setup on next shell
rm ~/.bootstrapped/bin         # Re-run bin setup on next shell
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
├── ssh                    # SSH symlink setup flag
└── bin                    # Custom bin setup flag
```

## What Gets Modified

First run creates/modifies:

- `~/.hushlogin` - Created if uncommented (suppress login banner) - *optional*
- `~/.vimrc` - Created if missing
- `~/.zprofile` - Adds Homebrew shellenv (if needed)
- `~/.zsh/cache/` - Completion cache (auto-created)
- `~/.bootstrapped/` - State directory with signature files

Optional (if configured):

- `~/.bin` - Symlinked to `$CUSTOM_BIN_DIR` if set
- `~/.ssh` - Symlinked to `$CUSTOM_SSH_DIR` if set

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Copyright (c) 2025 Joaquin A. Moquette

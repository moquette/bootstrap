# Dots

A single-file, opinionated (yet customizable :) zsh configuration for macOS environments. Designed to set up a fresh system with sensible defaults, essential tools, and productivity features.

## Quick Start

```bash
  curl -fsSL https://raw.githubusercontent.com/moquette/dots/main/.zshrc -o ~/.zshrc && source ~/.zshrc
```

That's it. On a fresh macOS system, this will:

- Create custom symlinks for dotfiles, SSH keys, and scripts from cloud storage (one-time setup)
- Install Homebrew (if needed, requires password)
- Install packages from your `.Brewfile` with smart change detection
- Configure macOS system defaults from your `~/.macos-defaults` with smart change detection
- Enable fuzzy history search, git-aware prompt, and more

## What's Included

### 🚀 Auto-Setup (Idempotent Dots Phases)

- **Custom Symlinks** (one-time): Creates symlinks for dotfiles, SSH keys, scripts, and other files/directories from cloud storage using convention-based auto-discovery (`.symlink` extension) and the `CUSTOM_SYMLINKS` array for edge cases
- **Homebrew**: Auto-installs if missing, with PATH configuration
- **Packages**: Installs packages from `~/.Brewfile` with smart change detection (re-installs when file changes)
- **npm Packages**: Installs global npm packages from `~/.npmrc-packages` with smart change detection (re-installs when file changes)
- **macOS Defaults**: Applies settings from `~/.macos-defaults` with smart change detection (re-applies when file changes)
- **PATH Enhancement**: Adds `~/.bin` to PATH if directory exists (runtime check)

### 📝 Shell Configuration

- **History**: 10,000 lines shared between sessions, deduplication, duplicates removed
- **Navigation**: Auto-cd to directories, directory stack management (pushd/popd)
- **Completion**: Case-insensitive matching, caching for performance, approximate matching
- **Shell Options**: Best practices for interactive shells (auto menu, interactive comments, etc.)

### ⌨️ Key Features

- **FZF History Search**: Press ↑ arrow to fuzzy-search command history with prefix matching (or fallback to prefix search)
- **Git-Aware Prompt**: Shows branch, dirty status (green if clean, red if dirty), and unpushed commits
- **Custom Aliases**: Define your own aliases via `~/.aliases` (sourced from cloud storage)
- **Completion System**: Case-insensitive, cached, with approximate matching

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

### Philosophy

Dots follows a **generic orchestrator + personal config** design:

- **`.zshrc`** (this repo) - Generic, shareable orchestrator with sensible defaults
- **`~/.zshrc.local`** (your machine) - Personal extensions, never committed

The orchestrator provides helper functions that `.zshrc.local` can leverage:

```bash
# In ~/.zshrc.local - extend the orchestrator
_has_command myapp && _run_if_changed \
  "$HOME/.myapp/config" \
  "$DOTS_STATE/myapp" \
  'echo "Setting up myapp..."; myapp setup'
```

**Available Helpers:**
- `_has_command <cmd>` - Check if command exists before running setup
- `_run_if_changed <file> <state-key> '<command>'` - Run command only when file content changes (MD5 check)
- `$DOTS_STATE` - State directory (`~/.dots/`) for tracking setup completions

This pattern keeps the orchestrator generic while letting you add machine-specific setup (API keys, personal tools, etc.) in `.zshrc.local`.

## Customization

All customization options are at the **top of `~/.zshrc`** in the **CUSTOMIZATION SECTION** for easy access:

### Configuration Sections

1. **Cloud Storage Folder** (`CLOUD_FOLDER` variable - optional)
   - Base path to your cloud-synced dotfiles (Dropbox, iCloud, mounted volumes, etc.)
   - Used as a prefix for `CUSTOM_SYMLINKS` entries to reduce path repetition
   - Example configurations:
     - `CLOUD_FOLDER="$HOME/Dropbox/dotfiles"`
     - `CLOUD_FOLDER="$HOME/Library/Mobile Documents/com~apple~CloudDocs/dotfiles"`
     - `CLOUD_FOLDER="/Volumes/My Shared Files/mycloud"`
   - Leave empty if not using cloud storage symlinks

2. **Custom Symlinks** (`CUSTOM_SYMLINKS` array - optional)
   - Create symlinks for files and directories from cloud storage or any source
   - **Convention-based auto-discovery**: Files/folders ending in `.symlink` are automatically discovered
     - `basename.symlink` → `~/.basename`
     - `folder.symlink/` → `~/.folder/`
     - Example: `aliases.symlink` → `~/.aliases`
     - Example: `ssh.symlink/` → `~/.ssh/`
   - **Explicit array**: Use for edge cases (no leading dot, custom paths, renamed targets)
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
     # Convention-based (auto-discovered from iCloud):
     # Just rename files in $CLOUD_FOLDER:
     #   ssh/ → ssh.symlink/
     #   aliases.txt → aliases.symlink
     #   gitconfig.txt → gitconfig.symlink
     
     # Explicit array (for edge cases):
     CUSTOM_SYMLINKS=(
       "$CLOUD_FOLDER/Code.symlink|~/Code"  # No leading dot
       "$CLOUD_FOLDER/notes.symlink|~/Documents/Notes"  # Custom path
     )
     ```
   
   See [MIGRATION.md](MIGRATION.md) for migrating to convention-based naming.

3. **Shell Aliases** (managed via `~/.aliases` file)
   - Define custom aliases in your `~/.aliases` file
   - Configure source via `CUSTOM_SYMLINKS` to use cloud storage version
   - Example: `"$CLOUD_FOLDER/shell/aliases.symlink|~/.aliases"`
   - Dots auto-sources from `~/.aliases` if it exists
   - Changes take effect on next shell startup

4. **Vim Configuration** (managed via `~/.vimrc` file)
   - Customize editor settings by modifying `~/.vimrc`
   - Configure source via `CUSTOM_SYMLINKS` to use cloud storage version
   - Example: `"$CLOUD_FOLDER/config/vimrc.symlink|~/.vimrc"`
   - Edit your vim settings directly in the file

5. **macOS Defaults** (`~/.macos-defaults` file)
   - Keyboard repeat, trackpad sensitivity, Finder preferences, Safari dev tools, etc.
   - Configure source via `CUSTOM_SYMLINKS` to use cloud storage version
   - Example: `"$CLOUD_FOLDER/macos/macos-defaults|~/.macos-defaults"`
   - **Smart detection**: Modifying the file automatically re-applies on next shell startup
   - Each line is a separate `defaults write` command (easy to read and modify)

6. **npm Packages** (`~/.npmrc-packages` file)
   - Global npm packages installed via `npm install -g`
   - Configure source via `CUSTOM_SYMLINKS` to use cloud storage version
   - Example: `"$CLOUD_FOLDER/packages/npmrc-packages|~/.npmrc-packages"`
   - **Smart detection**: Modifying the file automatically re-installs packages on next shell startup
   - One package per line, comments with `#` are ignored
   - Example file:

     ```text
     @github/copilot
     typescript
     # other-package
     ```

## Automation & Dots State Management

Dots uses a state directory `~/.dots/` to track which setup steps have been completed. Smart signature detection enables idempotent re-runs:

- **`~/.dots/brewfile`** - Brewfile MD5 signature
  - Automatically re-runs when `~/.Brewfile` content changes
  - Installs/updates packages based on current Brewfile

- **`~/.dots/npm`** - npm packages file MD5 signature
  - Automatically re-runs when `~/.npmrc-packages` content changes
  - Re-installs global npm packages when file changes

- **`~/.dots/macos`** - macOS defaults file MD5 signature
  - Automatically re-runs when `~/.macos-defaults` content changes
  - Re-applies all configured defaults when file changes

- **`~/.dots/symlinks`** - Symlinks setup flag
  - One-time setup after first run (no re-run unless manually deleted)

**To reset a specific component**, delete the corresponding flag file:

```bash
rm ~/.dots/brewfile    # Re-run package installation on next shell
rm ~/.dots/macos       # Re-run macOS defaults on next shell
rm ~/.dots/git         # Re-run git configuration on next shell
rm ~/.dots/symlinks    # Re-run symlinks setup on next shell
```

**To reset everything:**

```bash
rm -rf ~/.dots
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
- Optimized for fresh system setup; existing dotfiles not affected

## File Structure

```text
dots/
├── .zshrc                  # Main configuration (single-file design)
├── .editorconfig           # Editor consistency rules
├── .gitignore              # Git ignore rules
├── README.md               # Documentation
├── LICENSE                 # MIT License
├── .vscode/                # VS Code workspace configuration
│   ├── extensions.json     # Recommended extensions (ShellCheck, Bash IDE)
│   └── dots.code-snippets  # Code snippets for dotfiles patterns
├── dots.code-workspace     # Multi-root workspace configuration
└── .github/
    └── copilot-instructions.md  # Development guidelines
```

## Development

This repo includes an optimized VS Code workspace for development:

### Opening the Workspace

```bash
code dots.code-workspace
```

The workspace includes two folders:
- **Dots Project** - The Git repository (this folder)
- **My Cloud** - Private dotfiles in iCloud (never committed)

### Features

- **Syntax Highlighting** - Shell script support for `.txt` config files (aliases, zshrc.local, etc.)
- **ShellCheck Integration** - Linting configured for zsh-specific syntax
- **Code Snippets** - Quick templates for common patterns (`symlink`, `runif`, `hascmd`)
- **Tasks** - Quick actions via `Cmd+Shift+P` → "Tasks: Run Task"
  - Source .zshrc
  - Test Dots Setup
  - Reset Dots State

### Prerequisites

Install recommended extensions when prompted, or manually:
- ShellCheck - `brew install shellcheck`
- Bash IDE extension - For autocomplete

## Dots State Directory

On first run, Dots creates `~/.dots/` to track setup state:

```text
~/.dots/
├── brewfile              # Brewfile MD5 signature (smart detection)
├── macos                 # macOS defaults file MD5 signature (smart detection)
├── git                   # Git configuration signature (smart detection)
└── symlinks              # Custom symlinks setup flag
```

## What Gets Modified

First run creates/modifies:

- `~/.zprofile` - Adds Homebrew shellenv (if needed)
- `~/.zsh/cache/` - Completion cache (auto-created)
- `~/.dots/` - State directory with signature files

Optional (if configured via `CUSTOM_SYMLINKS`):

- Custom symlinks (e.g., `~/.ssh`, `~/.bin`, `~/.config/nvim`, `~/.vimrc`, `~/.aliases`, `~/.macos-defaults`, etc.)
  - Creates parent directories as needed
  - Backs up existing targets to `*.backup.<timestamp>`
  - Sets proper permissions (644 for files, 755 for directories, special handling for SSH keys)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Copyright (c) 2025 Joaquin A. Moquette

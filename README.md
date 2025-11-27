# Dotfiles: Self-Healing Dotfiles Orchestrator

**A revolutionary single-file zsh orchestrator that combines convention-based automation with self-healing architecture.**

Unlike traditional dotfiles that require manual symlinking and setup, this orchestrator automatically discovers, configures, and maintains your entire development environment across machines—with zero manual intervention after the initial curl.

## What Makes This Different?

### 🔮 Convention-Based Auto-Discovery

Files ending in `.symlink` are automatically discovered and symlinked. No arrays to maintain, no manual setup.

### 🔄 Self-Healing Architecture

Machine-specific configs in `~/.zshrc.local` automatically recreate themselves on any new machine. Move to a new laptop? Just curl, source, and everything rebuilds itself.

### 📍 Two-Location Design

- **Public repo** (`~/.dotfiles/`) - Generic, shareable orchestrator
- **Private cloud** (`~/Library/Mobile Documents/.../Dotfiles/`) - Your personal configs, never committed

### 🎯 Idempotent Everything

MD5 signatures detect file changes. Packages, system settings, and configs only run when they actually change. Re-source 100 times, only runs once.

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/moquette/dotfiles/main/install.sh | bash
```

**That's it.** One command. On a fresh macOS system, this:

1. ✅ Auto-discovers and symlinks all `.symlink` files from cloud storage
2. ✅ Installs Homebrew (if missing)
3. ✅ Installs packages from your Brewfile
4. ✅ Installs global npm packages
5. ✅ Applies macOS system defaults
6. ✅ Sets up shell with FZF history, git-aware prompt, and more

**On your second machine?** Same command. Everything rebuilds itself automatically.

## The Magic: How It Works

## The Magic: How It Works

### Convention Over Configuration

```
$CLOUD_FOLDER/shell/aliases.symlink     →  ~/.aliases
$CLOUD_FOLDER/ssh.symlink/              →  ~/.ssh/
$CLOUD_FOLDER/config/vimrc.symlink      →  ~/.vimrc
```

Name it `.symlink`, put it in cloud storage, done. The orchestrator finds and links everything automatically.

### Self-Healing Private Configs

Your `~/.zshrc.local` (stored in cloud, synced via convention) contains:

```bash
CUSTOM_SYMLINKS=(
  "$CLOUD_FOLDER/.github|$DOTFILES_REPO/.github"
  "$CLOUD_FOLDER/ai/claude/CLAUDE.md|~/.claude/CLAUDE.md"
)
_dotfiles_symlinks  # Recreate all private symlinks
```

**New machine?** This file is automatically symlinked via convention, runs itself, and recreates all your private configs. Zero manual work.

### Smart Change Detection

```bash
# Only runs when Brewfile content actually changes
_run_if_changed "$HOME/.Brewfile" "$DOTFILES_STATE/Brewfile" \
  'brew bundle --file="$HOME/.Brewfile"'
```

MD5 signatures track file contents. Edit your Brewfile, next shell startup installs packages. Don't edit it? Silent. Efficient.

## Architecture

### Two Locations, Zero Conflicts

**Git Repository** (`~/.dotfiles/`)

```
zshrc.symlink          # The orchestrator (public, generic)
README.md              # Documentation
.state/                # MD5 signatures for change detection
```

**Cloud Storage** (`~/Library/Mobile Documents/.../Dotfiles/`)

```
shell/                 # Shell configs (aliases, zprofile, zshrc.local)
packages/              # Brewfile, npm packages
config/                # gitconfig, vimrc
macos/                 # System defaults
bin.symlink/           # Custom scripts
ssh.symlink/           # SSH keys (never committed!)
.github/               # Copilot instructions (private)
```

### Execution Phases

1. **Symlinks** - Convention-based discovery + explicit `CUSTOM_SYMLINKS`
2. **Homebrew** - Auto-install if missing
3. **Packages** - Install from Brewfile (MD5-tracked)
4. **npm** - Global packages (MD5-tracked)
5. **macOS Defaults** - System settings (MD5-tracked)
6. **PATH** - Add `~/.bin` if it exists

Each phase is idempotent. Run once, run 1000 times—same result.

## What's Included

- **Custom Symlinks** (one-time): Creates symlinks for dotfiles, SSH keys, scripts, and other files/directories from cloud storage using convention-based auto-discovery (`.symlink` extension) and the `CUSTOM_SYMLINKS` array for edge cases
- **Homebrew**: Auto-installs if missing, with PATH configuration
- **Packages**: Installs packages from `~/.Brewfile` with smart change detection (re-installs when file changes)
- **npm Packages**: Installs global npm packages from `~/.npmrc-packages` with smart change detection (re-installs when file changes)
- **macOS Defaults**: Applies settings from `~/.macos-defaults` with smart change detection (re-applies when file changes)
- **PATH Enhancement**: Adds `~/.bin` to PATH if directory exists (runtime check)

## What's Included

### Shell Features

- **Custom Symlinks** (one-time): Creates symlinks for dotfiles, SSH keys, scripts, and other files/directories from cloud storage using convention-based auto-discovery (`.symlink` extension) and the `CUSTOM_SYMLINKS` array for edge cases
- **Homebrew**: Auto-installs if missing, with PATH configuration
- **Packages**: Installs packages from `~/.Brewfile` with smart change detection (re-installs when file changes)
- **npm Packages**: Installs global npm packages from cloud storage with smart change detection (re-installs when file changes)
- **macOS Defaults**: Applies settings from cloud storage with smart change detection (re-applies when file changes)
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

### The Three-Tier System

**Tier 1: Convention-Based (Preferred)**

```bash
# In cloud storage:
$CLOUD_FOLDER/shell/aliases.symlink       # Auto-discovered → ~/.aliases
$CLOUD_FOLDER/config/gitconfig.symlink    # Auto-discovered → ~/.gitconfig
```

Just name it `.symlink` and place in cloud storage. Zero configuration.

**Tier 2: Explicit in Orchestrator (Public)**

```bash
# In zshrc.symlink - applies to all users:
CUSTOM_SYMLINKS=(
  "$CLOUD_FOLDER/special/path|~/target"
)
```

Use for non-standard paths that should apply universally.

**Tier 3: Machine-Specific Self-Healing (Private)**

```bash
# In ~/.zshrc.local - private, auto-synced via convention:
CUSTOM_SYMLINKS=(
  "$CLOUD_FOLDER/.github|$DOTFILES_REPO/.github"
  "$CLOUD_FOLDER/api-keys|~/.secrets"
)
_dotfiles_symlinks  # Recreates everything automatically
```

**This is the magic.** Define once, works everywhere. New machine? Automatically rebuilt.

### Adding Orchestrated Phases

Want to auto-setup something when its config changes?

```bash
# In ~/.zshrc.local:
_dotfiles_my_app() {
  local config="$CLOUD_FOLDER/my-app/config.yml"
  [[ ! -r "$config" ]] && return
  _run_if_changed "$config" "$DOTFILES_STATE/my-app" \
    'echo "Setting up my-app..."; my-app setup'
}

# Add to execution:
_dotfiles() {
  # ... existing phases ...
  _dotfiles_my_app
}
```

MD5 signature tracks changes. Edit config? Auto-runs. Don't edit? Silent.

## Helper Functions

Available everywhere (orchestrator + `~/.zshrc.local`):

- `_has_command <cmd>` - Check if command exists
- `_run_if_changed <file> <state-key> '<command>'` - Run only when file content changes
- `_expand_path <path>` - Expand `~`, `$CLOUD_FOLDER`, `$HOME`
- `_setup_symlink <source|target>` - Create symlink with backup
- `_log <icon> <message>` - Consistent logging

**Environment variables:**

- `$DOTFILES_REPO` - Git repo location
- `$DOTFILES_STATE` - State directory for MD5 signatures
- `$CLOUD_FOLDER` - Cloud storage base path

## Cloud Folder Structure

Organized by purpose, not by tradition:

```
$CLOUD_FOLDER/
├── shell/           # Pure shell configs (aliases, zprofile, zshrc.local)
├── packages/        # Brewfile, npm packages
├── config/          # Application dotfiles (gitconfig, vimrc)
├── macos/           # macOS-specific settings
├── bin.symlink/     # Custom scripts → ~/.bin
├── ssh.symlink/     # SSH keys → ~/.ssh (never committed!)
└── .github/         # AI assistant instructions (private)
```

### Why This Structure?

- **Semantic clarity** - Each folder has one purpose
- **Scalable** - Easy to add `linux/`, `windows/`, new package managers
- **Cross-platform ready** - Platform-specific folders clearly separated
- **Convention-friendly** - `.symlink` works everywhere

## Philosophy

**Generic Orchestrator + Personal Config + Self-Healing**

- `zshrc.symlink` is generic and shareable (public repo)
- Cloud storage holds your private configs (never committed)
- `~/.zshrc.local` extends the orchestrator with machine-specific setup
- **Self-healing**: Define `CUSTOM_SYMLINKS` in `~/.zshrc.local`, call `_dotfiles_symlinks`, everything auto-recreates on new machines
- Convention over configuration (auto-discovery via `.symlink`)
- **Zero manual setup** required after initial bootstrap

## State Management

The orchestrator tracks setup completion in `$DOTFILES_REPO/.state/`:

```
.state/
├── Brewfile         # MD5 signature - reruns when Brewfile changes
├── npm              # MD5 signature - reruns when npm packages change
├── macos            # MD5 signature - reruns when defaults change
└── symlinks         # One-time flag (delete to force rerun)
```

**Reset everything:**

```bash
rm -rf "$DOTFILES_REPO/.state" && source ~/.zshrc
```

## Customization (Legacy Documentation)

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
   - The orchestrator auto-sources from `~/.aliases` if it exists
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

## Automation & State Management

The orchestrator uses a state directory `$DOTFILES_REPO/.state/` to track which setup steps have been completed. Smart signature detection enables idempotent re-runs:

- **`$DOTFILES_REPO/.state/Brewfile`** - Brewfile MD5 signature

  - Automatically re-runs when `~/.Brewfile` content changes
  - Installs/updates packages based on current Brewfile

- **`$DOTFILES_REPO/.state/npm`** - npm packages file MD5 signature

  - Automatically re-runs when npm packages file content changes
  - Re-installs global npm packages when file changes

- **`$DOTFILES_REPO/.state/macos`** - macOS defaults file MD5 signature

  - Automatically re-runs when macOS defaults file content changes
  - Re-applies all configured defaults when file changes

**To reset a specific component**, delete the corresponding state file:

```bash
rm "$DOTFILES_REPO/.state/Brewfile"    # Re-run package installation on next shell
rm "$DOTFILES_REPO/.state/macos"       # Re-run macOS defaults on next shell
rm "$DOTFILES_REPO/.state/npm"         # Re-run npm packages on next shell
```

**To reset everything:**

```bash
rm -rf "$DOTFILES_REPO/.state"
```

## System Requirements

- **macOS** 10.15+
- **zsh** (default on macOS 10.15+)
- **Homebrew** (auto-installs if needed)
- **Cloud storage** (optional, for syncing configs across machines)

## Why This Approach?

**Traditional dotfiles:**

- Clone repo
- Run install script
- Manually symlink files
- Repeat on every machine
- Hope you didn't forget anything

**This orchestrator:**

- Curl one file
- Source it
- Everything auto-discovers, auto-configures, auto-syncs
- Move to new machine? Same curl, everything rebuilds
- **Zero manual intervention**

## File Structure

```text
$DOTFILES_REPO/             # Public repo (generic orchestrator)
├── zshrc.symlink           # Main orchestrator (single-file design)
├── .state/                 # MD5 signatures for change detection
├── README.md               # This file
├── LICENSE                 # MIT License
└── dotfiles.code-workspace # VS Code multi-root workspace

$CLOUD_FOLDER/              # Private cloud storage (your configs)
├── shell/                 # Shell configs (auto-discovered via .symlink)
├── packages/              # Brewfile, npm packages
├── config/                # gitconfig, vimrc
├── macos/                 # System defaults
├── bin.symlink/           # Scripts → ~/.bin
├── ssh.symlink/           # SSH keys → ~/.ssh
└── .github/               # AI instructions (symlinked to repo)
```

## Development

VS Code workspace with multi-root setup:

```bash
code "$DOTFILES_REPO/dotfiles.code-workspace"
```

**Features:**

- Both repo and cloud storage visible
- ShellCheck integration
- Quick tasks: source, test, reset state
- Code snippets for common patterns

## Common Pitfalls

❌ **Don't** commit private configs (SSH keys, API keys, etc.)  
✅ **Do** keep them in cloud storage with `.symlink` naming

❌ **Don't** hard-code absolute paths in orchestrator  
✅ **Do** use `$CLOUD_FOLDER` variable

❌ **Don't** manually maintain symlink arrays  
✅ **Do** use convention-based `.symlink` naming

❌ **Don't** forget machine-specific configs need `~/.zshrc.local`  
✅ **Do** define `CUSTOM_SYMLINKS` there for self-healing

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Copyright (c) 2025 Joaquin A. Moquette

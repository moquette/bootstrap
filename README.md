# Bootstrap

A simple, modular dotfiles bootstrap system.

## Installation

You can install this dotfiles system in one of two ways:

### Option 1: Using the bootstrap command (recommended)

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/moquette/bootstrap/main/setup)"
```

Note: The bootstrap command now ensures that config.sh (the single source of truth for configuration) is downloaded automatically.

### Option 2: Clone the entire repository

Alternatively, you can clone the entire repository using:

```bash
git clone https://github.com/moquette/bootstrap.git ${HOME}/.dotfiles
```

and then run the setup script from within the cloned directory:

```bash
cd ${HOME}/.dotfiles
./setup
```

### Debugging Installation

If you encounter issues during installation, particularly with Brewfile installation, you can run the setup script in debug mode to see detailed execution steps:

```bash
# For debugging Brewfile installation, run:
bash -x ./setup
```

This will display each command as it executes, helping to identify where problems might be occurring.

## Features

- Modular design
- Easy to customize
- Simple installation
- Cross-platform compatibility

## Structure

- `setup`: Main bootstrap script
- `config.sh`: Configuration file (single source of truth for configuration)
- `modules/`: Directory containing individual configuration modules

## Customization

Edit the `config.sh` file to customize your installation preferences.

## SSH Configuration

The bootstrap process automatically creates a symbolic link from your custom SSH directory (specified by the LOCAL_SSH_DIR variable) to ~/.ssh. By default, LOCAL_SSH_DIR is set to:

```bash
${HOME}/Library/Mobile Documents/com~apple~CloudDocs/Dotfiles/Dotlocal/ssh
```

This allows you to store your SSH configuration in iCloud for backup and synchronization across devices.

If ~/.ssh already exists and is not a symlink, it will be moved to ~/.ssh.backup before linking. You can override LOCAL_SSH_DIR by setting it as an environment variable before running the bootstrap script:

```bash
LOCAL_SSH_DIR="/path/to/your/ssh/directory" bash -c "$(curl -fsSL https://raw.githubusercontent.com/moquette/bootstrap/main/setup)"
```

## Error Handling

This bootstrap system implements intelligent error handling that adapts to your shell context:

- **Non-interactive shells (scripts)**: Strict error handling is enforced with `set -euo pipefail`, which causes scripts to exit immediately if any command fails, any unset variable is referenced, or any command in a pipeline fails.

- **Interactive shells (terminal sessions)**: A more forgiving approach is used where errors are logged without closing your terminal. Instead, a trap is set to display error messages with line numbers.

This dual approach ensures that:

1. Scripts fail fast and visibly when something goes wrong (preventing cascading errors)
2. Your terminal sessions remain stable even when commands fail

### Customizing Error Behavior

If you want to modify the error handling behavior:

1. Edit the `config.sh` file to change the trap behavior for interactive shells:

   ```bash
   # Default trap (shows error line number)
   trap 'echo "An error occurred on line $LINENO." >&2' ERR

   # Example of a more detailed trap
   trap 'echo "Error on line $LINENO: Command \"$BASH_COMMAND\" exited with status $?" >&2' ERR
   ```

2. To disable error trapping completely in interactive shells, comment out or remove the trap line.

3. For non-interactive shells, you can modify the strict mode options in the `set -euo pipefail` line.

## Running Setup Multiple Times

The bootstrap setup script is designed to be idempotent, meaning it can be run multiple times without causing issues:

### What Happens on Subsequent Runs

When you run the setup script again after initial installation:

1. **Repository Clone**: The script will detect that the dotfiles directory already exists and skip the cloning step.
2. **Dotfile Symlinks**: Existing symlinks will be removed and recreated, ensuring they always point to the current files in your dotfiles repository.
3. **SSH Configuration**: If already correctly linked, the script will detect this and make no changes.
4. **Brewfile Installation**: The script will run `brew bundle` again, which:
   - Installs any packages in the Brewfile that aren't already installed
   - Skips packages that are already installed
   - Does not remove packages that were previously installed but are no longer in the Brewfile

### Managing Brewfile Installations

The Brewfile at `/Users/moquette/.dotfiles/Brewfile` controls which applications are installed. When you see output like:

```
Installing coreutils
Installing gh
Installing visual-studio-code
brew bundle complete! 3 Brewfile dependencies now installed.
```

This indicates that Homebrew is checking each package and installing it if needed. If a package is already installed, Homebrew will simply verify its presence and move on.

### Customizing Repeated Runs

If you want to:

- **Add new packages**: Edit your Brewfile to add new packages, then run the setup script again
- **Remove packages**: Comment out or remove lines from your Brewfile, then manually uninstall unwanted packages using `brew uninstall <package-name>`
- **Update all packages**: Run `brew update && brew upgrade` separately from the setup script

### Troubleshooting Repeated Runs

If you encounter issues with repeated runs:

- Check that symlinks are pointing to the correct locations
- Verify that your Brewfile contains the expected packages
- Run `brew doctor` to identify and fix any Homebrew-related issues

## License

MIT

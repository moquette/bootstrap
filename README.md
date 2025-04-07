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

## License

MIT

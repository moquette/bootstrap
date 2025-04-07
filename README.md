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

## License

MIT
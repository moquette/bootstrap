# Migration Guide: Convention-Based Symlinks

## Overview

This guide helps you migrate from the explicit `CUSTOM_SYMLINKS` array to the convention-based `.symlink` naming system.

## Convention Rules

1. **Files**: `basename.symlink` → `~/.basename`
2. **Folders**: `basename.symlink/` → `~/.basename/`
3. **Always adds leading dot** to the target filename

## Migration Steps

### 1. Rename Files in iCloud

Navigate to your iCloud Dots folder and rename files:

```bash
cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/Dots/system

# Rename files
mv aliases.txt aliases.symlink
mv gitconfig.txt gitconfig.symlink
mv vimrc.txt vimrc.symlink
mv zlogout.txt zlogout.symlink
mv zprofile.zsh zprofile.symlink
mv brewfile.rb Brewfile.symlink
mv macos-defaults.txt macos-defaults.symlink
mv npmrc-packages.txt npmrc-packages.symlink
mv zshrc.local.txt zshrc.local.symlink

# Rename folders
cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/Dots
mv ssh ssh.symlink
mv bin bin.symlink
```

### 2. Clear Symlink State

```bash
rm ~/.dots/symlinks
```

### 3. Test Auto-Discovery

```bash
source ~/.zshrc
```

This will:
- Auto-discover all `*.symlink` files/folders
- Create symlinks to `~/.*` locations
- Report success/failure counts

### 4. Verify Symlinks

```bash
ls -la ~ | grep "^l" | grep -E "(ssh|bin|aliases|gitconfig|vimrc|zlogout|zprofile|Brewfile|macos-defaults|npmrc-packages|zshrc.local)"
```

You should see all symlinks pointing to your iCloud folder.

## Edge Cases (Keep in CUSTOM_SYMLINKS)

Use explicit `CUSTOM_SYMLINKS` for:

1. **No leading dot**: `Code.symlink` → `~/Code` (not `~/.Code`)
2. **Custom target path**: `notes.symlink` → `~/Documents/Notes`
3. **Renamed targets**: `personal-aliases.symlink` → `~/.aliases`

Example:

```bash
CUSTOM_SYMLINKS=(
  "$CLOUD_FOLDER/Code.symlink|~/Code"  # No leading dot
  "$CLOUD_FOLDER/notes.symlink|~/Documents/Notes"  # Custom path
)
```

## Rollback

If something goes wrong:

1. Restore original filenames in iCloud
2. Restore original `CUSTOM_SYMLINKS` array in `.zshrc`
3. Clear state: `rm ~/.dots/symlinks`
4. Re-source: `source ~/.zshrc`

## Benefits

- **Zero configuration** for standard dotfiles
- **Self-documenting** naming in iCloud
- **Easier to add** new dotfiles (just rename with `.symlink`)
- **Explicit array** still available for edge cases

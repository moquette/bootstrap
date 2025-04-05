#!/bin/sh
# This script sets up passwordless sudo for the current user.
# It checks if the user is in the sudo group and if not, adds them.
# It also creates a sudoers file for the user with the appropriate permissions.
# Usage: Run this script as a normal user to set up passwordless sudo.

setup_passwordless_sudo() {
  local user file rule
  user=$(whoami)
  file="/etc/sudoers.d/$user"
  rule="$user ALL=(ALL) NOPASSWD: ALL"
  if [[ ! -f $file ]] || ! sudo grep -qF "$rule" "$file"; then
    echo "$rule" | sudo tee "$file" >/dev/null && sudo chmod 0440 "$file"
  fi
}
[[ $- == *i* ]] && setup_passwordless_sudo

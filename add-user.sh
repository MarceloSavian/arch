#!/usr/bin/env bash
# Add another desktop user with the same setup as the main one:
#   - account in wheel (sudo) + nordvpn groups, password prompt
#   - sudo verified (adds a %wheel sudoers rule only if wheel can't sudo yet)
#   - own copy of this repo, dotfiles stowed, desktop defaults (install.sh --user)
#   - per-user programs: Claude Code
# System packages (Chrome, Spotify, Steam, NordVPN, ...) are system-wide already.
#
#   ~/arch/add-user.sh <username> ["Display Name"]
#
# Run from a real terminal as an existing sudo user (it asks for passwords).
set -euo pipefail

NEW="${1:?usage: add-user.sh <username> [\"Display Name\"]}"
NAME="${2:-$NEW}"
REPO="$(cd "$(dirname "$0")" && pwd)"

step() { printf '\n\033[1;35m==> %s\033[0m\n' "$*"; }

[[ "$NEW" =~ ^[a-z_][a-z0-9_-]*$ ]] || { echo "Username must be lowercase (e.g. alice)."; exit 1; }

GROUPS_LIST=wheel
getent group nordvpn >/dev/null && GROUPS_LIST+=,nordvpn

step "1/5 Account '$NEW' ($NAME)"
if id "$NEW" >/dev/null 2>&1; then
    echo "User exists - making sure groups are set."
    sudo usermod -aG "$GROUPS_LIST" "$NEW"
else
    sudo useradd -m -s /bin/bash -c "$NAME" -G "$GROUPS_LIST" "$NEW"
    echo "Set a password for $NEW:"
    sudo passwd "$NEW"
fi
id "$NEW"

step "2/5 sudo"
if ! sudo -l -U "$NEW" | grep -q '(ALL'; then
    echo "wheel has no sudo rule yet - adding /etc/sudoers.d/10-wheel"
    tmp=$(mktemp)
    echo '%wheel ALL=(ALL:ALL) ALL' > "$tmp"
    sudo visudo -cf "$tmp"            # refuse to install a broken rule
    sudo install -m440 -o root -g root "$tmp" /etc/sudoers.d/10-wheel
    rm -f "$tmp"
fi
sudo -l -U "$NEW" | grep '(ALL'

HOME_NEW="$(getent passwd "$NEW" | cut -d: -f6)"

step "3/5 Copy dotfiles repo -> $HOME_NEW/arch"
if [ ! -d "$HOME_NEW/arch/.git" ]; then
    sudo cp -a "$REPO" "$HOME_NEW/arch"
    sudo chown -R "$NEW:$NEW" "$HOME_NEW/arch"
    # don't inherit the main user's git identity
    sudo -u "$NEW" git -C "$HOME_NEW/arch" config --unset user.name  || true
    sudo -u "$NEW" git -C "$HOME_NEW/arch" config --unset user.email || true
else
    echo "Already there - leaving it alone."
fi

step "4/5 Per-user setup (dotfiles, defaults)"
sudo -u "$NEW" -H env XDG_CURRENT_DESKTOP=Hyprland \
    dbus-run-session -- "$HOME_NEW/arch/install.sh" --user

step "5/5 Per-user programs: Claude Code"
if sudo -u "$NEW" -H test -x "$HOME_NEW/.local/bin/claude"; then
    echo "Claude Code already installed."
else
    sudo -u "$NEW" -H bash -c 'curl -fsSL https://claude.ai/install.sh | bash'
fi

cat <<EOF

Done. $NEW can log in from SDDM. On first login they should:
  * nordvpn login                      (their own NordVPN account)
  * claude                             (sign in to Claude Code)
  * Chrome: Settings > System > turn OFF "Continue running background apps"
EOF

#!/usr/bin/env bash
# Full setup for this dotfiles repo on a fresh (or existing) Arch install.
# Idempotent: safe to re-run. Run as your normal user from anywhere - it calls sudo
# itself (it will ask for your password, so run it in a real terminal).
#
#   ~/arch/install.sh            full setup (system + this user)
#   ~/arch/install.sh --user     per-user setup only (no sudo): dotfiles, defaults.
#                                Used by add-user.sh for additional accounts.
#
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
BACKUP="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
HAS_NVIDIA=$(lspci | grep -qi 'nvidia' && echo 1 || echo 0)

MODE=full
[ "${1:-}" = "--user" ] && MODE=user
system_only() { [ "$MODE" = full ]; }

step() { printf '\n\033[1;35m==> %s\033[0m\n' "$*"; }

[ "$(id -u)" -ne 0 ] || { echo "Run as your normal user, not root/sudo."; exit 1; }

# ---------------------------------------------------------------------------
if system_only; then
step "1/11 Enable multilib (needed for Steam / 32-bit drivers)"
if ! grep -q '^\[multilib\]' /etc/pacman.conf; then
    sudo sed -i '/^#\[multilib\]$/{s/^#//;n;s/^#//}' /etc/pacman.conf
fi

# ---------------------------------------------------------------------------
step "2/11 Official packages"
PKGS=(
    # compositor + desktop
    hyprland hypridle hyprpicker awww swaync
    waybar wofi kitty yazi thunar neovim
    # login
    sddm qt5-graphicaleffects
    # audio (without these there is NO sound at all)
    pipewire pipewire-pulse pipewire-alsa wireplumber pavucontrol
    # screenshots / clipboard / OCR
    grim slurp swappy wl-clipboard cliphist tesseract tesseract-data-eng
    # hardware + tray
    brightnessctl playerctl polkit-kde-agent network-manager-applet
    bluez bluez-utils blueman kdeconnect
    # tools used by scripts
    jq stow rsync python pacman-contrib libnotify qt6ct github-cli mesa-utils
    # themes + fonts
    gnome-themes-extra breeze-icons
    noto-fonts noto-fonts-emoji otf-font-awesome ttf-nerd-fonts-symbols
    ttf-input-nerd ttf-jetbrains-mono-nerd ttf-material-icons
    # build tools for AUR
    base-devel git
    # Steam (32-bit Vulkan drivers named explicitly so pacman doesn't prompt)
    lib32-mesa lib32-vulkan-radeon steam
)
if [ "$HAS_NVIDIA" = 1 ]; then
    PKGS+=(nvidia-open nvidia-utils lib32-nvidia-utils nvidia-prime)
fi
sudo pacman -Syu --needed --noconfirm "${PKGS[@]}"

# ---------------------------------------------------------------------------
step "3/11 yay (AUR helper)"
# Don't build/install -debug packages for AUR builds (makepkg default).
mkdir -p "$HOME/.config/pacman"
grep -qs '!debug' "$HOME/.config/pacman/makepkg.conf" || \
    echo 'OPTIONS+=(!debug)' >> "$HOME/.config/pacman/makepkg.conf"
if ! command -v yay >/dev/null; then
    tmp=$(mktemp -d)
    git clone https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
    (cd "$tmp/yay-bin" && makepkg -si --noconfirm)
    rm -rf "$tmp"
fi

# ---------------------------------------------------------------------------
step "4/11 AUR packages"
yay -S --needed --noconfirm \
    otf-monocraft bibata-cursor-theme \
    google-chrome spotify nordvpn-bin
fi  # system_only (steps 1-4)

# ---------------------------------------------------------------------------
step "5/11 Back up conflicting dotfiles -> $BACKUP"
for f in .config/hypr/hyprland.lua .config/hypr/hyprland.conf \
         .bashrc .bash_profile .bash_logout .gtkrc-2.0 \
         .config/gtk-3.0/settings.ini .config/gtk-4.0/settings.ini; do
    if [ -e "$HOME/$f" ] && [ ! -L "$HOME/$f" ]; then
        mkdir -p "$BACKUP/$(dirname "$f")"
        mv -v "$HOME/$f" "$BACKUP/$f"
    fi
done

# ---------------------------------------------------------------------------
step "6/11 Stow user configs"
cd "$REPO"
# Drop broken links left by files that were removed from the repo (only links that
# point into this repo; e.g. an old ~/.zshrc -> arch/shell/.zshrc).
find "$HOME" -maxdepth 5 -xtype l -lname "*$(basename "$REPO")/*" -print -delete 2>/dev/null || true
# Pre-create dirs that apps also write into, so stow links files, not the dir.
mkdir -p "$HOME/.config/hypr" "$HOME/.config/kitty" "$HOME/.config/gtk-3.0" \
         "$HOME/.config/gtk-4.0" "$HOME/.local/bin" "$HOME/.local/share/applications"
stow -R -v -t "$HOME" hypr waybar wofi kitty yazi shell
stow -R -v --no-folding -t "$HOME" gtk
[ "$HAS_NVIDIA" = 1 ] && stow -R -v --no-folding -t "$HOME" nvidia
mkdir -p "$HOME/wallpapers" "$HOME/Documents/projects" "$HOME/Pictures/Screenshots"
cp -n wallpapers/wallpapers/*.png "$HOME/wallpapers/"

# ---------------------------------------------------------------------------
if system_only; then
step "7/11 SDDM theme"
sudo cp -r sddm/cyberpunk-mr /usr/share/sddm/themes/
sudo chown -R root:root /usr/share/sddm/themes/cyberpunk-mr
sudo chmod -R a+rX /usr/share/sddm/themes/cyberpunk-mr
sudo install -d /etc/sddm.conf.d
printf '[Theme]\nCurrent=cyberpunk-mr\n' | sudo tee /etc/sddm.conf.d/theme.conf >/dev/null

# ---------------------------------------------------------------------------
step "8/11 Login-screen Xorg settings (no VT switching; iGPU only)"
sudo install -d /etc/X11/xorg.conf.d
sudo rm -f /etc/X11/xorg.conf.d/10-no-gpu-hotplug.conf   # old name
sudo install -m644 "$REPO/system/xorg.conf.d/10-sddm-greeter.conf" /etc/X11/xorg.conf.d/

# ---------------------------------------------------------------------------
step "9/11 Services"
sudo systemctl enable sddm bluetooth NetworkManager
sudo systemctl enable --now nordvpnd
sudo systemctl --global enable hypridle   # every user (lock before sleep, restore workspace)
sudo usermod -aG nordvpn "$USER"   # takes effect after next login
fi  # system_only (steps 7-9)
systemctl --user enable pipewire pipewire-pulse wireplumber hypridle 2>/dev/null || true

# ---------------------------------------------------------------------------
step "10/11 Desktop defaults"
xdg-settings set default-web-browser google-chrome.desktop
xdg-mime default google-chrome.desktop text/html x-scheme-handler/http x-scheme-handler/https x-scheme-handler/about x-scheme-handler/unknown
xdg-mime default thunar.desktop inode/directory
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark
gsettings set org.gnome.desktop.interface icon-theme breeze-dark
gsettings set org.gnome.desktop.interface cursor-theme Bibata-Modern-Classic

# ---------------------------------------------------------------------------
step "11/11 Check Hyprland config"
# Hyprland refuses to run without XDG_RUNTIME_DIR (unset under `sudo -u`, e.g. add-user.sh).
rt="${XDG_RUNTIME_DIR:-}"; [ -n "$rt" ] || rt=$(mktemp -d)
XDG_RUNTIME_DIR="$rt" Hyprland --verify-config -c "$HOME/.config/hypr/hyprland.lua" 2>&1 \
    | sed -n '/parsing result/,$p' || echo "WARNING: Hyprland config check failed - run it again from a desktop session."
[ "$rt" = "${XDG_RUNTIME_DIR:-}" ] || rm -rf "$rt"

cat <<'EOF'

Done. Remaining manual steps:
  * Reboot (or log out and back in) - needed for group membership + PATH.
  * nordvpn login            (opens a browser to sign in)
  * gh auth login && gh auth setup-git   (to push this repo)
  * Chrome: Settings > System > turn OFF "Continue running background apps"
    (otherwise SUPER+Q leaves Chrome running and the NVIDIA launcher refuses)
EOF

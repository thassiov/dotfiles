#!/bin/bash
# Setup DDC/CI brightness control for external monitors
# Run this once to install ddcutil, load i2c-dev, and configure permissions.
# After running, log out and back in for group changes to take effect.

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[+]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[x]${NC} $1"; }

# --- 1. Install ddcutil ---
if command -v ddcutil &>/dev/null; then
  info "ddcutil is already installed ($(ddcutil --version 2>/dev/null | head -1))"
else
  info "Installing ddcutil..."
  sudo pacman -S --noconfirm ddcutil
fi

# --- 2. Load i2c-dev kernel module ---
if lsmod | grep -q '^i2c_dev'; then
  info "i2c-dev module is already loaded"
else
  info "Loading i2c-dev kernel module..."
  sudo modprobe i2c-dev
fi

# Make it persistent across reboots
if [[ -f /etc/modules-load.d/i2c-dev.conf ]] && grep -q 'i2c-dev' /etc/modules-load.d/i2c-dev.conf; then
  info "i2c-dev is already set to load on boot"
else
  info "Making i2c-dev load on boot..."
  echo 'i2c-dev' | sudo tee /etc/modules-load.d/i2c-dev.conf > /dev/null
fi

# --- 3. Set up udev rules for permissions ---
UDEV_RULE="/etc/udev/rules.d/60-ddcutil-i2c.rules"
if [[ -f "$UDEV_RULE" ]]; then
  info "ddcutil udev rules already exist"
else
  info "Installing udev rules for i2c device permissions..."
  # ddcutil >= 2.0 ships these rules; copy from package data if available
  if [[ -f /usr/share/ddcutil/data/60-ddcutil-i2c.rules ]]; then
    sudo cp /usr/share/ddcutil/data/60-ddcutil-i2c.rules "$UDEV_RULE"
  else
    # Fallback: grant access to logged-in user via uaccess tag
    cat <<'EOF' | sudo tee "$UDEV_RULE" > /dev/null
SUBSYSTEM=="i2c-dev", KERNEL=="i2c-[0-9]*", ATTRS{class}=="0x030000", TAG+="uaccess"
SUBSYSTEM=="dri", KERNEL=="card[0-9]*", TAG+="uaccess"
EOF
  fi
  info "Reloading udev rules..."
  sudo udevadm control --reload-rules
  sudo udevadm trigger
fi

# --- 4. Add user to i2c group (fallback for non-seat sessions) ---
if getent group i2c &>/dev/null; then
  info "i2c group exists"
else
  info "Creating i2c group..."
  sudo groupadd i2c
fi

if id -nG | grep -qw i2c; then
  info "User $(whoami) is already in the i2c group"
else
  info "Adding $(whoami) to i2c group..."
  sudo usermod -aG i2c "$(whoami)"
  warn "You need to log out and back in for group membership to take effect"
fi

# --- 5. Verify ---
echo ""
info "Checking for /dev/i2c-* devices..."
if ls /dev/i2c-* &>/dev/null; then
  echo "  Found: $(ls /dev/i2c-* | tr '\n' ' ')"
else
  error "No /dev/i2c-* devices found. The i2c-dev module may not have loaded correctly."
  exit 1
fi

echo ""
info "Detecting monitors via ddcutil (this may take a few seconds)..."
echo ""
sudo ddcutil detect 2>&1

echo ""
echo "---"
info "Setup complete."
echo ""
echo "  Next steps:"
echo "    1. Log out and back in (for i2c group membership)"
echo "    2. Test without sudo:  ddcutil detect"
echo "    3. Read brightness:    ddcutil getvcp 10 --display 1"
echo "    4. Set brightness:     ddcutil setvcp 10 50 --display 1"
echo ""
echo "  If 'ddcutil detect' finds no displays after re-login,"
echo "  check 'ddcutil environment' for diagnostics."

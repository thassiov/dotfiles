#!/bin/bash
#
# Install lid-grace: lid close grace period handler
#
# Run with: sudo bash install.sh
#
# What it does:
#   1. Copies lid-grace script to /usr/local/bin/
#   2. Installs systemd service unit
#   3. Configures logind to ignore lid events (handled by our script)
#   4. Enables and starts the service
#
# Behavior after install:
#   - Close lid → 15s grace period → suspend if no external display
#   - Open lid within 15s → cancel suspend
#   - Close lid while docked → no suspend (external display detected)
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: run with sudo"
    exit 1
fi

echo "=== Installing lid-grace ==="

echo "[1/4] Installing script to /usr/local/bin/lid-grace..."
cp "$SCRIPT_DIR/lid-grace" /usr/local/bin/lid-grace
chmod 755 /usr/local/bin/lid-grace

echo "[2/4] Installing systemd service..."
cp "$SCRIPT_DIR/lid-grace.service" /etc/systemd/system/lid-grace.service

echo "[3/4] Installing logind drop-in..."
mkdir -p /etc/systemd/logind.conf.d
cp "$SCRIPT_DIR/90-lid-grace.conf" /etc/systemd/logind.conf.d/90-lid-grace.conf

echo "[4/4] Enabling and starting..."
systemctl daemon-reload
systemctl restart systemd-logind
systemctl enable --now lid-grace.service

echo ""
echo "=== Done ==="
echo ""
echo "Commands:"
echo "  journalctl -u lid-grace -f     # Watch logs"
echo "  systemctl status lid-grace     # Check status"
echo ""
echo "To change grace period (default 15s):"
echo "  sudo systemctl edit lid-grace"
echo "  [Service]"
echo "  Environment=LID_GRACE_SECONDS=30"
echo ""
echo "To uninstall: sudo bash $(dirname "$0")/uninstall.sh"

#!/bin/bash
#
# Uninstall lid-grace and restore default logind lid handling.
#
# Run with: sudo bash uninstall.sh
#

set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: run with sudo"
    exit 1
fi

echo "=== Uninstalling lid-grace ==="

echo "[1/4] Stopping and disabling service..."
systemctl disable --now lid-grace.service 2>/dev/null || true

echo "[2/4] Removing files..."
rm -f /usr/local/bin/lid-grace
rm -f /etc/systemd/system/lid-grace.service
rm -f /etc/systemd/logind.conf.d/90-lid-grace.conf

echo "[3/4] Reloading systemd..."
systemctl daemon-reload

echo "[4/4] Restoring default logind lid handling..."
systemctl restart systemd-logind

echo ""
echo "=== Done. Default lid behavior (suspend on close) restored. ==="

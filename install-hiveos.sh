#!/usr/bin/env bash
# XMRig No-Fee Installation Script for HiveOS
# Usage: curl -s https://raw.githubusercontent.com/JustAResearcher/xmrig-no-fee/main/install-hiveos.sh | bash

set -e

echo "Installing XMRig No-Fee for HiveOS..."

# Download and extract
cd /tmp
wget -q https://github.com/JustAResearcher/xmrig-no-fee/releases/download/v1.0-no-fee-rebuilt/xmrig-no-fee.tar.gz
tar -xzf xmrig-no-fee.tar.gz

# Find existing XMRig installation
XMRIG_PATH=$(find /hive/miners -name "xmrig" -type f 2>/dev/null | grep -E "xmrig/[0-9]" | head -1)

if [ -z "$XMRIG_PATH" ]; then
  echo "XMRig not found in /hive/miners. Creating custom miner directory..."
  mkdir -p /hive/miners/custom/xmrig-nofee/6.24.0
  XMRIG_PATH="/hive/miners/custom/xmrig-nofee/6.24.0/xmrig"
  cp /tmp/xmrig "$XMRIG_PATH"
  chmod +x "$XMRIG_PATH"
  echo "Installed to: $XMRIG_PATH"
  echo "Use 'custom/xmrig-nofee' as miner name in Flight Sheet"
else
  # Backup and replace
  [ ! -f "${XMRIG_PATH}.original" ] && cp "$XMRIG_PATH" "${XMRIG_PATH}.original"
  cp /tmp/xmrig "$XMRIG_PATH"
  chmod +x "$XMRIG_PATH"
  echo "Replaced: $XMRIG_PATH"
  echo "Original backed up to: ${XMRIG_PATH}.original"
  echo "Use regular XMRig Flight Sheet"
fi

# Cleanup
rm -f /tmp/xmrig /tmp/config.json /tmp/start.sh /tmp/xmrig-no-fee.tar.gz

$XMRIG_PATH --version

echo "SUCCESS! No-fee XMRig installed."
echo "Now create/apply your Tari Flight Sheet in HiveOS dashboard."

#!/bin/bash
# Deploy XMRig no-fee to all HiveOS rigs via HiveOS API

# Download and install on this rig
cd /tmp
wget -O xmrig-no-fee.tar.gz https://github.com/JustAResearcher/xmrig-no-fee/releases/download/v1.0-no-fee-rebuilt/xmrig-no-fee.tar.gz
tar -xzf xmrig-no-fee.tar.gz

# Find existing xmrig installation
XMRIG_PATH=$(which xmrig 2>/dev/null || find /hive/miners -name xmrig -type f 2>/dev/null | head -1)

if [ -n "$XMRIG_PATH" ]; then
    echo "Found XMRig at: $XMRIG_PATH"
    # Backup original
    cp "$XMRIG_PATH" "${XMRIG_PATH}.backup-$(date +%Y%m%d)"
    # Replace with no-fee version
    cp xmrig-no-fee/xmrig-no/xmrig "$XMRIG_PATH"
    chmod +x "$XMRIG_PATH"
    echo "Replaced XMRig binary with no-fee version"
else
    echo "XMRig not found - installing to /usr/local/bin"
    cp xmrig-no-fee/xmrig-no/xmrig /usr/local/bin/xmrig
    chmod +x /usr/local/bin/xmrig
fi

# Cleanup
rm -rf xmrig-no-fee.tar.gz xmrig-no-fee

echo "Installation complete. Restart your miner to use no-fee version."

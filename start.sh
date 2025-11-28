#!/bin/sh
# XMRig Custom Miner Startup Script
# This script ensures the binary has execute permissions and starts XMRig with the config.

set -e

# Ensure the binary is executable
chmod +x ./xmrig

# Start XMRig with the provided config.
# HiveOS may pass additional arguments here via "$@"
exec ./xmrig --config=config.json "$@"

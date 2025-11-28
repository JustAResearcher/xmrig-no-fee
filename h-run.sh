#!/usr/bin/env bash

cd $MINER_DIR/$MINER_VER

# Read the config
[[ -f xmrig.conf ]] && source xmrig.conf || { echo "No config found"; exit 1; }

# Run xmrig with command-line args
./xmrig $conf 2>&1

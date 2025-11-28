#!/usr/bin/env bash

cd $MINER_DIR/$MINER_VER

# Run xmrig with config file
./xmrig --config=config.json 2>&1

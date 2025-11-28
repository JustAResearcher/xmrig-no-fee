#!/usr/bin/env bash
# HiveOS config generator for XMRig no-fee

[[ -z $CUSTOM_TEMPLATE ]] && echo -e "${YELLOW}CUSTOM_TEMPLATE is empty${NOCOLOR}" && return 1
[[ -z $CUSTOM_URL ]] && echo -e "${YELLOW}CUSTOM_URL is empty${NOCOLOR}" && return 1

# Build config.json from template
conf_file="$MINER_DIR/$MINER_VER/config.json"

cat > $conf_file <<EOF
{
    "autosave": true,
    "donate-level": 0,
    "cpu": true,
    "opencl": false,
    "cuda": false,
    "pools": [
        {
            "url": "$CUSTOM_URL",
            "user": "$CUSTOM_TEMPLATE",
            "pass": "${CUSTOM_PASS:-x}",
            "keepalive": true
        }
    ],
    "randomx": {
        "1gb-pages": true
    },
    "http": {
        "enabled": true,
        "host": "127.0.0.1",
        "port": 16000
    }
}
EOF

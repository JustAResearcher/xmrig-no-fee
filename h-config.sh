#!/usr/bin/env bash
# HiveOS config generator for XMRig no-fee

[[ -z $CUSTOM_TEMPLATE ]] && echo -e "${YELLOW}CUSTOM_TEMPLATE is empty${NOCOLOR}" && return 1
[[ -z $CUSTOM_URL ]] && echo -e "${YELLOW}CUSTOM_URL is empty${NOCOLOR}" && return 1

conf="-o $CUSTOM_URL"

# Add wallet/user
[[ ! -z $CUSTOM_TEMPLATE ]] && conf+=" -u $CUSTOM_TEMPLATE"

# Add password/worker name
[[ ! -z $CUSTOM_PASS ]] && conf+=" -p $CUSTOM_PASS"

# Add extra user config options from flight sheet
[[ ! -z $CUSTOM_USER_CONFIG ]] && conf+=" $CUSTOM_USER_CONFIG"

# Output config
echo "$conf" > $MINER_DIR/$MINER_VER/xmrig.conf

#!/usr/bin/env bash

# Try to get stats from XMRig API
stats_raw=$(curl -s http://127.0.0.1:16000/1/summary 2>/dev/null)

if [[ $? -ne 0 || -z $stats_raw ]]; then
  # No API response, return basic stats
  echo "No stats available"
  exit 1
fi

# Parse JSON for hashrate and shares
khs=$(echo $stats_raw | jq -r '.hashrate.total[0] // 0' 2>/dev/null)
shares_good=$(echo $stats_raw | jq -r '.results.shares_good // 0' 2>/dev/null)
shares_total=$(echo $stats_raw | jq -r '.results.shares_total // 0' 2>/dev/null)

# Convert to MH/s if needed
if [[ ! -z $khs && $khs != "null" ]]; then
  khs=$(echo "scale=2; $khs / 1000" | bc)
fi

# Output in HiveOS format
stats=$(jq -n \
  --arg khs "$khs" \
  --arg shares_good "$shares_good" \
  --arg shares_total "$shares_total" \
  '{$khs, $shares_good, $shares_total}')

echo "$stats"

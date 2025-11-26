# XMRig No-Fee Custom Miner for HiveOS

This is a pre-compiled, **no-fee developer donation** build of XMRig v6.24.0 optimized for HiveOS.

## Features

- **Zero developer donation**: `donate-level` is set to 0 in the bundled config
- **Linux x64 static binary**: Runs on any x64 Linux system (HiveOS, Ubuntu, Debian, etc.)
- **Easy HiveOS integration**: Use as a Custom Miner in HiveOS Flight Sheets
- **Pre-configured**: Just edit `config.json` with your pool URL and wallet address

## Contents

- `xmrig` — Precompiled Linux x64 binary
- `config.json` — Configuration template (edit with your pool and wallet)
- `start.sh` — Startup wrapper script
- `SHA256SUMS` — Checksum for verification

## Quick Start

### On Linux / HiveOS console:

1. Download and extract:
   ```bash
   cd /tmp
   wget https://github.com/<your-username>/<repo-name>/releases/download/v1.0-no-fee/xmrig-no-fee.tar.gz
   tar -xzvf xmrig-no-fee.tar.gz
   cd xmrig-release
   ```

2. Edit the config:
   ```bash
   nano config.json
   ```
   Replace `POOL_URL` and `YOUR_WALLET_ADDRESS` with your actual values.

3. Test the miner:
   ```bash
   chmod +x xmrig
   ./xmrig --config=config.json
   ```

### On HiveOS (via Custom Miner Flight Sheet):

1. In HiveOS web UI → Flight Sheets → Create Flight Sheet
2. Select **Miner**: Custom
3. Paste in the **URL** field:
   ```
   https://github.com/<your-username>/<repo-name>/releases/download/v1.0-no-fee/xmrig-no-fee.tar.gz
   ```
4. Save and apply to your worker(s)
5. HiveOS will download, extract, and run `start.sh` automatically
6. Edit the config via HiveOS console or SSH into the rig and edit `/hive/miners/custom/<miner_name>/config.json`

## Verification

To verify the integrity of the binary before running it:

```bash
sha256sum -c SHA256SUMS
```

Both files must be in the same directory.

## Configuration Notes

- **Pool URL**: Set to your mining pool (e.g., `pool.monero.example.com:3333`)
- **Wallet Address**: Your Monero wallet address
- **Donation**: Disabled (donate-level: 0)
- **Huge Pages**: Enabled by default (requires `vm.nr_hugepages` kernel setting)
- **CPU Threads**: Set automatically; tweak in config.json if needed

## Support & Issues

- For XMRig issues: https://github.com/xmrig/xmrig
- For this build: Check the GitHub Issues tab
- For HiveOS integration help: HiveOS Docs at https://hiveos.farm/knowledge

## License

XMRig is licensed under GPLv3. See the original repository for details.

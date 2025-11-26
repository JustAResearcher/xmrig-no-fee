# HiveOS Custom Miner Setup & Test Guide

This guide walks you through configuring and testing the XMRig no-fee miner on HiveOS.

## Part 1: Create Flight Sheet in HiveOS

### Step 1: Log into HiveOS Dashboard

1. Go to https://the.hiveos.farm
2. Log in with your HiveOS credentials
3. Navigate to **Rigs** → select your mining rig

### Step 2: Create or Edit Flight Sheet

1. In the left sidebar, click **Flight Sheets**
2. Click **Create Flight Sheet** (or edit an existing one)
3. Fill in the form:

   - **Name**: `XMRig No-Fee`
   - **Miner**: Select **Custom** from the dropdown
   - **URL**: Paste your GitHub release download link:
     ```
     https://github.com/<YOUR_USERNAME>/xmrig-no-fee/releases/download/v1.0-no-fee/xmrig-no-fee.tar.gz
     ```
   - **Extra Config** or **Command**: Leave empty (optional; start.sh handles execution)
   - **Pool** (if available): Select or skip (we'll configure in config.json)

4. Click **Save Flight Sheet**

### Step 3: Apply Flight Sheet to Your Rig

1. Go to **Rigs** and select your worker
2. In the top-right, select the Flight Sheet you just created from the dropdown
3. Click **Apply**
4. HiveOS will download and extract the archive automatically

---

## Part 2: Configure the Miner (First Run)

### Option A: Via HiveOS Console (Recommended)

1. In HiveOS Dashboard, go to **Rigs** → your worker
2. Click **Console** (or **Remote Shell** if available)
3. Navigate to the miner directory:
   ```bash
   cd /hive/miners/custom/xmrig-no-fee
   # or similar; path depends on HiveOS version
   ```

4. Edit the config:
   ```bash
   nano config.json
   ```

5. Find and replace:
   - `"POOL_URL"` → your actual pool URL (e.g., `pool.monero.example.com:3333`)
   - `"YOUR_WALLET_ADDRESS"` → your Monero wallet address

6. Save: `Ctrl+O`, then `Ctrl+X`

7. **IMPORTANT**: If you edited on Windows, fix line endings:
   ```bash
   dos2unix start.sh
   # or
   sed -i 's/\r$//' start.sh
   ```

8. Test the miner manually:
   ```bash
   chmod +x xmrig start.sh
   ./xmrig --config=config.json
   ```
   You should see the XMRig banner and start connecting to the pool.

9. Stop the test: `Ctrl+C`

### Option B: Via SSH (Advanced)

SSH into your rig:

```powershell
# From Windows PowerShell
ssh root@<rig-ip-address>
# or
ssh -i C:\path\to\key root@<rig-ip-address>
```

Then run the same commands as Option A.

### Option C: Via HiveOS Web UI Config Editor

If HiveOS has a built-in config editor:

1. Go to **Rigs** → your worker
2. Look for an **Edit Config** or **Settings** button
3. Navigate to the miner's `config.json`
4. Edit the pool URL and wallet address inline
5. Save and restart miner

---

## Part 3: Verify the Setup

### Check 1: HiveOS Dashboard Status

1. In the **Rigs** view, your worker should show:
   - Status: **Online** (green)
   - Miner: **Running** (if configured correctly)
   - Hash Rate: Should display after 30–60 seconds

### Check 2: Miner Logs

1. Click **Logs** or **Miner Logs** for your rig
2. Look for:
   - `XMRig` banner with version
   - `[cpu] accepted` or `[cpu] rejected` (share submissions)
   - No `error` or `connection refused` messages

### Check 3: Manual Console Test

From the rig console:

```bash
# Verify xmrig is running
ps aux | grep xmrig

# Check the log file (if logging enabled)
tail -f /hive/miners/custom/xmrig-no-fee/xmrig.log

# Test connectivity
./xmrig --config=config.json &
sleep 5
# You should see connection attempts and accepted shares
```

---

## Part 4: Troubleshooting

### Problem: Miner doesn't start after applying Flight Sheet

**Check:**
1. HiveOS downloaded the archive:
   ```bash
   ls -la /hive/miners/custom/xmrig-no-fee/
   ```
   You should see: `xmrig`, `config.json`, `start.sh`

2. Permissions are correct:
   ```bash
   chmod +x /hive/miners/custom/xmrig-no-fee/xmrig
   chmod +x /hive/miners/custom/xmrig-no-fee/start.sh
   ```

3. Line endings on `start.sh` (if edited on Windows):
   ```bash
   dos2unix /hive/miners/custom/xmrig-no-fee/start.sh
   ```

4. Test manually:
   ```bash
   cd /hive/miners/custom/xmrig-no-fee
   ./start.sh
   ```

### Problem: "Connection refused" or "Invalid pool URL"

**Check:**
- Pool URL is correct and reachable:
  ```bash
  nc -zv pool.monero.example.com 3333
  ```
- Pool URL in `config.json` doesn't have `http://` or `https://` (just hostname:port)
- Wallet address is valid for your pool

### Problem: Low hash rate or frequent rejected shares

**Check:**
1. CPU threads in config match your CPU core count:
   ```json
   "max-threads-hint": 100
   ```
   Set to actual thread count or tweak for performance.

2. Huge pages are enabled (Linux):
   ```bash
   cat /proc/meminfo | grep HugePages
   ```
   If 0, enable:
   ```bash
   sudo bash -c 'echo 1024 > /proc/sys/vm/nr_hugepages'
   ```

3. Try a different pool or check pool logs for your address

### Problem: Miner crashes immediately

**Check:**
1. Binary compatibility:
   ```bash
   file /hive/miners/custom/xmrig-no-fee/xmrig
   # Should show: ELF 64-bit LSB executable
   ldd /hive/miners/custom/xmrig-no-fee/xmrig
   # Should show all libraries found, not "not found"
   ```

2. Config JSON syntax:
   ```bash
   python3 -m json.tool /hive/miners/custom/xmrig-no-fee/config.json
   ```
   Should output without errors.

3. Run with verbose output:
   ```bash
   ./xmrig --config=config.json -v
   ```

---

## Part 5: Performance Optimization

### CPU Thread Count

In `config.json`, adjust `max-threads-hint`:

```json
"max-threads-hint": 75
```

- **75**: Use 75% of available threads (recommended for shared systems)
- **100**: Use all available threads
- **0**: Automatic (HiveOS default)

### Huge Pages (1GB)

Enable in config:

```json
"randomx": {
    "1gb-pages": true
}
```

Then on the rig:

```bash
# Allocate 1GB huge pages (requires root)
echo 1 | sudo tee /proc/sys/vm/nr_hugepages_madvise
```

### Power Efficiency vs. Hash Rate

- **Max performance**: `1gb-pages: true`, `max-threads-hint: 100`, `asm: true`
- **Balanced**: `1gb-pages: false`, `max-threads-hint: 75`, `asm: true`
- **Power-efficient**: `1gb-pages: false`, `max-threads-hint: 50`, `asm: true`, consider `yield: true`

---

## Verification Checklist

- [ ] GitHub release created and public
- [ ] Release asset URL verified (`https://github.com/.../releases/download/.../xmrig-no-fee.tar.gz`)
- [ ] HiveOS Flight Sheet created with Custom miner
- [ ] Custom miner URL entered in Flight Sheet
- [ ] Flight Sheet applied to a worker
- [ ] Miner download/extract confirmed in console (`ls -la /hive/miners/custom/xmrig-no-fee/`)
- [ ] `config.json` edited with your pool URL and wallet address
- [ ] `start.sh` line endings corrected (if needed)
- [ ] Miner tested manually: `./xmrig --config=config.json`
- [ ] Miner shows in HiveOS Dashboard as **Running**
- [ ] Hash rate displaying in Dashboard (wait 1–2 minutes)
- [ ] Shares accepted in miner logs (no "rejected" errors)
- [ ] CPU usage and hash rate are stable (monitor for 5+ minutes)

---

## Quick Reference: Common Commands

```bash
# SSH into the rig
ssh root@<rig-ip-address>

# Navigate to miner
cd /hive/miners/custom/xmrig-no-fee

# Restart miner
killall xmrig; sleep 2; ./start.sh

# View logs
tail -100 /var/log/miner.log
# or if logged by xmrig itself
tail -100 xmrig.log

# Check CPU usage
top -n 1 -b | grep xmrig

# Test pool connectivity
nc -zv pool.monero.example.com 3333

# Fix Windows line endings
dos2unix start.sh config.json

# Verify binary format
file xmrig
ldd xmrig

# Check JSON syntax
python3 -m json.tool config.json
```

---

## Next Steps

- Monitor the miner in the HiveOS Dashboard for the first hour
- Adjust CPU thread count based on performance and heat
- Document your optimal config in a local file for future reinstalls
- Consider creating a backup of your configured `config.json`
- Check pool statistics to verify regular share submission

For further help:
- HiveOS docs: https://hiveos.farm/knowledge
- XMRig official: https://github.com/xmrig/xmrig
- Monero pools: https://miningpoolstats.stream/monero

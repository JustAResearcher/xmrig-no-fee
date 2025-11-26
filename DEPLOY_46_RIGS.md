# Deploy XMRig No-Fee to 46 Rigs

This guide covers deploying the updated XMRig package (with 1GB hugepages enabled) to your remaining 46 rigs.

## Release URL

```
https://github.com/JustAResearcher/xmrig-no-fee/releases/download/v1.0-no-fee/xmrig-no-fee.tar.gz
```

SHA256: `54E3B9BC6C6A5DFB5D28679AAF50215B2F9775F9ADB816B322055E6EA419FD6F`

---

## Method 1: HiveOS Flight Sheet (Recommended - No SSH Required)

**Best for:** Identical wallet/pool across all rigs, no per-host customization.

### Steps:

1. **Log in to HiveOS Dashboard**

2. **Navigate to Workers** and select your 46 rigs

3. **Create/Update Flight Sheet:**
   - Go to **Flight Sheets → New Flight Sheet**
   - Name: `XMRig No-Fee v1.0` (or similar)
   - Coin: Select your mining algorithm (e.g., Monero for RandomX)
   - Miner: `Custom miner`

4. **Configure Custom Miner:**
   - **Template:** Leave default or select Monero template
   - **Download URL:** 
     ```
     https://github.com/JustAResearcher/xmrig-no-fee/releases/download/v1.0-no-fee/xmrig-no-fee.tar.gz
     ```
   - **Unpack:** `xmrig-no-fee`
   - **Hash:** `54E3B9BC6C6A5DFB5D28679AAF50215B2F9775F9ADB816B322055E6EA419FD6F`
   - **Pool:** Your pool URL (e.g., `pool-global.tari.snipanet.com:3333`)
   - **Wallet:** Your wallet address
   - **Password:** `x`
   - **Extra Arguments:** *(leave empty, 1GB pages in config)*

5. **Apply to Rigs:**
   - Select the 46 rigs
   - **Action → Apply Flight Sheet → Select `XMRig No-Fee v1.0`**
   - Confirm

6. **Monitor:**
   - Rigs will download, extract, and start mining automatically
   - Check **Workers** tab for hashrate and status

---

## Method 2: Ansible (Best for Per-Host Wallet Customization)

**Best for:** Each rig has a different wallet or custom config.

### Prerequisites:

```powershell
# Install Ansible on your Windows machine
pip install ansible
# or
choco install ansible -y
```

### Steps:

1. **Download and edit inventory:**
   ```bash
   cp inventory-example.ini inventory.ini
   # Edit inventory.ini with your 46 rig IPs and wallets
   ```

2. **Create Ansible playbook (`deploy-46.yml`):**
   ```yaml
   ---
   - name: Deploy XMRig No-Fee to 46 Rigs
     hosts: hiveos_rigs
     tasks:
       - name: Download and extract XMRig package
         shell: |
           cd /hive/miners/custom
           rm -rf xmrig-no-fee
           wget https://github.com/JustAResearcher/xmrig-no-fee/releases/download/v1.0-no-fee/xmrig-no-fee.tar.gz
           tar -xzf xmrig-no-fee.tar.gz
           chmod +x xmrig-no-fee/xmrig xmrig-no-fee/start.sh
           rm xmrig-no-fee.tar.gz

       - name: Update config.json with host-specific wallet
         template:
           src: config.json.j2
           dest: /hive/miners/custom/xmrig-no-fee/config.json
         notify: restart xmrig

       - name: Start XMRig
         shell: cd /hive/miners/custom/xmrig-no-fee && ./start.sh &

     handlers:
       - name: restart xmrig
         shell: pkill -9 xmrig; sleep 1; cd /hive/miners/custom/xmrig-no-fee && ./start.sh &
   ```

3. **Run deployment:**
   ```bash
   ansible-playbook deploy-46.yml -i inventory.ini -u root
   ```

---

## Method 3: PowerShell Parallel SSH (Windows Native)

**Best for:** Quick bulk deployment with minimal setup.

### Prerequisites:

- SSH keys distributed to all rigs
- Create `rig_ips.txt` with one IP per line

### Steps:

1. **Create deployment script (`deploy-46.ps1`):**
   ```powershell
   param(
       [string[]]$RigIps,
       [string]$PoolUrl = "pool-global.tari.snipanet.com:3333",
       [string]$Wallet = "YOUR_WALLET_ADDRESS"
   )

   $deployCmd = @"
   cd /hive/miners/custom
   rm -rf xmrig-no-fee
   wget https://github.com/JustAResearcher/xmrig-no-fee/releases/download/v1.0-no-fee/xmrig-no-fee.tar.gz
   tar -xzf xmrig-no-fee.tar.gz
   chmod +x xmrig-no-fee/xmrig xmrig-no-fee/start.sh
   cd xmrig-no-fee
   ./start.sh &
   "@

   $RigIps | ForEach-Object -Parallel {
       $rig = $_
       ssh -i ~/.ssh/id_ed25519 root@$rig $using:deployCmd 2>&1 | Write-Host "[✓] $rig"
   } -ThrottleLimit 8
   ```

2. **Run deployment:**
   ```powershell
   $ips = Get-Content rig_ips.txt
   .\deploy-46.ps1 -RigIps $ips -PoolUrl "pool-global.tari.snipanet.com:3333" -Wallet "YOUR_WALLET"
   ```

---

## Method 4: HiveOS API (Programmatic Bulk Assignment)

**Best for:** Full automation and integration with monitoring systems.

### Steps:

1. **Get your HiveOS API key** from HiveOS Dashboard → Settings → API

2. **Create PowerShell script (`deploy-api.ps1`):**
   ```powershell
   param(
       [string]$ApiKey = "YOUR_HIVEOS_API_KEY",
       [string]$FlightSheetId = "12345"  # Get from HiveOS Dashboard
   )

   $headers = @{
       "Authorization" = "Bearer $ApiKey"
       "Content-Type" = "application/json"
   }

   $workers = Invoke-RestMethod -Uri "https://api2.hiveos.io/v2/workers" -Headers $headers | Select-Object -ExpandProperty data

   foreach ($worker in $workers) {
       $body = @{
           flight_sheet_id = $FlightSheetId
       } | ConvertTo-Json

       Invoke-RestMethod -Uri "https://api2.hiveos.io/v2/workers/$($worker.id)" `
           -Method PUT -Headers $headers -Body $body
   }
   ```

3. **Run deployment:**
   ```powershell
   .\deploy-api.ps1 -ApiKey "YOUR_KEY" -FlightSheetId "12345"
   ```

---

## Post-Deployment Verification

After deploying to all 46 rigs, verify:

### 1. Check XMRig is running:
```bash
ssh root@192.168.1.100 "ps aux | grep xmrig"
```

### 2. Verify 1GB hugepages are enabled:
```bash
ssh root@192.168.1.100 "sysctl vm.nr_hugepages; cat /sys/devices/system/node/node0/hugepages/hugepages-1048576kB/nr_hugepages"
```

### 3. Confirm donation is disabled (0% fee):
```bash
ssh root@192.168.1.100 "grep -i donate-level /hive/miners/custom/xmrig-no-fee/config.json"
```

Expected output: `"donate-level": 0`

### 4. Check pool connectivity:
```bash
ssh root@192.168.1.100 "tail -50 /hive/miners/custom/xmrig-no-fee/config.json | grep -E 'url|user'"
```

---

## Enable 1GB Hugepages on All 46 Rigs (Persistent)

After initial deployment, enable 1GB hugepages for 1-3% speedup:

### Option A: HiveOS manages it (some versions)
Check HiveOS Workers settings → Advanced → Hugepages

### Option B: Manual kernel boot parameter (one-time per rig)
```bash
# On each rig
ssh root@192.168.1.100 << 'EOF'
sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet hugepages=48 default_hugepagesz=1G"/' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
echo "Rebooting to enable 1GB hugepages..."
sudo reboot
EOF
```

### Option C: Bulk enable via Ansible
```bash
ansible-playbook enable-hugepages-ansible.yml -i inventory.ini
```

---

## Troubleshooting

### Issue: Rigs fail to download package
**Solution:** Check internet/DNS on rig. Test: `ssh root@RIG "wget https://github.com/.../xmrig-no-fee.tar.gz"`

### Issue: XMRig fails to start
**Solution:** Check permissions and dependencies. Log: `ssh root@RIG "cat /hive/miners/custom/xmrig-no-fee/xmrig --version"`

### Issue: Pool connection errors
**Solution:** Verify pool URL is correct. Test: `ssh root@RIG "nc -zv POOL_URL PORT"`

### Issue: 1GB hugepages still disabled
**Solution:** Requires kernel boot parameter and reboot. See "Enable 1GB Hugepages" section above.

---

## Summary

| Method | Setup Time | Automation | Best For |
|--------|-----------|-----------|----------|
| **Flight Sheet** | 5 min | Full | Identical config, no SSH |
| **Ansible** | 15 min | Full | Per-host wallets, repeatable |
| **PowerShell SSH** | 10 min | Full | Windows-native, quick |
| **HiveOS API** | 20 min | Full | Integration with monitoring |

**Recommended starting approach:** HiveOS Flight Sheet (Method 1) — fastest and no SSH required.

# Enable 1GB Hugepages on All 47 Rigs

1GB hugepages provide a **1-3% hashrate boost** for RandomX mining. Choose one of the methods below:

## Method 1: PowerShell Parallel SSH (Fastest on Windows)

**Prerequisites:**
- SSH key setup: SSH keys distributed to all rigs (see [SSH_SETUP.md](SSH_SETUP.md))
- PowerShell 7+ (or Windows PowerShell 5.1 with ssh client)

**Steps:**

1. Create a file `rig_ips.txt` with one IP per line:
   ```
   192.168.1.100
   192.168.1.101
   192.168.1.102
   ...
   192.168.1.146
   ```

2. Run the PowerShell script:
   ```powershell
   $ips = Get-Content rig_ips.txt
   .\enable-hugepages.ps1 -RigIps $ips -SshUser root -Threads 8
   ```

   **Output example:**
   ```
   [✓] 192.168.1.100 : 1GB hugepages enabled
   [✓] 192.168.1.101 : 1GB hugepages enabled
   Summary: 47 succeeded, 0 failed
   ```

---

## Method 2: Ansible (Best for Complex Deployments)

**Prerequisites:**
- Ansible installed: `pip install ansible` or `choco install ansible -y`
- SSH keys distributed to all rigs

**Steps:**

1. Update `inventory-example.ini` with your rig IPs:
   ```bash
   cp inventory-example.ini inventory.ini
   # Edit inventory.ini with your 47 rig IPs
   ```

2. Run the playbook:
   ```bash
   ansible-playbook enable-hugepages-ansible.yml -i inventory.ini
   ```

3. Verify:
   ```bash
   ansible hiveos_rigs -i inventory.ini -m shell -a "sysctl vm.nr_hugepages"
   ```

---

## Method 3: Manual per-Rig SSH

If you only have a few rigs or need per-rig confirmation:

```bash
ssh root@192.168.1.100 << 'EOF'
sysctl -w vm.nr_hugepages=$(nproc)
for i in $(find /sys/devices/system/node/node* -maxdepth 0 -type d 2>/dev/null);
do
    echo 3 > "$i/hugepages/hugepages-1048576kB/nr_hugepages" 2>/dev/null;
done
echo "1GB hugepages enabled"
EOF
```

---

## Verification

After enabling hugepages, verify on any rig:

```bash
ssh root@192.168.1.100 "sysctl vm.nr_hugepages; ls -la /sys/devices/system/node/node0/hugepages/hugepages-1048576kB/"
```

Expected output:
```
vm.nr_hugepages = 16
hugepages-1048576kB
```

Check XMRig config confirms `1gb-pages: true`:

```bash
ssh root@192.168.1.100 "grep -i 1gb-pages /hive/miners/custom/xmrig-no-fee/config.json"
```

---

## Notes

- Hugepages persist across reboots on HiveOS.
- XMRig must be restarted after hugepages are enabled for the setting to take effect.
- If using HiveOS Flight Sheet, the `config.json` already has `"1gb-pages": true` in the updated release.
- Rigs without sufficient memory may fail to allocate 1GB hugepages silently; monitor hashrate after enabling.

---

## Rollback

If you need to disable hugepages:

```bash
sysctl -w vm.nr_hugepages=0
pkill -9 xmrig
# Restart XMRig via Flight Sheet or manually
```

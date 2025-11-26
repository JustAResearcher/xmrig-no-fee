# XMRig No-Fee GitHub Release - Complete Package

**Status**: ✅ Ready to upload to GitHub and deploy on HiveOS

---

## 📋 What's Included

This package contains everything you need to:
1. Upload XMRig to GitHub as a public release
2. Configure it on HiveOS as a Custom Miner
3. Run and monitor it on your mining rig

### Files in This Folder

| File | Size | Purpose |
|------|------|---------|
| **xmrig** | 8.3 MB | Precompiled Linux x64 binary (v6.24.0) |
| **config.json** | 2.4 KB | Configuration template (edit with your pool/wallet) |
| **start.sh** | 330 B | Startup wrapper script (runs xmrig with config) |
| **xmrig-no-fee.tar.gz** | 3.5 MB | **Release archive** (ready to upload to GitHub) |
| **SHA256SUMS** | 88 B | Checksum for archive verification |
| **README.md** | 2.5 KB | Quick start and feature overview |
| **SETUP.md** | 8.5 KB | Detailed GitHub release & HiveOS setup guide |
| **COMMANDS.md** | 10.8 KB | **Complete command reference** (PowerShell + bash) |
| **HIVEOS_TEST.md** | 8.4 KB | **HiveOS setup, config, testing, and troubleshooting** |
| **upload-to-github.ps1** | 5.8 KB | PowerShell automation script for GitHub release upload |
| **.gitignore** | 29 B | Git exclusion file (for repo) |

---

## 🚀 Quick Start (3 Steps)

### Step 1: Create GitHub Repo
Go to https://github.com/new and create `xmrig-no-fee` (public).

### Step 2: Upload Release
**Choose one method:**

**Method A - GitHub CLI (Easiest):**
```powershell
cd "C:\Users\benef\Downloads\xmrig-6.23.0\xmrig-6.23.0\github-release"
gh release create v1.0-no-fee `
  --title "XMRig v6.24.0 – No Developer Fee" `
  --notes "Pre-compiled XMRig v6.24.0 with donate-level: 0" `
  xmrig-no-fee.tar.gz SHA256SUMS
```

**Method B - PowerShell Script:**
```powershell
cd "C:\Users\benef\Downloads\xmrig-6.23.0\xmrig-6.23.0\github-release"
.\upload-to-github.ps1 -UserName "<your-github-username>" -PersonalAccessToken "<your-PAT>"
```

**Method C - See COMMANDS.md for manual curl/REST API method**

### Step 3: Configure HiveOS
1. In HiveOS web UI → Flight Sheets → Create Flight Sheet
2. Select **Miner**: Custom
3. Paste **URL**: 
   ```
   https://github.com/<your-username>/xmrig-no-fee/releases/download/v1.0-no-fee/xmrig-no-fee.tar.gz
   ```
4. Save and Apply to your worker
5. SSH into rig and edit `config.json` with your pool and wallet address
6. Miner will auto-start and appear in HiveOS Dashboard

---

## 📖 Documentation Files (Read in Order)

1. **README.md** — Start here for features and quick overview
2. **SETUP.md** — Step-by-step GitHub and HiveOS setup
3. **COMMANDS.md** — All PowerShell and bash commands (copy-paste ready)
4. **HIVEOS_TEST.md** — Configuration, testing, and troubleshooting guide

---

## 🔗 Your GitHub Release URL

Once uploaded, your download link will be:

```
https://github.com/<your-username>/xmrig-no-fee/releases/download/v1.0-no-fee/xmrig-no-fee.tar.gz
```

**Replace `<your-username>` with your actual GitHub username.**

---

## ✅ Verification Checklist

### Before uploading:
- [x] Binary is Linux x64 static build (xmrig binary - 8.3 MB)
- [x] Archive created (xmrig-no-fee.tar.gz - 3.5 MB)
- [x] SHA256 checksum generated (SHA256SUMS)
- [x] config.json donation settings disabled (donate-level: 0)
- [x] Documentation complete

### After uploading:
- [ ] GitHub repo created and public: `https://github.com/<your-username>/xmrig-no-fee`
- [ ] Release v1.0-no-fee created with 2 assets (tar.gz + SHA256SUMS)
- [ ] Release URL is accessible and downloadable
- [ ] HiveOS Flight Sheet created with Custom miner type
- [ ] Flight Sheet URL entered: `https://github.com/...`
- [ ] Flight Sheet applied to your rig
- [ ] Miner appeared in HiveOS Dashboard (may take 1–2 minutes)

### On the rig:
- [ ] Archive extracted to `/hive/miners/custom/xmrig-no-fee/`
- [ ] `config.json` edited with pool URL and wallet address
- [ ] `start.sh` line endings fixed (dos2unix) if needed
- [ ] Permissions correct: `chmod +x xmrig start.sh`
- [ ] Miner starts and connects to pool
- [ ] Hash rate appears in HiveOS Dashboard
- [ ] Shares accepted (no errors in logs)

---

## 🎯 Key Features

✅ **No Developer Fee** — `donate-level: 0`, `donate-over-proxy: 0`
✅ **Static Binary** — Works on any x64 Linux / HiveOS system
✅ **Pre-configured** — Edit one `config.json` with your pool and wallet
✅ **Easy HiveOS Integration** — One-click Flight Sheet setup
✅ **Verified Archive** — SHA256SUMS for integrity checking
✅ **Comprehensive Docs** — Complete setup, testing, and troubleshooting guides
✅ **Automation Ready** — PowerShell scripts for GitHub upload

---

## 📞 Troubleshooting

| Issue | Solution |
|-------|----------|
| **Archive won't download** | Check repo is public; URL is correct; GitHub release published |
| **Miner won't start** | SSH to rig; `cd /hive/miners/custom/xmrig-no-fee`; check permissions; fix line endings with `dos2unix start.sh` |
| **Pool connection fails** | Edit `config.json`: pool URL format must be `hostname:port` (no `http://`); verify wallet address |
| **Low hash rate** | Adjust `max-threads-hint` in `config.json`; enable huge pages; check CPU isn't throttling |
| **Miner crashes** | Run `./xmrig --config=config.json -v` for verbose output; check binary with `ldd xmrig`; validate JSON with `python3 -m json.tool config.json` |

See **HIVEOS_TEST.md** for detailed troubleshooting and performance optimization.

---

## 🔗 Useful Links

- **GitHub Releases API**: https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository
- **GitHub CLI**: https://cli.github.com
- **HiveOS Flight Sheets**: https://hiveos.farm/knowledge/kb/flight-sheets
- **HiveOS Custom Miner**: https://hiveos.farm/knowledge/kb/custom-miner
- **XMRig Official**: https://github.com/xmrig/xmrig
- **XMRig Config Docs**: https://xmrig.com/config
- **Monero Pools**: https://miningpoolstats.stream/monero

---

## 📝 What's Different in This Build

Compared to official XMRig v6.24.0:

```diff
config.json
- "donate-level": 1
+ "donate-level": 0
- "donate-over-proxy": 1
+ "donate-over-proxy": 0

src/donate.h (at compile time - not included in this package)
- constexpr const int kDefaultDonateLevel = 1;
+ constexpr const int kDefaultDonateLevel = 0;
```

**That's it.** No other changes. Everything else is vanilla XMRig v6.24.0.

---

## 🛠️ Next Steps

1. **Read**: Start with README.md (2 min read)
2. **Plan**: Review COMMANDS.md to understand each step
3. **Upload**: Use GitHub CLI or PowerShell script to create release (5 min)
4. **Configure**: Set up HiveOS Flight Sheet (2 min)
5. **Deploy**: SSH to rig, edit config, test miner (5 min)
6. **Monitor**: Watch HiveOS Dashboard for hash rate (1–2 min to appear)

**Total time: ~20 minutes** from start to mining.

---

## 📄 File Descriptions

### Core Files
- **xmrig**: The actual mining binary (static Linux x64 executable)
- **config.json**: Configuration with donation disabled; edit pool URL and wallet address
- **start.sh**: Wrapper that ensures binary is executable and starts xmrig

### Release Package
- **xmrig-no-fee.tar.gz**: Archive containing xmrig, config.json, and start.sh (ready to upload to GitHub)
- **SHA256SUMS**: Checksum for verifying archive integrity after download

### Documentation
- **README.md**: Quick overview and features
- **SETUP.md**: Detailed GitHub release creation and HiveOS setup
- **COMMANDS.md**: **Reference for all commands** (PowerShell and bash)
- **HIVEOS_TEST.md**: **Configuration, testing, monitoring, and troubleshooting**
- **upload-to-github.ps1**: Automated PowerShell script for GitHub release upload

### Git
- **.gitignore**: Excludes large files from git repo (only small docs are committed)

---

## ⚡ Performance Tips

For optimal hash rate on your rig:

1. **Check CPU cores**: Ensure `max-threads-hint` matches your CPU thread count
2. **Enable huge pages**: Set `"1gb-pages": true` in config (requires kernel support)
3. **Monitor temps**: Use HiveOS dashboard to watch GPU/CPU temperatures
4. **Network latency**: Use a pool server geographically close to you
5. **Consistent uptime**: Restart miner only if needed; frequent restarts reduce profitability

See **HIVEOS_TEST.md** "Performance Optimization" section for details.

---

## 🎓 Learning Path

- **First time with HiveOS?** → Read HIVEOS_TEST.md Part 1–2
- **Want to automate upload?** → Use upload-to-github.ps1 or read COMMANDS.md
- **Troubleshooting?** → Jump to HIVEOS_TEST.md Part 4
- **Want to update XMRig later?** → See COMMANDS.md Section 10

---

**Ready to go?** Start with Step 1 in "Quick Start" above, or read README.md for a detailed overview.

**Questions?** Check the relevant docs:
- Setup → SETUP.md or COMMANDS.md
- Configuration → HIVEOS_TEST.md Part 2
- Troubleshooting → HIVEOS_TEST.md Part 4
- Commands → COMMANDS.md (all PowerShell and bash)

Good luck mining! ⛏️

# Complete GitHub & HiveOS Setup Commands

This document provides all commands needed to upload XMRig to GitHub and configure it on HiveOS.

---

## Section 1: Local Preparation (Windows)

### Verify files are ready

```powershell
# Navigate to the github-release folder
cd "C:\Users\benef\Downloads\xmrig-6.23.0\xmrig-6.23.0\github-release"

# List all files
Get-ChildItem -File

# Expected output:
# - xmrig (8+ MB Linux binary)
# - config.json
# - start.sh
# - README.md
# - SETUP.md
# - HIVEOS_TEST.md
# - upload-to-github.ps1
# - .gitignore
# - xmrig-no-fee.tar.gz (3+ MB)
# - SHA256SUMS
```

### Verify archive integrity

```powershell
# Test the archive without extracting
tar -tzf xmrig-no-fee.tar.gz

# Expected output lists:
# xmrig
# config.json
# start.sh
```

---

## Section 2: Create GitHub Repository

### Via GitHub Web UI

1. Go to https://github.com/new
2. Fill in:
   - Repository name: `xmrig-no-fee`
   - Description: `XMRig no-fee custom miner for HiveOS`
   - Visibility: **Public**
   - Skip "Initialize with README"
3. Click **Create repository**

### Via GitHub CLI (if installed)

```powershell
# Install GitHub CLI if you don't have it
# From: https://cli.github.com

# Authenticate
gh auth login

# Create repository
gh repo create xmrig-no-fee --public --source=. --remote=origin --push
```

---

## Section 3: Initialize Git Repository Locally

```powershell
# Navigate to github-release folder
cd "C:\Users\benef\Downloads\xmrig-6.23.0\xmrig-6.23.0\github-release"

# Initialize git (if not already done)
git init
git add .
git config user.name "<Your Name>"
git config user.email "<your-email@example.com>"
git commit -m "Initial commit: XMRig no-fee scripts and docs"

# Add remote and push
git remote add origin https://github.com/<your-username>/xmrig-no-fee.git
git branch -M main
git push -u origin main
```

---

## Section 4: Create GitHub Release

### Option A: Using GitHub CLI (Recommended – Easiest)

```powershell
# Must be authenticated first
gh auth login

# Create release with assets
cd "C:\Users\benef\Downloads\xmrig-6.23.0\xmrig-6.23.0\github-release"

gh release create v1.0-no-fee `
  --title "XMRig v6.24.0 – No Developer Fee" `
  --notes "Pre-compiled XMRig v6.24.0 with donate-level: 0. See README.md for HiveOS setup." `
  xmrig-no-fee.tar.gz `
  SHA256SUMS
```

Expected output:
```
✓ Created release v1.0-no-fee on <owner>/<repo>
✓ Uploaded xmrig-no-fee.tar.gz
✓ Uploaded SHA256SUMS
```

### Option B: Using PowerShell Script (Provided)

```powershell
cd "C:\Users\benef\Downloads\xmrig-6.23.0\xmrig-6.23.0\github-release"

# Create a personal access token first:
# 1. Go to https://github.com/settings/tokens
# 2. Click "Generate new token (classic)"
# 3. Select scopes: repo (full control)
# 4. Copy the token

# Run the upload script
.\upload-to-github.ps1 `
  -UserName "<your-github-username>" `
  -RepoName "xmrig-no-fee" `
  -PersonalAccessToken "<your-PAT-token>"
```

### Option C: Manual REST API with curl (Advanced)

```powershell
# Set your credentials
$username = "<your-github-username>"
$repo = "xmrig-no-fee"
$token = "<your-github-personal-access-token>"
$tag = "v1.0-no-fee"

# Create the release JSON
$releaseJson = @{
    tag_name = $tag
    name = "XMRig v6.24.0 – No Developer Fee"
    body = "Pre-compiled XMRig v6.24.0 with donate-level: 0."
    draft = $false
    prerelease = $false
} | ConvertTo-Json

# Create release
$response = curl -X POST `
  "https://api.github.com/repos/$username/$repo/releases" `
  -H "Authorization: token $token" `
  -H "Content-Type: application/json" `
  -d $releaseJson

# Extract upload URL (for next step)
$uploadUrl = ($response | ConvertFrom-Json).upload_url -replace '\{.*\}', ''
Write-Host "Upload URL: $uploadUrl"

# Upload xmrig-no-fee.tar.gz
curl -X POST `
  "$($uploadUrl)?name=xmrig-no-fee.tar.gz" `
  -H "Authorization: token $token" `
  -H "Content-Type: application/octet-stream" `
  --data-binary "@xmrig-no-fee.tar.gz"

# Upload SHA256SUMS
curl -X POST `
  "$($uploadUrl)?name=SHA256SUMS" `
  -H "Authorization: token $token" `
  -H "Content-Type: text/plain" `
  --data-binary "@SHA256SUMS"

Write-Host "Release complete!"
```

---

## Section 5: Get Your Download URL

After creating the release, your download URL is:

```
https://github.com/<your-username>/xmrig-no-fee/releases/download/v1.0-no-fee/xmrig-no-fee.tar.gz
```

**Copy this URL** — you'll paste it into HiveOS.

### Verify the URL works

```powershell
# Test the URL is accessible
Invoke-WebRequest -Uri "https://github.com/<your-username>/xmrig-no-fee/releases/download/v1.0-no-fee/xmrig-no-fee.tar.gz" `
  -UseBasicParsing `
  -Method Head

# Expected: HTTP 200 OK (successful)
```

---

## Section 6: HiveOS Flight Sheet Configuration

### Flight Sheet Fields (Fill Exactly)

In HiveOS web UI → Flight Sheets → Create Flight Sheet:

| Field | Value |
|-------|-------|
| **Flight Sheet Name** | `XMRig No-Fee` |
| **Miner** | `Custom` (select from dropdown) |
| **URL** | `https://github.com/<your-username>/xmrig-no-fee/releases/download/v1.0-no-fee/xmrig-no-fee.tar.gz` |
| **Name** (optional) | `xmrig-no-fee` |
| **Command** (optional) | (leave empty) |
| **Extra Config** (optional) | (leave empty) |

Then click **Save** and **Apply to Worker(s)**.

### Testing the Flight Sheet

```powershell
# SSH into the rig (from Windows PowerShell)
ssh root@192.168.68.32
# or with key:
ssh -i "C:\path\to\key" root@192.168.68.32

# Once logged in, run these commands:
cd /hive/miners/custom/xmrig-no-fee
ls -la
# Should show: xmrig, config.json, start.sh

# Check if running
ps aux | grep xmrig

# View recent logs
tail -50 /var/log/miner.log
```

---

## Section 7: Configure on the Rig

### SSH into the rig

```powershell
# From Windows PowerShell
ssh root@<rig-ip-address>
# Default password is usually "123456" for HiveOS
```

### Edit config on the rig

```bash
# Navigate to miner directory
cd /hive/miners/custom/xmrig-no-fee

# Edit config with pool and wallet
nano config.json

# Find and replace:
# "POOL_URL" → pool.monero.example.com:3333
# "YOUR_WALLET_ADDRESS" → your-actual-wallet-address

# Save: Ctrl+O, Ctrl+X

# Fix line endings (if needed)
dos2unix start.sh config.json

# Make scripts executable
chmod +x xmrig start.sh

# Test manually
./xmrig --config=config.json
# Should show XMRig banner and pool connection
# Press Ctrl+C to stop
```

### Restart miner on the rig

```bash
# Kill any running instance
killall xmrig

# Wait a moment
sleep 2

# Restart via HiveOS (it will auto-restart) or manually:
./start.sh &
# Now check HiveOS Dashboard
```

---

## Section 8: Verification Checklist

```powershell
# Run from Windows PowerShell to check:

# 1. GitHub repo exists and is public
Invoke-WebRequest -Uri "https://api.github.com/repos/<username>/xmrig-no-fee" `
  -UseBasicParsing | Select-Object -ExpandProperty StatusCode

# 2. Release exists
Invoke-WebRequest -Uri "https://api.github.com/repos/<username>/xmrig-no-fee/releases/tags/v1.0-no-fee" `
  -UseBasicParsing | Select-Object -ExpandProperty StatusCode

# 3. Download URL is accessible
Invoke-WebRequest -Uri "https://github.com/<username>/xmrig-no-fee/releases/download/v1.0-no-fee/xmrig-no-fee.tar.gz" `
  -UseBasicParsing `
  -Method Head | Select-Object StatusCode, Content-Length

# 4. SSH to rig and check miner directory
ssh root@192.168.68.32 "ls -la /hive/miners/custom/xmrig-no-fee"
# Should list xmrig, config.json, start.sh

# 5. Check if miner is running
ssh root@192.168.68.32 "ps aux | grep xmrig"
# Should show xmrig process if running
```

---

## Section 9: Troubleshooting Commands

### If archive doesn't extract

```bash
# On the rig, manually extract:
cd /tmp
wget https://github.com/<username>/xmrig-no-fee/releases/download/v1.0-no-fee/xmrig-no-fee.tar.gz
tar -xzvf xmrig-no-fee.tar.gz
ls -la
# Should show xmrig, config.json, start.sh
```

### If miner won't start

```bash
# Check file permissions
cd /hive/miners/custom/xmrig-no-fee
chmod +x xmrig start.sh

# Check for line ending issues
file start.sh
# Should show "POSIX shell script text executable, ASCII text"
# NOT "CRLF line terminators"

# Fix if needed
dos2unix start.sh
# or
sed -i 's/\r$//' start.sh

# Test binary
file xmrig
ldd xmrig
# Should show all libraries linked correctly
```

### If pool connection fails

```bash
# Check pool URL format
cat config.json | grep -A2 '"url"'
# Should be: "url": "pool.domain.com:port" (no http://)

# Test connectivity
nc -zv pool.monero.example.com 3333
# Should show "succeeded"

# Check wallet address format
cat config.json | grep -A1 '"user"'
# Should be a valid Monero address
```

---

## Section 10: Update to New Version

When a new XMRig version is released:

```powershell
# On your Windows machine:
cd "C:\Users\benef\Downloads\xmrig-6.23.0\xmrig-6.23.0\github-release"

# Download new binary
Invoke-WebRequest -Uri "https://github.com/xmrig/xmrig/releases/download/v6.25.0/xmrig-6.25.0-linux-static-x64.tar.gz" `
  -OutFile "xmrig-6.25.0.tar.gz"

# Extract and copy
tar -xzf "xmrig-6.25.0.tar.gz"
Copy-Item "xmrig-6.25.0\xmrig" ".\xmrig" -Force

# Recreate archive
tar -czvf xmrig-no-fee.tar.gz xmrig config.json start.sh
$hash = (Get-FileHash xmrig-no-fee.tar.gz -Algorithm SHA256).Hash
"$hash  xmrig-no-fee.tar.gz" | Out-File SHA256SUMS

# Create new release
gh release create v1.1-no-fee `
  --title "XMRig v6.25.0 – No Developer Fee" `
  --notes "Updated to XMRig v6.25.0" `
  xmrig-no-fee.tar.gz SHA256SUMS
```

---

## Quick Copy-Paste Commands

### For GitHub CLI users (fastest):

```powershell
cd "C:\Users\benef\Downloads\xmrig-6.23.0\xmrig-6.23.0\github-release"
gh release create v1.0-no-fee --title "XMRig v6.24.0 – No Developer Fee" --notes "Pre-compiled with donate-level: 0" xmrig-no-fee.tar.gz SHA256SUMS
```

### For SSHing to rig:

```powershell
ssh root@192.168.68.32
# Once logged in:
cd /hive/miners/custom/xmrig-no-fee
nano config.json
# Edit POOL_URL and wallet address, Ctrl+O, Ctrl+X
chmod +x xmrig start.sh
dos2unix start.sh
./xmrig --config=config.json
```

---

## Reference Documentation

- GitHub CLI docs: https://cli.github.com/manual
- HiveOS Flight Sheets: https://hiveos.farm/knowledge/kb/flight-sheets
- XMRig official: https://github.com/xmrig/xmrig
- Config reference: https://xmrig.com/config
- Monero pools: https://miningpoolstats.stream/monero

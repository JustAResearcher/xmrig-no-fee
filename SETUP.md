# GitHub Release & HiveOS Setup Guide

This document walks you through uploading this package to GitHub and configuring it as a Custom Miner on HiveOS.

## Step 1: Create a GitHub Repository

1. Go to https://github.com/new
2. Create a new repository named `xmrig-no-fee` (or your preferred name)
   - Description: "XMRig no-fee custom miner for HiveOS"
   - Make it **Public** (so HiveOS can download without authentication)
   - Initialize with README (optional; we have our own)
   - Click **Create repository**

3. Clone it locally (or use GitHub CLI):
   ```bash
   git clone https://github.com/<your-username>/xmrig-no-fee.git
   cd xmrig-no-fee
   ```

## Step 2: Add Files to the Repository

Copy these files to your repo directory:

```
xmrig-no-fee/
├── start.sh
├── config.json
├── README.md
├── SETUP.md (this file)
├── SHA256SUMS
└── .gitignore (optional)
```

**Note on the binary**: If `xmrig` binary is >100MB, GitHub recommends using Git LFS or hosting on a separate storage service. For this guide, we'll attach it as a **Release asset** instead of committing it to the repo.

## Step 3: Create .gitignore (Optional)

Create `.gitignore` to exclude the binary from the repo:

```
xmrig
*.tar.gz
SHA256SUMS
```

Then commit the smaller files:

```bash
git add start.sh config.json README.md SETUP.md .gitignore
git commit -m "Initial commit: XMRig no-fee starter scripts"
git push origin main
```

## Step 4: Prepare the Release Archive Locally

You have two options:

### Option A: On Linux / WSL (Recommended)

```bash
cd /path/to/xmrig-no-fee

# Assuming you have xmrig binary downloaded locally
# Create the tar.gz with correct permissions
tar -czvf xmrig-no-fee.tar.gz xmrig config.json start.sh

# Generate SHA256 checksum
sha256sum xmrig-no-fee.tar.gz > SHA256SUMS
cat SHA256SUMS
```

### Option B: On Windows PowerShell

```powershell
# Create tar.gz (Windows 10+ has tar built-in)
$SourcePath = "C:\path\to\xmrig-release"
tar -czvf xmrig-no-fee.tar.gz xmrig config.json start.sh

# Generate SHA256 checksum
$hash = (Get-FileHash xmrig-no-fee.tar.gz -Algorithm SHA256).Hash
"$hash  xmrig-no-fee.tar.gz" | Out-File SHA256SUMS -Encoding UTF8 -NoNewline
Get-Content SHA256SUMS
```

## Step 5: Create a GitHub Release

### Option A: Via GitHub Web UI

1. Go to your repo: https://github.com/\<your-username\>/xmrig-no-fee
2. Click **Releases** (or **Create a release** on the right)
3. Click **Draft a new release**
4. Fill in:
   - **Tag version**: `v1.0-no-fee`
   - **Release title**: `XMRig v6.24.0 – No Developer Fee`
   - **Description**:
     ```
     Pre-compiled XMRig v6.24.0 with no developer donation.
     
     **Changes:**
     - donate-level: 0
     - donate-over-proxy: 0
     
     **Contents:**
     - xmrig (Linux x64 static binary)
     - config.json (template)
     - start.sh (startup script)
     - SHA256SUMS (integrity check)
     
     **How to use on HiveOS:**
     See README.md for instructions or use as Custom Miner with the release URL.
     ```
5. Drag & drop (or click to upload):
   - `xmrig-no-fee.tar.gz`
   - `SHA256SUMS`
6. Click **Publish release**

### Option B: Via GitHub CLI (Command Line)

First, install GitHub CLI: https://cli.github.com

```bash
# Ensure you're authenticated
gh auth login

# Create and publish the release
gh release create v1.0-no-fee \
  --title "XMRig v6.24.0 – No Developer Fee" \
  --notes "Pre-compiled XMRig v6.24.0 with donate-level: 0. See README.md for setup instructions." \
  xmrig-no-fee.tar.gz SHA256SUMS
```

### Option C: Via PowerShell (Using curl + REST API)

If you don't have GitHub CLI, you can use PowerShell and `curl`:

```powershell
# Set variables
$owner = "<your-username>"
$repo = "xmrig-no-fee"
$tag = "v1.0-no-fee"
$token = "<your-github-personal-access-token>"  # Create at https://github.com/settings/tokens

# Create the release (JSON body)
$releaseBody = @{
    tag_name = $tag
    name = "XMRig v6.24.0 – No Developer Fee"
    body = "Pre-compiled XMRig v6.24.0 with donate-level: 0.`n`nSee README.md for setup."
    draft = $false
    prerelease = $false
} | ConvertTo-Json

$releaseResponse = curl -X POST `
  "https://api.github.com/repos/$owner/$repo/releases" `
  -H "Authorization: token $token" `
  -H "Content-Type: application/json" `
  -d $releaseBody

# Parse response to get upload URL
$uploadUrl = ($releaseResponse | ConvertFrom-Json).upload_url -replace '\{.*\}', ''

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

Write-Host "Release created and assets uploaded!"
```

## Step 6: Get the Download URL

Once the release is published, the direct download URL for the asset will be:

```
https://github.com/<your-username>/xmrig-no-fee/releases/download/v1.0-no-fee/xmrig-no-fee.tar.gz
```

Copy this URL — you'll need it for HiveOS.

## Step 7: Configure HiveOS Custom Miner

### Via HiveOS Web UI:

1. Log into your HiveOS account at https://the.hiveos.farm
2. Go to **Flight Sheets** → **Create Flight Sheet** (or edit an existing one)
3. Under **Miner** dropdown, select **Custom**
4. A form appears with these fields:
   - **URL**: Paste your GitHub release download URL:
     ```
     https://github.com/<your-username>/xmrig-no-fee/releases/download/v1.0-no-fee/xmrig-no-fee.tar.gz
     ```
   - **Name** (optional): `xmrig-no-fee`
   - **Command** or **Extra args** (optional): Leave empty; `start.sh` will run by default
   - **Config** or **Pool settings**: If available, configure your pool and wallet here (or edit after extraction)
5. Click **Save Flight Sheet**
6. Select your worker(s) and click **Apply Flight Sheet**

### Via HiveOS API / Programmatic:

(Advanced) If using HiveOS API, the custom miner JSON structure looks like:

```json
{
  "id": "<miner-id>",
  "name": "xmrig-no-fee",
  "type": "custom",
  "url": "https://github.com/<your-username>/xmrig-no-fee/releases/download/v1.0-no-fee/xmrig-no-fee.tar.gz",
  "extra": ""
}
```

## Step 8: Test on the Rig

### Expected Behavior:

1. Apply the Flight Sheet to your HiveOS worker
2. HiveOS will:
   - Download `xmrig-no-fee.tar.gz` from GitHub
   - Extract to `/hive/miners/custom/xmrig-no-fee` (or similar)
   - Attempt to run `start.sh`
3. Check the **Dashboard** or **Logs** in HiveOS web UI for the miner status

### Troubleshooting:

If the miner doesn't start:

1. **Check console/logs** in HiveOS web UI
2. **SSH into the rig** and manually run:
   ```bash
   cd /hive/miners/custom/xmrig-no-fee
   chmod +x xmrig start.sh
   ./xmrig --config=config.json
   ```
3. **Fix the config**: Edit `config.json` with your pool URL and wallet address:
   ```bash
   nano config.json
   ```
4. **Check CRLF line endings**: If `start.sh` was edited on Windows, convert line endings:
   ```bash
   dos2unix start.sh
   # or
   sed -i 's/\r$//' start.sh
   ```

## Verification Checklist

- [ ] GitHub repository created and public
- [ ] Files committed: `start.sh`, `config.json`, `README.md`, `SETUP.md`, `.gitignore`
- [ ] Release `v1.0-no-fee` created with assets uploaded
- [ ] Release asset URL confirmed: `https://github.com/<...>/releases/download/v1.0-no-fee/xmrig-no-fee.tar.gz`
- [ ] HiveOS Flight Sheet created with Custom miner type
- [ ] Custom miner URL entered in Flight Sheet
- [ ] Flight Sheet applied to a worker
- [ ] Miner appeared in HiveOS Dashboard
- [ ] config.json edited with your pool and wallet on the rig
- [ ] Miner is running and reporting shares

## Next Steps

- Monitor the miner's performance in HiveOS Dashboard
- Adjust config.json settings (CPU threads, huge pages, etc.) as needed
- Document any custom changes in the GitHub repo README for other users
- Consider adding a release for newer XMRig versions in the future

---

**Questions?** See HiveOS documentation at https://hiveos.farm/knowledge or XMRig official repo at https://github.com/xmrig/xmrig

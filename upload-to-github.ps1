#!/usr/bin/env pwsh
<#
  XMRig No-Fee GitHub Release Upload Script (PowerShell)
  
  This script automates uploading the XMRig package to GitHub.
  
  Prerequisites:
    - GitHub account and authentication (PAT or git credential)
    - PowerShell 5.1 or later
    - git command-line tool
  
  Usage:
    .\upload-to-github.ps1 -UserName "<your-github-username>" -RepoName "xmrig-no-fee" -PersonalAccessToken "<your-PAT>"
    
  For GitHub CLI users (easier):
    gh release create v1.0-no-fee --title "XMRig v6.24.0 – No Developer Fee" \
      --notes "Pre-compiled XMRig v6.24.0 with donate-level: 0" \
      xmrig-no-fee.tar.gz SHA256SUMS
#>

param(
    [string]$UserName,
    [string]$RepoName = "xmrig-no-fee",
    [string]$PersonalAccessToken,
    [string]$Tag = "v1.0-no-fee",
    [string]$ReleaseTitle = "XMRig v6.24.0 - No Developer Fee",
    [string]$ReleaseNotes = @'
Pre-compiled XMRig v6.24.0 with no developer donation.

Changes:
- donate-level: 0
- donate-over-proxy: 0

Contents:
- xmrig (Linux x64 static binary)
- config.json (template)
- start.sh (startup script)
- SHA256SUMS (integrity check)

How to use on HiveOS:
See README.md for complete setup instructions or use as Custom Miner in HiveOS Flight Sheets.
'@
)

# Validate inputs
if (-not $UserName) {
    Write-Error "UserName is required. Use: -UserName '<your-github-username>'"
    exit 1
}

if (-not $PersonalAccessToken) {
    Write-Host "GitHub Personal Access Token not provided." -ForegroundColor Yellow
    Write-Host "You can create one at: https://github.com/settings/tokens" -ForegroundColor Cyan
    Write-Host ""
    
    # Check for GitHub CLI as alternative
    if (Get-Command gh -ErrorAction SilentlyContinue) {
        Write-Host "GitHub CLI (gh) detected. Recommending GitHub CLI method:" -ForegroundColor Green
        Write-Host ""
        Write-Host "gh release create $Tag --title `"$ReleaseTitle`" \" -ForegroundColor Green
        Write-Host "  --notes `"Pre-compiled XMRig v6.24.0 with donate-level: 0`" \" -ForegroundColor Green
        Write-Host "  xmrig-no-fee.tar.gz SHA256SUMS" -ForegroundColor Green
        Write-Host ""
        Write-Host "Run the above command if authenticated with 'gh auth login'" -ForegroundColor Cyan
        exit 0
    }
    
    exit 1
}

Write-Host "XMRig GitHub Release Upload Script" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Configuration:" -ForegroundColor Yellow
Write-Host "  GitHub User: $UserName"
Write-Host "  Repository: $RepoName"
Write-Host "  Release Tag: $Tag"
Write-Host "  Release Title: $ReleaseTitle"
Write-Host ""

# Verify required files exist
$requiredFiles = @("xmrig-no-fee.tar.gz", "SHA256SUMS")
foreach ($file in $requiredFiles) {
    if (-not (Test-Path $file)) {
        Write-Error "Required file not found: $file"
        Write-Host "Please run from the github-release directory containing xmrig-no-fee.tar.gz"
        exit 1
    }
}

Write-Host "[OK] All required files found" -ForegroundColor Green
Write-Host ""

# Create release using REST API
Write-Host "Creating release via GitHub REST API..." -ForegroundColor Yellow

$headers = @{
    "Authorization" = "token $PersonalAccessToken"
    "Content-Type" = "application/json"
    "Accept" = "application/vnd.github+json"
}

$releaseBody = @{
    tag_name    = $Tag
    name        = $ReleaseTitle
    body        = $ReleaseNotes
    draft       = $false
    prerelease  = $false
} | ConvertTo-Json

try {
    Write-Host "  -> Creating release: $Tag" -ForegroundColor Cyan
    
    $response = Invoke-WebRequest `
        -Uri "https://api.github.com/repos/$UserName/$RepoName/releases" `
        -Method POST `
        -Headers $headers `
        -Body $releaseBody `
        -ErrorAction Stop
    
    $releaseId = ($response.Content | ConvertFrom-Json).id
    $uploadUrl = ($response.Content | ConvertFrom-Json).upload_url -replace '\{.*\}', ''
    
    Write-Host "  [OK] Release created with ID: $releaseId" -ForegroundColor Green
} catch {
    Write-Error "Failed to create release: $($_.Exception.Message)"
    Write-Host "Make sure:" -ForegroundColor Yellow
    Write-Host "  1. Repository exists: https://github.com/$UserName/$RepoName"
    Write-Host "  2. Personal Access Token is valid and has 'repo' scope"
    Write-Host "  3. Tag doesn't already exist"
    exit 1
}

# Upload assets
$assets = @("xmrig-no-fee.tar.gz", "SHA256SUMS")

foreach ($asset in $assets) {
    if (-not (Test-Path $asset)) {
        Write-Host "  [WARN] Skipping $asset (not found)" -ForegroundColor Yellow
        continue
    }
    
    Write-Host "  -> Uploading: $asset" -ForegroundColor Cyan
    
    $fileContent = [System.IO.File]::ReadAllBytes($asset)
    
    try {
        $response = Invoke-WebRequest `
            -Uri "$($uploadUrl)?name=$asset" `
            -Method POST `
            -Headers @{
                "Authorization" = "token $PersonalAccessToken"
                "Content-Type" = "application/octet-stream"
            } `
            -Body $fileContent `
            -ErrorAction Stop
        
        Write-Host "  [OK] Uploaded: $asset" -ForegroundColor Green
    } catch {
        Write-Error "Failed to upload $asset`: $($_.Exception.Message)"
    }
}

Write-Host ""
Write-Host "Release complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Your download URL:" -ForegroundColor Yellow
Write-Host "https://github.com/$UserName/$RepoName/releases/download/$Tag/xmrig-no-fee.tar.gz" -ForegroundColor Cyan
Write-Host ""
Write-Host "Use this URL in HiveOS Custom Miner configuration." -ForegroundColor Green

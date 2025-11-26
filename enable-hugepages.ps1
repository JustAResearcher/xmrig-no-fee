# PowerShell script to enable 1GB hugepages on all HiveOS rigs via SSH
# Usage: .\enable-hugepages.ps1 -RigIps @("192.168.1.100", "192.168.1.101") -SshUser "root"

param(
    [string[]]$RigIps,
    [string]$SshUser = "root",
    [string]$SshKeyPath = "$env:USERPROFILE\.ssh\id_ed25519",
    [int]$Threads = 4
)

if (-not $RigIps -or $RigIps.Count -eq 0) {
    Write-Host "Usage: .\enable-hugepages.ps1 -RigIps @('192.168.1.100', '192.168.1.101') -SshUser 'root'" -ForegroundColor Yellow
    Write-Host "Usage: .\enable-hugepages.ps1 -RigIps (Get-Content rig_ips.txt) -SshUser 'root'" -ForegroundColor Yellow
    exit 1
}

$hugepagesCmd = @"
#!/bin/sh
sysctl -w vm.nr_hugepages=`$(nproc)
for i in `$(find /sys/devices/system/node/node* -maxdepth 0 -type d 2>/dev/null);
do
    echo 3 > "`$i/hugepages/hugepages-1048576kB/nr_hugepages" 2>/dev/null;
done
echo "1GB hugepages enabled"
"@

$successCount = 0
$failCount = 0
$lock = [System.Object]::new()

Write-Host "Enabling 1GB hugepages on $($RigIps.Count) rig(s)..." -ForegroundColor Cyan

$RigIps | ForEach-Object -Parallel {
    $rig = $_
    $sshUser = $using:SshUser
    $sshKeyPath = $using:SshKeyPath
    $cmd = $using:hugepagesCmd
    $lock = $using:lock
    
    try {
        $result = ssh -i $sshKeyPath -o ConnectTimeout=5 -o StrictHostKeyChecking=accept-new "${sshUser}@${rig}" $cmd 2>&1
        [System.Threading.Monitor]::Enter($lock)
        Write-Host "[✓] $rig : $result" -ForegroundColor Green
        $script:successCount++
    }
    catch {
        [System.Threading.Monitor]::Enter($lock)
        Write-Host "[✗] $rig : $_" -ForegroundColor Red
        $script:failCount++
    }
    finally {
        [System.Threading.Monitor]::Exit($lock)
    }
} -ThrottleLimit $Threads

Write-Host "`nSummary: $successCount succeeded, $failCount failed" -ForegroundColor Cyan

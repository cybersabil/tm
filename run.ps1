# CyberSabil TM Online Launcher
$ErrorActionPreference = "Stop"

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
} catch {}

$MainUrl  = "https://raw.githubusercontent.com/cybersabil/tm/main/app.ps1"
$WorkDir  = Join-Path $env:TEMP "CyberSabilTM"
$MainFile = Join-Path $WorkDir "app.ps1"

if (!(Test-Path $WorkDir)) {
    New-Item -ItemType Directory -Path $WorkDir -Force | Out-Null
}

try {
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($MainUrl, $MainFile)
} catch {
    Write-Host ""
    Write-Host "Download failed." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

try {
    Unblock-File -Path $MainFile -ErrorAction SilentlyContinue
} catch {}

$IsAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

$PowerShellExe = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
$Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$MainFile`""

if (-not $IsAdmin) {
    Start-Process -FilePath $PowerShellExe -ArgumentList $Arguments -Verb RunAs
    exit
}

& $PowerShellExe -NoProfile -ExecutionPolicy Bypass -File $MainFile

exit

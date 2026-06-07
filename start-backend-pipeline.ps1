# GLM Coding Helper - Pipeline Backend Launcher
# Usage: powershell -File start-backend-pipeline.ps1
#   or just double-click in Explorer

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Root

Write-Host "GLM Coding Helper - Pipeline Backend" -ForegroundColor Cyan

# Find Python venv
$Python = ""
if (Test-Path "$Root\venv\Scripts\python.exe") {
    $Python = "$Root\venv\Scripts\python.exe"
} elseif (Test-Path "$Root\.venv_paddle\Scripts\python.exe") {
    $Python = "$Root\.venv_paddle\Scripts\python.exe"
} else {
    Write-Host "[FAIL] No Python venv found. Run setup first." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Check port
$portInUse = netstat -ano | Select-String ":8888 .*LISTENING"
if ($portInUse) {
    Write-Host "[WARN] Port 8888 is already in use!" -ForegroundColor Yellow
    $portPid = ($portInUse.ToString().Trim() -split '\s+')[-1]
    Write-Host "       Existing process PID: $portPid"
    $choice = Read-Host "       Type 1 to kill it and restart, or Enter to exit"
    if ($choice -eq "1") {
        Stop-Process -Id $portPid -Force -ErrorAction SilentlyContinue
        Start-Sleep 2
        Write-Host "       Killed."
    } else {
        exit 1
    }
}

Write-Host "[OK] Starting pipeline backend on http://127.0.0.1:8888" -ForegroundColor Green
Write-Host "[OK] Press Ctrl+C to stop" -ForegroundColor Green
Write-Host ""

$env:PYTHONUTF8 = "1"
$env:PYTHONIOENCODING = "utf-8"

& $Python "$Root\backend\server.py"

Read-Host "Press Enter to exit"

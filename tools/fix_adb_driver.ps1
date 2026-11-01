# fix_adb_driver.ps1
# Memperbaiki agar ADB bisa mendeteksi HP Infinix GT 30 Pro di Windows.
#
# Masalah: interface ADB (VID_0E8D&PID_201D&MI_01) memakai driver generic
# "WinUsb Device" (winusb.inf) tanpa DeviceInterfaceGUIDs, sehingga adb.exe
# tidak menemukan perangkat walaupun di Device Manager statusnya OK.
#
# Cara pakai:
#   1. Klik kanan file ini -> "Run with PowerShell" sebagai Administrator,
#      atau buka PowerShell (Admin) lalu jalankan:
#         powershell -ExecutionPolicy Bypass -File .\tools\fix_adb_driver.ps1
#   2. Cabut dan colok ulang kabel USB HP.
#   3. Jalankan: adb devices
#
# Script ini hanya menambah nilai registry pada interface ADB dan me-restart
# device tersebut. Tidak mengubah driver lain.

$ErrorActionPreference = 'Stop'

$logPath = Join-Path $env:TEMP 'opencode\adb_fix.log'
New-Item -ItemType Directory -Path (Split-Path $logPath) -Force | Out-Null
try { Start-Transcript -Path $logPath -Force | Out-Null } catch { }

$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host 'Script ini harus dijalankan sebagai Administrator.' -ForegroundColor Red
    Write-Host 'Klik kanan -> Run as administrator, lalu ulangi.'
    exit 1
}

$adbGuid = '{F72FE0D4-CBCB-407d-8814-9ED673D0DD6B}'

$devices = Get-PnpDevice -PresentOnly | Where-Object {
    $_.InstanceId -match '^USB\\VID_0E8D&PID_201D&MI_01'
}

if (-not $devices) {
    Write-Host 'Interface ADB Infinix tidak ditemukan.' -ForegroundColor Yellow
    Write-Host 'Pastikan HP tercolok, mode USB = File Transfer (MTP), dan USB debugging aktif.'
    exit 1
}

foreach ($dev in $devices) {
    $instanceId = $dev.InstanceId
    Write-Host "Memproses: $instanceId"

    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Enum\$instanceId\Device Parameters"
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    New-ItemProperty -Path $regPath -Name 'DeviceInterfaceGUIDs' `
        -PropertyType MultiString -Value $adbGuid -Force | Out-Null
    Write-Host "  DeviceInterfaceGUIDs = $adbGuid"

    # Restart device agar driver membaca ulang registry.
    & pnputil.exe /restart-device "$instanceId" | Out-Null
    Write-Host '  device di-restart'
}

Start-Sleep -Seconds 3
& adb kill-server | Out-Null
& adb start-server | Out-Null
Start-Sleep -Seconds 2

Write-Host ''
Write-Host 'Hasil "adb devices":' -ForegroundColor Cyan
& adb devices -l

Write-Host ''
Write-Host 'Jika HP belum muncul: cabut-colok kabel USB, lalu jalankan "adb devices" lagi.' -ForegroundColor Cyan
Write-Host 'Jika masih kosong, di HP buka Settings > Developer options > Revoke USB debugging authorizations,'
Write-Host 'lalu colok ulang dan setujui dialog "Allow USB debugging".'

try { Stop-Transcript | Out-Null } catch { }

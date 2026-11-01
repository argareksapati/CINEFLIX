# CINEFLIX Flutter bootstrap for Windows PowerShell.
# Safeguards provided lib/ and pubspec.yaml before generating Flutter platforms.
$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$FlutterCmd = Get-Command flutter -ErrorAction SilentlyContinue
if ($null -eq $FlutterCmd) {
    Write-Error 'Flutter tidak ditemukan di PATH. Instal Flutter SDK terlebih dahulu lalu jalankan flutter doctor.'
    exit 1
}
$BackupDir = Join-Path $env:TEMP ('cineflix_' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $ProjectRoot 'lib') -Destination $BackupDir -Recurse -Force
Copy-Item -LiteralPath (Join-Path $ProjectRoot 'pubspec.yaml') -Destination $BackupDir -Force
Push-Location $ProjectRoot
try {
    Write-Host '[1/3] Generating Android/iOS/Web Flutter project scaffolding...'
    & flutter create --project-name cineflix_flutter --platforms android,ios,web .
    if ($LASTEXITCODE -ne 0) { throw 'flutter create failed' }
    # Network poster URLs are optional; offline illustrations remain available.
    $Manifest = Join-Path $ProjectRoot 'android/app/src/main/AndroidManifest.xml'
    if (Test-Path -LiteralPath $Manifest) {
        $ManifestText = Get-Content -LiteralPath $Manifest -Raw
        if ($ManifestText -notmatch 'android.permission.INTERNET') {
            $ManifestText = $ManifestText.Replace('<application', '    <uses-permission android:name="android.permission.INTERNET" />' + [Environment]::NewLine + '    <application')
            Set-Content -LiteralPath $Manifest -Value $ManifestText -Encoding UTF8
        }
    }
    Write-Host '[2/3] Restoring CINEFLIX Dart source and pubspec.yaml...'
    Copy-Item -Path (Join-Path $BackupDir 'lib/*') -Destination (Join-Path $ProjectRoot 'lib') -Recurse -Force
    Copy-Item -LiteralPath (Join-Path $BackupDir 'pubspec.yaml') -Destination $ProjectRoot -Force
    $TemplateTest = Join-Path $ProjectRoot 'test/widget_test.dart'
    if (Test-Path $TemplateTest) { Remove-Item $TemplateTest -Force }
    Write-Host '[3/3] Resolving Flutter dependencies...'
    & flutter pub get
    if ($LASTEXITCODE -ne 0) { throw 'flutter pub get failed' }
    Write-Host 'READY. Run: flutter run (or flutter run -d edge)'
}
finally {
    Pop-Location
    Remove-Item -LiteralPath $BackupDir -Recurse -Force -ErrorAction SilentlyContinue
}

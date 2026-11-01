#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
if ! command -v flutter >/dev/null 2>&1; then
  echo 'Flutter not found in PATH. Install Flutter SDK and run flutter doctor.' >&2
  exit 1
fi
backup_dir="$(mktemp -d)"
trap 'rm -rf "$backup_dir"' EXIT
cp -R lib "$backup_dir/lib"
cp pubspec.yaml "$backup_dir/pubspec.yaml"
flutter create --project-name cineflix_flutter --platforms android,ios,web .
python3 - <<'PYMANIFEST'
from pathlib import Path
manifest=Path('android/app/src/main/AndroidManifest.xml')
if manifest.exists():
    text=manifest.read_text()
    if 'android.permission.INTERNET' not in text:
        text=text.replace('<application','    <uses-permission android:name="android.permission.INTERNET" />\n    <application',1)
        manifest.write_text(text)
PYMANIFEST
cp -R "$backup_dir/lib/." lib/
cp "$backup_dir/pubspec.yaml" pubspec.yaml
rm -f test/widget_test.dart
flutter pub get
echo 'READY. Run: flutter run (or flutter run -d edge)'

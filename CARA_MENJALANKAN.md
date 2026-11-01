# Cara Menjalankan CINEFLIX (Android, iOS, VS Code, Android Studio)

Project ini adalah aplikasi **Flutter** (`cineflix_flutter`). Semua kode UI ada di `lib/`.
Folder platform `android/`, `ios/`, dan `web/` sudah disertakan, jadi tidak perlu
menjalankan `flutter create` lagi.

## 1. Prasyarat

| Kebutuhan | Versi yang dipakai saat project diverifikasi |
| --- | --- |
| Flutter SDK | 3.47.7 (stable) / Dart 3.13.5 |
| Android SDK | Platform 36.1, Build Tools 36.1, JDK 21 (bawaan Android Studio) |
| Android Studio | Versi terbaru (untuk emulator/SDK Manager) |
| VS Code | Ekstensi **Dart** dan **Flutter** (`Dart-Code.dart-code`, `Dart-Code.flutter`) |
| Xcode (khusus iOS) | macOS + Xcode terbaru |

Cek instalasi:

```powershell
flutter doctor -v
```

## 2. Ambil dependensi

Dari folder project (`cineflix_task1_v2`):

```powershell
flutter pub get
```

## 3. Menjalankan lewat VS Code

1. Buka folder project di VS Code: **File > Open Folder**.
2. Pasang ekstensi yang direkomendasikan (VS Code akan menawarkan saat folder dibuka).
3. Hubungkan HP Android (USB debugging aktif) atau nyalakan emulator.
4. Pilih konfigurasi di panel **Run and Debug**:
   - `CINEFLIX - Android/HP (debug)`
   - `CINEFLIX - Edge/Web (debug)`
   - `CINEFLIX - iOS Simulator (macOS)` (hanya di Mac)
5. Tekan **F5**.

Alternatif lewat terminal VS Code:

```powershell
flutter devices
flutter run                 # otomatis memilih perangkat yang terhubung
flutter run -d edge         # browser Edge (tanpa emulator)
```

Konfigurasi siap pakai ada di `.vscode/launch.json` dan `.vscode/tasks.json`
(termasuk task `Flutter: analyze`, `Flutter: test`, `Flutter: build APK`).

## 4. Menjalankan lewat Android Studio

1. **File > Open**, pilih folder project `cineflix_task1_v2` (bukan folder `android/` saja).
2. Tunggu proses **Gradle Sync** selesai.
3. Pilih device di toolbar (emulator atau HP fisik).
4. Pilih run configuration **main.dart**, lalu klik **Run** (Shift+F10).
5. Jika Gradle meminta NDK, buka **Tools > SDK Manager > SDK Tools**, centang
   **NDK (Side by side)** versi `28.2.13676358`, lalu **Apply**.

Membuat emulator bila belum ada:

1. **Tools > Device Manager > Create Device**.
2. Pilih tipe HP (mis. Pixel 7), lalu pilih system image (mis. API 35/36).
3. Selesaikan wizard, lalu jalankan emulator dari Device Manager.

Atau lewat terminal:

```powershell
flutter emulators
flutter emulators --launch <emulator_id>
flutter run
```

## 5. Menjalankan di HP Android (USB debugging)

1. Di HP: **Settings > About phone**, ketuk **Build number** 7x.
2. Aktifkan **Developer options > USB debugging**.
3. Sambungkan kabel USB, pilih mode **File transfer / MTP**, lalu izinkan
   dialog **Allow USB debugging**.
4. Cek dan jalankan:

```powershell
adb devices
flutter devices
flutter run
```

Jika perangkat tidak terdeteksi, coba `adb kill-server` lalu `adb start-server`,
ganti kabel/port USB, atau gunakan **Wireless debugging** di Android 11+.

### 5a. HP terdeteksi di Device Manager tapi `adb devices` kosong (Windows)

Kasus yang sudah terpecahkan di project ini (Infinix GT 30 Pro): interface **ADB Interface**
memakai driver generic *WinUsb Device* tanpa `DeviceInterfaceGUIDs`, sehingga adb tidak
menemukannya. Perbaikannya butuh **Administrator**:

```powershell
# klik kanan -> Run as administrator, atau dari PowerShell (Admin):
powershell -ExecutionPolicy Bypass -File .\tools\fix_adb_driver.ps1
```

Script menambahkan GUID ADB ke registry interface tersebut, me-restart device, lalu
menjalankan `adb devices`. Setelah itu cabut-colok kabel USB dan setujui dialog
**Allow USB debugging** di HP.

### 5b. `INSTALL_FAILED_VERIFICATION_FAILURE` saat `adb install`

Verifikasi paket bawaan vendor (HiOS/MIUI) menolak instalasi. Matikan verifikasi untuk
instalasi lewat ADB:

```powershell
adb shell settings put global verifier_verify_adb_installs 0
adb shell settings put global package_verifier_enable 0
adb install -r build\app\outputs\flutter-apk\app-release.apk
```

## 6. Build APK untuk dikumpulkan / dipasang manual

```powershell
flutter build apk --debug      # cepat, untuk uji
flutter build apk --release    # untuk dibagikan (ditandatangani debug key)
```

Hasil build:

```text
build\app\outputs\flutter-apk\app-debug.apk
build\app\outputs\flutter-apk\app-release.apk
```

Pasang ke HP:

```powershell
adb install -r build\app\outputs\flutter-apk\app-release.apk
```

### 6a. Mengambil screenshot langsung dari HP

```powershell
adb shell screencap -p /sdcard/shot.png
adb pull /sdcard/shot.png docs\screenshot-baru.png
```

Enam screenshot asli dari HP Infinix GT 30 Pro sudah tersedia di folder `docs/`
(`screenshot-1-home.png` sampai `screenshot-6-search.png`).

## 7. iOS (iPhone / Simulator)

Build dan run iOS **wajib memakai macOS** dengan Xcode. Dari Windows folder `ios/`
hanya bisa disiapkan/diedit, tidak bisa di-build.

Di Mac:

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
flutter doctor
cd cineflix_task1_v2
flutter pub get
open ios/Runner.xcworkspace     # atau: flutter run -d ios
```

Langkah di Xcode:

1. Pilih target **Runner > Signing & Capabilities**.
2. Pilih **Team** (Apple ID gratis bisa untuk simulator; iPhone fisik butuh
   provisioning).
3. Pilih simulator/iPhone di toolbar, lalu **Run**.

Catatan: poster online memakai HTTPS (TMDB CDN), jadi tidak perlu mengubah
App Transport Security. Bila offline, ilustrasi lokal tetap tampil.

## 8. Menjalankan versi Web (paling cepat tanpa emulator)

```powershell
flutter run -d edge
# atau
flutter build web
flutter run -d web-server --web-port 8088
```

## 9. Perintah verifikasi

```powershell
flutter analyze
flutter test
```

Hasil verifikasi di mesin ini (31 Oktober 2026):

- `flutter analyze` — bersih, 0 issue.
- `flutter test` — 3/3 test lulus.
- `flutter build web` — berhasil.
- `flutter run -d edge` — aplikasi berjalan dan tampil di Edge.
- `flutter build apk --debug` — berhasil (`build\app\outputs\flutter-apk\app-debug.apk`).
- `flutter build apk --release` — berhasil (`build\app\outputs\flutter-apk\app-release.apk`, ±50 MB).
- NDK `28.2.13676358` sudah terpasang untuk build Android.

Mesin ini **belum memiliki emulator Android dan belum ada HP yang terhubung**, jadi
run di perangkat Android serta screenshot asli perlu dilakukan setelah emulator
dibuat atau HP disambungkan (lihat langkah 4–5). Build iOS hanya bisa dilakukan di
macOS. APK release di atas ditandatangani dengan debug key (sesuai template Flutter),
jadi cukup untuk demo/tugas, bukan untuk rilis Play Store.

## 10. Troubleshooting

- **`No devices found`** — jalankan `flutter devices`; aktifkan USB debugging atau
  nyalakan emulator lebih dulu.
- **Gradle gagal mengunduh NDK** — pastikan internet stabil, lalu pasang NDK
  `28.2.13676358` dari SDK Manager. Project ini tidak memakai kode native, tetapi
  Flutter Gradle Plugin tetap memeriksa NDK.
- **Gradle lambat / gagal dependency** — jalankan `flutter pub get`, lalu
  `cd android; .\gradlew.bat --stop`, dan coba `flutter run` lagi.
- **Poster tidak muncul** — aplikasi memakai gambar online; tanpa internet,
  fallback ilustrasi lokal otomatis dipakai.
- **Chrome tidak ditemukan** — gunakan Edge (`flutter run -d edge`) atau set
  `CHROME_EXECUTABLE` ke lokasi `chrome.exe`.

## 11. Struktur singkat

```text
android/                 scaffold Android (sudah ada)
ios/                     scaffold iOS (sudah ada, build di macOS)
web/                     scaffold Web
lib/                     kode aplikasi
.vscode/                 konfigurasi run/debug VS Code
.idea/                   konfigurasi run Android Studio
```

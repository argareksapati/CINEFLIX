# CHECKLIST PENGUJIAN

Tanggal uji: 1 November 2026  |  Perangkat: **Infinix GT 30 Pro (X6873), Android 16**  |  Flutter: 3.47.7
Metode: APK release dipasang lewat `adb install -r`, dijalankan langsung di perangkat, lalu
setiap interaksi diuji manual dan juga lewat automate test (`flutter test`, 15 test).

## Otomatis

- [x] `flutter doctor` tidak memblokir target Android.
- [x] `flutter pub get` sukses.
- [x] `flutter analyze` tanpa error (0 issue).
- [x] `flutter test` sukses (**15/15**), mencakup animasi pembuka, filter kategori, pencarian,
      halaman pemutar, panel detail, halaman koleksi, profil, dan navigasi bawah.
- [x] `flutter build apk --release` sukses.

## Di perangkat (manual)

- [x] Animasi pembuka muncul saat aplikasi pertama kali dibuka, lalu memudar membuka beranda.
- [x] Header CINEFLIX, chip kategori, dan banner Now Playing tampil.
- [x] Now Playing berganti otomatis dan bisa digeser manual.
- [x] Trending Now, Popular, Top Rated tampil, bisa digeser horizontal, dan punya tautan
      **Lihat semua**.
- [x] Top 10 Pilihan tampil dan bisa digeser horizontal.
- [x] Filter kategori (Semua / Sci-Fi / Aksi / Thriller / Drama) mengubah katalog.
- [x] Pencarian di beranda menyaring judul dan genre.
- [x] Pencarian di tab Explore menyaring grid dan menampilkan jumlah film.
- [x] Ketuk poster membuka panel detail film.
- [x] Tombol **Daftarku** berubah menjadi **Tersimpan** dan film muncul di tab My List
      (sinkron, termasuk badge angka di navigasi bawah).
- [x] **Hot picks** membuka halaman koleksi Now Playing.
- [x] Sub-judul **Lagi ramai / Favorit penonton / Rating tertinggi** membuka halaman koleksi
      berisi daftar film section tersebut.
- [x] Tombol **Play** dan **Putar Film** membuka halaman pemutar; setelah memuat muncul pesan
      **"Pemutaran gagal"** karena aplikasi masih versi demo.
- [x] Tombol **Coba lagi** mengulang proses memuat dan kembali gagal.
- [x] Ikon **profil** membuka halaman Profil.
- [x] Pengaturan profil berfungsi: kualitas streaming (Otomatis / Hemat data / 720p / 1080p),
      notifikasi (3 switch), dan bahasa (Indonesia / English).
- [x] Menu **Daftarku** di profil berpindah ke tab My List.
- [x] Menu **Tentang aplikasi** membuka halaman penjelasan aplikasi.
- [x] Menu **Keluar** menampilkan dialog konfirmasi lalu kembali ke beranda.
- [x] Navigasi bawah berpindah antara Home, Explore, dan My List dengan status aktif sinkron.
- [x] Tombol back perangkat di tab lain kembali ke Home lebih dulu.
- [x] Mode pesawat: poster daring gagal dimuat dan ilustrasi lokal otomatis tampil.
- [x] Screenshot diambil langsung dari HP (folder `docs/screenshots/`).
- [x] Video demo direkam dari HP (`docs/cineflix_demo.mp4`).

## Bukti pengujian di perangkat

| File | Isi |
| --- | --- |
| `docs/screenshots/01-intro.png` | Animasi pembuka |
| `docs/screenshots/02-beranda.png` | Beranda: header, chip, Now Playing, Hot picks |
| `docs/screenshots/03-filter-kategori.png` | Filter kategori Sci-Fi |
| `docs/screenshots/04-koleksi.png` | Halaman koleksi Now Playing |
| `docs/screenshots/05-detail-film.png` | Panel detail film |
| `docs/screenshots/06-tersimpan.png` | Tombol Daftarku berubah jadi Tersimpan |
| `docs/screenshots/07-pemutar-gagal.png` | Halaman pemutar: pemutaran gagal |
| `docs/screenshots/08-explore.png` | Tab Explore |
| `docs/screenshots/09-pencarian.png` | Pencarian "batman" di Explore |
| `docs/screenshots/10-my-list.png` | Tab My List |
| `docs/screenshots/11-profil.png` | Halaman profil dan pengaturan |
| `docs/screenshots/12-tentang-aplikasi.png` | Tentang aplikasi |
| `docs/screenshots/13-offline.png` | Poster cadangan saat mode pesawat |
| `docs/cineflix_demo.mp4` | Rekaman demo di HP |

Semua item di atas sudah diverifikasi. Tiga item yang tidak masuk checklist ini: upload source
ke GitHub, unggah video ke layanan berbagi, dan penyusunan PDF final.

import 'package:cineflix_flutter/main.dart';
import 'package:cineflix_flutter/widgets/cineflix_intro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Ukuran viewport untuk pengujian. Font bawaan test (Ahem) lebih lebar dari
/// Roboto, jadi viewport dibuat sedikit lebih lega agar tidak memicu
/// overflow palsu.
void _usePhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1620, 3000);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

/// Melepas widget tree supaya timer internal (carousel auto-play, pemutar
/// demo) ikut dibatalkan sebelum test selesai.
Future<void> _closeApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
}

/// Membuka aplikasi lalu menunggu animasi intro selesai.
Future<void> _openHome(WidgetTester tester) async {
  _usePhoneViewport(tester);
  await tester.pumpWidget(const CineflixApp());
  await tester.pumpAndSettle();
}

Future<void> _tapNav(WidgetTester tester, String id) async {
  await tester.tap(find.byKey(ValueKey(id)));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('animasi intro tampil lebih dulu, lalu beranda muncul',
      (tester) async {
    _usePhoneViewport(tester);
    await tester.pumpWidget(const CineflixApp());

    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(CineflixIntro), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byType(CineflixIntro), findsNothing);
    expect(find.text('Now Playing'), findsOneWidget);

    await _closeApp(tester);
  });

  testWidgets('chip kategori Sci-Fi menyaring katalog', (tester) async {
    await _openHome(tester);

    await tester.tap(find.text('Sci-Fi').first);
    await tester.pumpAndSettle();

    expect(find.text('DUNE: PART TWO'), findsOneWidget);
    expect(find.text('SPIDER-MAN: ACROSS THE SPIDER-VERSE'), findsNothing);

    await _closeApp(tester);
  });

  testWidgets('kolom cari beranda menyaring judul', (tester) async {
    await _openHome(tester);

    await tester.tap(find.byTooltip('Cari film'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'dune');
    await tester.pumpAndSettle();

    expect(find.text('DUNE: PART TWO'), findsOneWidget);

    await _closeApp(tester);
  });

  testWidgets('tombol Play membuka halaman pemutar lalu gagal (demo)',
      (tester) async {
    await _openHome(tester);

    await tester.tap(find.text('Play').hitTestable().first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Halaman pemutar tampil dan sedang menyiapkan video.
    expect(find.text('Menyiapkan pemutaran…'), findsOneWidget);

    // Setelah percobaan, muncul pesan gagal karena masih demo.
    await tester.pumpAndSettle();
    expect(find.text('Pemutaran gagal'), findsOneWidget);
    expect(
      find.textContaining('masih berupa demo tampilan'),
      findsOneWidget,
    );

    await _closeApp(tester);
  });

  testWidgets('tombol Info membuka bottom sheet dan My List bisa ditandai',
      (tester) async {
    await _openHome(tester);

    await tester.tap(find.text('Info').hitTestable().first);
    await tester.pumpAndSettle();

    expect(find.text('SINOPSIS'), findsOneWidget);
    expect(find.text('Putar Film'), findsOneWidget);

    await tester.tap(find.text('Daftarku'));
    await tester.pumpAndSettle();
    expect(find.text('Tersimpan'), findsOneWidget);

    await _closeApp(tester);
  });

  testWidgets('"Putar Film" di bottom sheet juga membuka halaman pemutar',
      (tester) async {
    await _openHome(tester);

    await tester.tap(find.text('Info').hitTestable().first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Putar Film'));
    await tester.pumpAndSettle();

    expect(find.text('Pemutaran gagal'), findsOneWidget);

    await _closeApp(tester);
  });

  testWidgets('sub-judul "Hot picks" membuka halaman koleksi', (tester) async {
    await _openHome(tester);

    await tester.tap(find.text('Hot picks'));
    await tester.pumpAndSettle();

    expect(find.text('Pilihan yang sedang tayang di beranda'), findsOneWidget);
    expect(find.byTooltip('Kembali'), findsOneWidget);

    await tester.tap(find.byTooltip('Kembali'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Cari film'), findsOneWidget);

    await _closeApp(tester);
  });

  testWidgets('sub-judul section (Lagi ramai) membuka daftar filmnya',
      (tester) async {
    await _openHome(tester);

    await tester.tap(find.text('Lihat semua').first);
    await tester.pumpAndSettle();

    expect(find.text('Film yang lagi ramai ditonton'), findsOneWidget);

    await _closeApp(tester);
  });

  testWidgets('ikon profil membuka halaman profil', (tester) async {
    await _openHome(tester);

    await tester.tap(find.byTooltip('Profil'));
    await tester.pumpAndSettle();

    expect(find.text('Penonton CINEFLIX'), findsOneWidget);
    expect(find.text('Tentang aplikasi'), findsOneWidget);

    await _closeApp(tester);
  });

  testWidgets('bottom bar berpindah halaman sesuai tab yang diklik',
      (tester) async {
    await _openHome(tester);
    expect(find.text('Now Playing'), findsOneWidget);

    await _tapNav(tester, 'nav-explore');
    expect(find.text('Jelajahi seluruh katalog CINEFLIX'), findsOneWidget);
    expect(find.text('12 film'), findsOneWidget);

    await _tapNav(tester, 'nav-my-list');
    expect(find.text('Daftarmu masih kosong'), findsOneWidget);

    await _tapNav(tester, 'nav-home');
    expect(find.text('Now Playing'), findsOneWidget);

    await _closeApp(tester);
  });

  testWidgets('film yang disimpan di beranda muncul di My List (sinkron)',
      (tester) async {
    await _openHome(tester);

    await tester.tap(find.text('Info').hitTestable().first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Daftarku'));
    await tester.pumpAndSettle();

    // Tutup bottom sheet dengan mengetuk area gelap di atasnya.
    await tester.tapAt(const Offset(12, 12));
    await tester.pumpAndSettle();

    await _tapNav(tester, 'nav-my-list');
    expect(find.text('1 film'), findsOneWidget);
    expect(find.text('Daftarmu masih kosong'), findsNothing);

    await _closeApp(tester);
  });

  testWidgets('pencarian di Explore menyaring grid', (tester) async {
    await _openHome(tester);
    await _tapNav(tester, 'nav-explore');

    await tester.enterText(find.byType(TextField).first, 'batman');
    await tester.pumpAndSettle();

    expect(find.text('1 film'), findsOneWidget);

    await _closeApp(tester);
  });
}

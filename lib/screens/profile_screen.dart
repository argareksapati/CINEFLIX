import 'package:flutter/material.dart';

/// Halaman profil beserta pengaturannya.
///
/// Dibuka dari ikon profil di header beranda. Semua pengaturan di sini
/// berfungsi (pilihan kualitas, bahasa, notifikasi) dan tersimpan selama
/// aplikasi berjalan.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.savedCount,
    required this.onOpenMyList,
  });

  final int savedCount;

  /// Dipanggil saat pengguna memilih menu Daftarku.
  final VoidCallback onOpenMyList;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _red = Color(0xFFE50914);
  static const _muted = Color(0xFF9B9BA8);

  String _quality = 'Otomatis';
  String _language = 'Bahasa Indonesia';
  bool _notifNewRelease = true;
  bool _notifReminder = false;
  bool _notifEmail = false;

  void _openMyList() {
    Navigator.of(context).pop();
    widget.onOpenMyList();
  }

  Future<void> _showChoiceSheet({
    required String title,
    required List<String> options,
    required String current,
    required ValueChanged<String> onChanged,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1A1A22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 14),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            for (final option in options)
              ListTile(
                onTap: () {
                  onChanged(option);
                  Navigator.of(sheetContext).pop();
                },
                title: Text(
                  option,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                trailing: option == current
                    ? const Icon(Icons.check_rounded, color: _red)
                    : null,
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _showNotificationsSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1A1A22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, refresh) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 14),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Notifikasi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                value: _notifNewRelease,
                onChanged: (value) {
                  setState(() => _notifNewRelease = value);
                  refresh(() {});
                },
                activeTrackColor: _red,
                title: const Text('Film baru',
                    style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: const Text('Info judul yang baru ditambahkan',
                    style: TextStyle(color: _muted, fontSize: 11)),
              ),
              SwitchListTile(
                value: _notifReminder,
                onChanged: (value) {
                  setState(() => _notifReminder = value);
                  refresh(() {});
                },
                activeTrackColor: _red,
                title: const Text('Pengingat menonton',
                    style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: const Text('Ingatkan film di daftar simpanan',
                    style: TextStyle(color: _muted, fontSize: 11)),
              ),
              SwitchListTile(
                value: _notifEmail,
                onChanged: (value) {
                  setState(() => _notifEmail = value);
                  refresh(() {});
                },
                activeTrackColor: _red,
                title: const Text('Email',
                    style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: const Text('Ringkasan mingguan lewat email',
                    style: TextStyle(color: _muted, fontSize: 11)),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmSignOut() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Keluar dari profil?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Kamu akan kembali ke halaman beranda.',
          style: TextStyle(color: Color(0xFFC1C1CA), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Keluar',
                style: TextStyle(color: Color(0xFFE50914))),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    navigator.pop();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Kamu sudah keluar dari profil.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF25252D),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }

  void _openAbout() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const _AboutScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0D),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 28),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Kembali',
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white),
                  ),
                  const Text(
                    'Profil',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: const Color(0xFF6F1B32),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFB14B6A), width: 2),
                ),
                child: const Icon(Icons.person_rounded,
                    color: Color(0xFFFFB6C9), size: 52),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Penonton CINEFLIX',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Center(
              child: Text(
                'Belum login',
                style: TextStyle(color: _muted, fontSize: 12),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFF15151B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF272730)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _Stat(value: '${widget.savedCount}', label: 'Di My List'),
                    _divider(),
                    const _Stat(value: '12', label: 'Judul tersedia'),
                    _divider(),
                    const _Stat(value: '1', label: 'Profil'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            _Tile(
              icon: Icons.bookmark_border_rounded,
              title: 'Daftarku',
              subtitle: '${widget.savedCount} film disimpan',
              onTap: _openMyList,
            ),
            _Tile(
              icon: Icons.high_quality_rounded,
              title: 'Kualitas streaming',
              subtitle: _quality,
              onTap: () => _showChoiceSheet(
                title: 'Kualitas streaming',
                options: const ['Otomatis', 'Hemat data', '720p', '1080p'],
                current: _quality,
                onChanged: (value) => setState(() => _quality = value),
              ),
            ),
            _Tile(
              icon: Icons.notifications_none_rounded,
              title: 'Notifikasi',
              subtitle: _notifNewRelease || _notifReminder || _notifEmail
                  ? 'Aktif'
                  : 'Nonaktif',
              onTap: _showNotificationsSheet,
            ),
            _Tile(
              icon: Icons.language_rounded,
              title: 'Bahasa',
              subtitle: _language,
              onTap: () => _showChoiceSheet(
                title: 'Bahasa aplikasi',
                options: const ['Bahasa Indonesia', 'English'],
                current: _language,
                onChanged: (value) => setState(() => _language = value),
              ),
            ),
            _Tile(
              icon: Icons.info_outline_rounded,
              title: 'Tentang aplikasi',
              subtitle: 'Versi 2.0.0',
              onTap: _openAbout,
            ),
            _Tile(
              icon: Icons.logout_rounded,
              title: 'Keluar',
              subtitle: 'Keluar dari profil ini',
              onTap: _confirmSignOut,
              danger: true,
            ),
            const SizedBox(height: 26),
            const Center(
              child: Text(
                'CINEFLIX 2.0.0',
                style: TextStyle(
                  color: Color(0xFF5A5A66),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 28,
        color: const Color(0xFF2A2A33),
      );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF9B9BA8), fontSize: 10),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: danger ? const Color(0xFFE50914) : const Color(0xFFC1C1CA),
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: danger ? const Color(0xFFE50914) : Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Color(0xFF8A8A97), fontSize: 11),
      ),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: Color(0xFF6B6B78), size: 20),
    );
  }
}

/// Halaman "Tentang aplikasi".
class _AboutScreen extends StatelessWidget {
  const _AboutScreen();

  @override
  Widget build(BuildContext context) {
    const muted = Color(0xFF9B9BA8);
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0D),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Kembali',
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon:
                      const Icon(Icons.arrow_back_rounded, color: Colors.white),
                ),
                const Text(
                  'Tentang aplikasi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Center(
              child: RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'CINE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 30,
                        letterSpacing: -1.2,
                      ),
                    ),
                    TextSpan(
                      text: 'FLIX',
                      style: TextStyle(
                        color: Color(0xFFE50914),
                        fontWeight: FontWeight.w900,
                        fontSize: 30,
                        letterSpacing: -1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text('Versi 2.0.0 (build 1)',
                  style: TextStyle(color: muted, fontSize: 12)),
            ),
            const SizedBox(height: 26),
            const Text(
              'Apa itu CINEFLIX?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'CINEFLIX adalah aplikasi katalog film untuk menemukan tontonan '
              'baru. Semua judul tersusun dalam beberapa koleksi — Now Playing, '
              'Trending, Popular, dan Top Rated — sehingga kamu bisa menjelajah '
              'tanpa harus mencari satu per satu.',
              style: TextStyle(
                  color: Color(0xFFC1C1CA), height: 1.6, fontSize: 13),
            ),
            const SizedBox(height: 12),
            const Text(
              'Setiap film punya halaman detail berisi tahun, genre, durasi, '
              'rating, dan sinopsis. Film yang menarik bisa disimpan ke '
              'Daftarku supaya mudah ditemukan lagi nanti.',
              style: TextStyle(
                  color: Color(0xFFC1C1CA), height: 1.6, fontSize: 13),
            ),
            const SizedBox(height: 22),
            const Text(
              'Fitur utama',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Banner Now Playing yang berganti otomatis\n'
              '• Koleksi Trending, Popular, Top Rated, dan Top 10\n'
              '• Filter kategori serta pencarian judul atau genre\n'
              '• Halaman detail film dengan sinopsis\n'
              '• Daftarku untuk menyimpan film pilihan\n'
              '• Profil dengan pengaturan kualitas, notifikasi, dan bahasa',
              style: TextStyle(
                  color: Color(0xFFC1C1CA), height: 1.7, fontSize: 13),
            ),
            const SizedBox(height: 22),
            const Text(
              'Data dan poster',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Poster film diambil dari TMDB Image CDN saat perangkat '
              'terhubung internet, dan otomatis diganti ilustrasi lokal bila '
              'koneksi tidak tersedia. Daftar simpanan dan pengaturan berlaku '
              'selama aplikasi berjalan.',
              style: TextStyle(
                  color: Color(0xFFC1C1CA), height: 1.6, fontSize: 13),
            ),
            const SizedBox(height: 22),
            const Text(
              'Kredit',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Poster film adalah hak milik pemegang hak masing-masing dan '
              'ditampilkan melalui TMDB. Ilustrasi cadangan dibuat sendiri '
              'untuk keperluan tampilan. Nilai rating pada katalog adalah '
              'data contoh.',
              style: TextStyle(
                  color: Color(0xFFC1C1CA), height: 1.6, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

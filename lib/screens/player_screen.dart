import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../widgets/movie_artwork.dart';

/// Halaman pemutar video "pura-pura".
///
/// Tampil seperti akan memutar film (poster sebagai frame, kontrol pemutar
/// di bawah), lalu menampilkan pesan bahwa pemutaran gagal karena aplikasi
/// ini masih berupa demo tampilan.
class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key, required this.movie});

  final Movie movie;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  static const _red = Color(0xFFE50914);

  bool _loading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startPlayback();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPlayback() {
    _timer?.cancel();
    setState(() => _loading = true);
    _timer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // "Frame" video: poster film yang digelapkan.
          Opacity(
            opacity: 0.22,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: MovieArtwork(movie: movie),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xB3000000),
                  Color(0x99000000),
                  Color(0xF2000000),
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(movie),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: _loading ? _buildLoading() : _buildError(movie),
                    ),
                  ),
                ),
                _buildFakeControls(movie),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(Movie movie) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 20, 0),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Kembali',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${movie.year}  •  ${movie.genre}  •  ${movie.runtimeLabel}',
                  style: const TextStyle(
                    color: Color(0xFF9B9BA8),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        SizedBox(
          width: 42,
          height: 42,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: _red,
            backgroundColor: Color(0xFF2A2A34),
          ),
        ),
        SizedBox(height: 18),
        Text(
          'Menyiapkan pemutaran…',
          style: TextStyle(color: Color(0xFFC1C1CA), fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildError(Movie movie) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 74,
          height: 74,
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C24),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF33333F)),
          ),
          child: const Icon(Icons.videocam_off_rounded,
              color: Color(0xFFE50914), size: 34),
        ),
        const SizedBox(height: 22),
        const Text(
          'Pemutaran gagal',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Video "${movie.title}" tidak bisa diputar karena aplikasi ini '
          'masih berupa demo tampilan. Fitur streaming belum tersedia.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFA9A9B4),
            fontSize: 13,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: _startPlayback,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white30),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba lagi'),
            ),
            const SizedBox(width: 10),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).maybePop(),
              style: FilledButton.styleFrom(
                backgroundColor: _red,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Kembali'),
            ),
          ],
        ),
      ],
    );
  }

  /// Kontrol pemutar palsu di bagian bawah, sengaja tidak berfungsi.
  Widget _buildFakeControls(Movie movie) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(height: 4, color: const Color(0xFF34343E)),
                Container(
                  height: 4,
                  width: 26,
                  decoration: BoxDecoration(
                    color: _loading ? const Color(0xFF6B6B78) : _red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('00:00',
                  style: TextStyle(color: Color(0xFF9B9BA8), fontSize: 10)),
              const Spacer(),
              Text(
                movie.runtimeLabel,
                style: const TextStyle(color: Color(0xFF9B9BA8), fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.play_arrow_rounded,
                  color: Color(0xFF6B6B78), size: 30),
              Icon(Icons.volume_up_rounded, color: Color(0xFF6B6B78), size: 24),
              Icon(Icons.subtitles_outlined,
                  color: Color(0xFF6B6B78), size: 24),
              Icon(Icons.fullscreen_rounded,
                  color: Color(0xFF6B6B78), size: 26),
            ],
          ),
        ],
      ),
    );
  }
}

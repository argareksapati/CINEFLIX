import 'package:flutter/material.dart';

import '../models/movie.dart';
import 'movie_artwork.dart';

const _red = Color(0xFFE50914);
const _muted = Color(0xFF9B9BA8);

/// Menampilkan bottom sheet detail film.
///
/// [saved] adalah status awal (dari daftar simpanan aplikasi), dan
/// [onToggleSaved] dipanggil setiap kali tombol Daftarku ditekan supaya
/// status di halaman lain (My List) ikut sinkron.
Future<void> showMovieDetailSheet(
  BuildContext context, {
  required Movie movie,
  required bool saved,
  required ValueChanged<Movie> onToggleSaved,
  required ValueChanged<Movie> onPlayMovie,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: const Color(0xFF1A1A22),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
    builder: (sheetContext) => _MovieDetailSheet(
      movie: movie,
      initiallySaved: saved,
      onToggleSaved: onToggleSaved,
      onPlayMovie: onPlayMovie,
      sheetContext: sheetContext,
    ),
  );
}

class _MovieDetailSheet extends StatefulWidget {
  const _MovieDetailSheet({
    required this.movie,
    required this.initiallySaved,
    required this.onToggleSaved,
    required this.onPlayMovie,
    required this.sheetContext,
  });

  final Movie movie;
  final bool initiallySaved;
  final ValueChanged<Movie> onToggleSaved;
  final ValueChanged<Movie> onPlayMovie;
  final BuildContext sheetContext;

  @override
  State<_MovieDetailSheet> createState() => _MovieDetailSheetState();
}

class _MovieDetailSheetState extends State<_MovieDetailSheet> {
  late bool _saved = widget.initiallySaved;

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 112,
                    height: 160,
                    child: MovieArtwork(movie: movie),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CINEFLIX PICKS',
                        style: TextStyle(
                          color: _red,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        movie.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${movie.year}  •  ${movie.genre}  •  ${movie.runtimeLabel}',
                        style: const TextStyle(color: _muted, fontSize: 12),
                      ),
                      const SizedBox(height: 9),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Color(0xFFFFC94B), size: 18),
                          const SizedBox(width: 5),
                          Text(
                            '${movie.rating.toStringAsFixed(1)} / 10',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const Text(
              'SINOPSIS',
              style: TextStyle(
                color: _muted,
                fontWeight: FontWeight.w800,
                fontSize: 11,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              movie.synopsis,
              style: const TextStyle(
                color: Color(0xFFE4E4EA),
                height: 1.55,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(widget.sheetContext).pop();
                      widget.onPlayMovie(movie);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: _red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Putar Film'),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    widget.onToggleSaved(movie);
                    setState(() => _saved = !_saved);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 15),
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(_saved ? Icons.check : Icons.add),
                  label: Text(_saved ? 'Tersimpan' : 'Daftarku'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

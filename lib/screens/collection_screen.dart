import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../widgets/movie_detail_sheet.dart';
import '../widgets/movie_grid.dart';

/// Halaman daftar film untuk satu koleksi (mis. "Lagi ramai", "Rating
/// tertinggi"). Dibuka dari sub-judul section di beranda lewat
/// `Navigator.push`, jadi punya tombol kembali sendiri.
class CollectionScreen extends StatelessWidget {
  const CollectionScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.movies,
    required this.savedIds,
    required this.onToggleSaved,
    required this.onPlayMovie,
  });

  final String title;
  final String subtitle;
  final List<Movie> movies;
  final Set<String> savedIds;
  final ValueChanged<Movie> onToggleSaved;
  final ValueChanged<Movie> onPlayMovie;

  void _openDetails(BuildContext context, Movie movie) {
    showMovieDetailSheet(
      context,
      movie: movie,
      saved: savedIds.contains(movie.id),
      onToggleSaved: onToggleSaved,
      onPlayMovie: onPlayMovie,
    );
  }

  @override
  Widget build(BuildContext context) {
    const muted = Color(0xFF9B9BA8);
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0D),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          'CINEFLIX',
                          style: TextStyle(
                            color: Color(0xFFE50914),
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            letterSpacing: 1.6,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${movies.length} film',
                          style: const TextStyle(color: muted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 2),
                    child: Text(
                      title,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontSize: 27,
                              ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                    child: Text(
                      subtitle,
                      style: const TextStyle(color: muted, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            if (movies.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(28),
                    child: Text(
                      'Belum ada film pada koleksi ini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: muted),
                    ),
                  ),
                ),
              )
            else
              MovieGridSliver(
                movies: movies,
                onMovieTap: (movie) => _openDetails(context, movie),
              ),
          ],
        ),
      ),
    );
  }
}

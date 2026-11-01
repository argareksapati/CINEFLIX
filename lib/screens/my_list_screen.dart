import 'package:flutter/material.dart';

import '../data/movie_catalog.dart';
import '../models/movie.dart';
import '../widgets/movie_detail_sheet.dart';
import '../widgets/movie_grid.dart';

/// Halaman My List: menampilkan film yang ditandai "Daftarku".
/// Data disimpan di [AppShell] sehingga sinkron dengan halaman lain.
class MyListScreen extends StatelessWidget {
  const MyListScreen({
    super.key,
    required this.savedIds,
    required this.onToggleSaved,
    required this.onPlayMovie,
    required this.onExplore,
  });

  final Set<String> savedIds;
  final ValueChanged<Movie> onToggleSaved;
  final ValueChanged<Movie> onPlayMovie;

  /// Pindah ke tab Explore ketika daftar masih kosong.
  final VoidCallback onExplore;

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
    final movies = MovieCatalog.movies
        .where((movie) => savedIds.contains(movie.id))
        .toList();

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: PageHeading(
              title: 'My List',
              subtitle: 'Film yang kamu tandai dengan tombol Daftarku',
              trailing: Text(
                '${movies.length} film',
                style: const TextStyle(color: muted, fontSize: 11),
              ),
            ),
          ),
          if (movies.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bookmark_border_rounded,
                          color: muted, size: 56),
                      const SizedBox(height: 16),
                      const Text(
                        'Daftarmu masih kosong',
                        style: TextStyle(
                          fontSize: 19,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Buka detail film lalu ketuk "Daftarku" untuk '
                        'menyimpannya di sini.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: muted, height: 1.5),
                      ),
                      const SizedBox(height: 22),
                      FilledButton.icon(
                        onPressed: onExplore,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFE50914),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.explore_outlined, size: 18),
                        label: const Text('Jelajahi katalog'),
                      ),
                    ],
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
    );
  }
}

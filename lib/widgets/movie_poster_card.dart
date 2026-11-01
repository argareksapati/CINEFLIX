import 'package:flutter/material.dart';

import '../models/movie.dart';
import 'movie_artwork.dart';

class MoviePosterCard extends StatelessWidget {
  const MoviePosterCard({
    super.key,
    required this.movie,
    required this.onTap,
    this.width = 140,
  });

  final Movie movie;
  final ValueChanged<Movie> onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => onTap(movie),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 0.74,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MovieArtwork(movie: movie),
                    Positioned(
                      top: 9,
                      left: 9,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE50914),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'C',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              movie.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.star_rounded,
                    size: 13, color: Color(0xFFFFC94B)),
                const SizedBox(width: 2),
                Text(
                  movie.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFE2E2E9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    movie.genre,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9B9BA8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MovieSection extends StatelessWidget {
  const MovieSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.movies,
    required this.onMovieTap,
    this.onSubtitleTap,
  });

  final String title;
  final String subtitle;
  final List<Movie> movies;
  final ValueChanged<Movie> onMovieTap;

  /// Jika diisi, sub-judul (mis. "Lagi ramai") bisa diketuk untuk membuka
  /// halaman daftar film koleksi tersebut.
  final VoidCallback? onSubtitleTap;

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) return const SizedBox.shrink();

    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = screenWidth < 375 ? 125.0 : 140.0;
    final rowHeight = cardWidth / 0.74 + 52;

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 22,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE50914),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF9B9BA8),
                  ),
                ),
                if (onSubtitleTap != null) ...[
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: onSubtitleTap,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Lihat semua',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFE50914),
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded,
                              size: 15, color: Color(0xFFE50914)),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: rowHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const BouncingScrollPhysics(),
              itemCount: movies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) => MoviePosterCard(
                movie: movies[index],
                width: cardWidth,
                onTap: onMovieTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reference: ranking-strip idea adapted from AkshayShineKrishna's clone.
/// Ranks are computed from *demo* scores, not an official top-ten chart.
class TopTenSection extends StatelessWidget {
  const TopTenSection({
    super.key,
    required this.movies,
    required this.onMovieTap,
  });

  final List<Movie> movies;
  final ValueChanged<Movie> onMovieTap;

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.emoji_events_rounded,
                    color: Color(0xFFE50914), size: 23),
                SizedBox(width: 10),
                Text(
                  'Top 10 Pilihan',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const SizedBox(height: 7),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Peringkat ilustrasi untuk demonstrasi UI',
              style: TextStyle(color: Color(0xFF9B9BA8), fontSize: 11),
            ),
          ),
          const SizedBox(height: 13),
          SizedBox(
            height: 171,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: movies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 4),
              itemBuilder: (context, index) {
                final movie = movies[index];
                return InkWell(
                  onTap: () => onMovieTap(movie),
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 162,
                    child: Stack(
                      children: [
                        Positioned(
                          left: index == 9 ? 0 : 7,
                          bottom: 5,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              height: 0.9,
                              fontSize: index == 9 ? 70 : 100,
                              fontWeight: FontWeight.w900,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 2.6
                                ..color = const Color(0xFFB3B3B9),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 4,
                          top: 0,
                          bottom: 0,
                          width: 104,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: MovieArtwork(movie: movie),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

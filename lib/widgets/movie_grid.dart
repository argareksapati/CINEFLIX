import 'package:flutter/material.dart';

import '../models/movie.dart';
import 'movie_poster_card.dart';

/// Grid poster 2 kolom (3 kolom untuk layar lebar) yang dipakai di halaman
/// Explore dan My List. Mengembalikan sliver agar bisa digabung dengan
/// header di [CustomScrollView].
class MovieGridSliver extends StatelessWidget {
  const MovieGridSliver({
    super.key,
    required this.movies,
    required this.onMovieTap,
  });

  final List<Movie> movies;
  final ValueChanged<Movie> onMovieTap;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final columns = screenWidth >= 700 ? 3 : 2;
    const horizontalPadding = 20.0;
    const spacing = 12.0;
    final cardWidth =
        (screenWidth - horizontalPadding * 2 - spacing * (columns - 1)) /
            columns;
    final cellHeight = cardWidth / 0.74 + 54;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
          horizontalPadding, 6, horizontalPadding, 24),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: spacing,
          mainAxisSpacing: 18,
          mainAxisExtent: cellHeight,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => MoviePosterCard(
            movie: movies[index],
            width: cardWidth,
            onTap: onMovieTap,
          ),
          childCount: movies.length,
        ),
      ),
    );
  }
}

/// Header sederhana berisi judul halaman + subjudul.
class PageHeading extends StatelessWidget {
  const PageHeading({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 26,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF9B9BA8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

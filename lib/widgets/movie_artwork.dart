import 'package:flutter/material.dart';

import '../models/movie.dart';

/// Public TMDB poster URL is used *only at runtime*. We never redistribute
/// third-party film poster files. The original offline fallback is bundled.
class MovieArtwork extends StatelessWidget {
  const MovieArtwork({
    super.key,
    required this.movie,
    this.fit = BoxFit.cover,
  });

  final Movie movie;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    Widget offline() => Image.asset(movie.posterAsset, fit: fit);

    return Image.network(
      movie.posterUrl,
      fit: fit,
      // Show the supplied offline art *immediately* while downloading.
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : offline(),
      errorBuilder: (context, exception, stackTrace) => offline(),
    );
  }
}

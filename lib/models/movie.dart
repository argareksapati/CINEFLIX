/// Movie metadata for UI demonstration. Scores are illustrative, not live TMDB scores.
class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.synopsis,
    required this.posterAsset,
    required this.posterUrl,
    required this.year,
    required this.durationMinutes,
    required this.rating,
  });

  final String id;
  final String title;
  final String genre;
  final String synopsis;
  final String posterAsset;
  final String posterUrl;
  final int year;
  final int durationMinutes;
  final double rating;

  String get runtimeLabel =>
      '${durationMinutes ~/ 60}j ${durationMinutes % 60}m';
}

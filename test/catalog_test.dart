import 'package:flutter_test/flutter_test.dart';
import 'package:cineflix_flutter/data/movie_catalog.dart';

void main() {
  test('catalog contains 12 unique demo titles', () {
    expect(MovieCatalog.movies, hasLength(12));
    final ids = MovieCatalog.movies.map((movie) => movie.id).toSet();
    expect(ids, hasLength(MovieCatalog.movies.length));
  });

  test('every movie has an available category and image path', () {
    for (final movie in MovieCatalog.movies) {
      expect(MovieCatalog.categories, contains(movie.genre));
      expect(movie.posterAsset, startsWith('assets/offline_posters/'));
      expect(movie.posterUrl, startsWith('https://image.tmdb.org/t/p/w500/'));
      expect(movie.rating, inInclusiveRange(0, 10));
    }
  });

  test('recommended collections are populated and sorted correctly', () {
    expect(MovieCatalog.featured, hasLength(3));
    expect(MovieCatalog.topTen, hasLength(10));
    expect(MovieCatalog.trending, isNotEmpty);
    expect(MovieCatalog.popular, isNotEmpty);
    for (var i = 1; i < MovieCatalog.topRated.length; i++) {
      expect(
        MovieCatalog.topRated[i - 1].rating,
        greaterThanOrEqualTo(MovieCatalog.topRated[i].rating),
      );
    }
  });
}

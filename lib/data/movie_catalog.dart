import '../models/movie.dart';

/// Curated, static educational demo list. No TMDB API key or backend required.
abstract final class MovieCatalog {
  static const categories = <String>[
    'Semua',
    'Sci-Fi',
    'Aksi',
    'Thriller',
    'Drama',
    'Animasi',
  ];

  static const movies = <Movie>[
    Movie(
      id: 'dune_part_two',
      title: 'Dune: Part Two',
      genre: 'Sci-Fi',
      synopsis:
          'Sang pewaris Atreides berjuang bersama bangsa Fremen menghadapi masa depan Arrakis.',
      posterAsset: 'assets/offline_posters/dune_part_two.jpg',
      posterUrl:
          'https://image.tmdb.org/t/p/w500/1pdfLvkbY9ohJlCjQH2CZjjYVvJ.jpg',
      year: 2024,
      durationMinutes: 166,
      rating: 8.4,
    ),
    Movie(
      id: 'spider_verse',
      title: 'Spider-Man: Across The Spider-Verse',
      genre: 'Aksi',
      synopsis:
          'Miles Morales melintasi berbagai semesta dan bertemu kumpulan Spider-People.',
      posterAsset: 'assets/offline_posters/spider_verse.jpg',
      posterUrl:
          'https://image.tmdb.org/t/p/w500/8Vt6mWEReuy4Of61Lnj5Xj704m8.jpg',
      year: 2023,
      durationMinutes: 140,
      rating: 8.6,
    ),
    Movie(
      id: 'oppenheimer',
      title: 'Oppenheimer',
      genre: 'Drama',
      synopsis:
          'Kisah ilmuwan J. Robert Oppenheimer dalam proyek yang mengubah sejarah dunia.',
      posterAsset: 'assets/offline_posters/oppenheimer.jpg',
      posterUrl:
          'https://image.tmdb.org/t/p/w500/ptpr0kGAckfQkJeJIt8st5dglvd.jpg',
      year: 2023,
      durationMinutes: 180,
      rating: 8.6,
    ),
    Movie(
      id: 'interstellar',
      title: 'Interstellar',
      genre: 'Sci-Fi',
      synopsis:
          'Sejumlah penjelajah mencari harapan baru bagi umat manusia di luar galaksi.',
      posterAsset: 'assets/offline_posters/interstellar.jpg',
      posterUrl:
          'https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
      year: 2014,
      durationMinutes: 169,
      rating: 8.7,
    ),
    Movie(
      id: 'the_batman',
      title: 'The Batman',
      genre: 'Thriller',
      synopsis:
          'Batman menyelidiki korupsi di Gotham ketika sosok Riddler mengancam kota.',
      posterAsset: 'assets/offline_posters/the_batman.jpg',
      posterUrl:
          'https://image.tmdb.org/t/p/w500/74xTEgt7R36Fpooo50r9T25onhq.jpg',
      year: 2022,
      durationMinutes: 176,
      rating: 8.3,
    ),
    Movie(
      id: 'inside_out_2',
      title: 'Inside Out 2',
      genre: 'Animasi',
      synopsis: 'Riley memasuki masa remaja dan bertemu berbagai emosi baru.',
      posterAsset: 'assets/offline_posters/inside_out_2.jpg',
      posterUrl:
          'https://image.tmdb.org/t/p/w500/vpnVM9B6NMmQpWeZvzLvDESb2QY.jpg',
      year: 2024,
      durationMinutes: 96,
      rating: 7.6,
    ),
    Movie(
      id: 'kung_fu_panda_4',
      title: 'Kung Fu Panda 4',
      genre: 'Animasi',
      synopsis:
          'Po menghadapi musuh baru sambil menyiapkan penerus Dragon Warrior.',
      posterAsset: 'assets/offline_posters/kung_fu_panda_4.jpg',
      posterUrl:
          'https://image.tmdb.org/t/p/w500/kDp1vUBnMpe8ak4rjgl3cLELqjU.jpg',
      year: 2024,
      durationMinutes: 94,
      rating: 7.1,
    ),
    Movie(
      id: 'everything_everywhere',
      title: 'Everything Everywhere All At Once',
      genre: 'Sci-Fi',
      synopsis:
          'Seorang perempuan biasa menghadapi kekacauan berbagai dunia paralel.',
      posterAsset: 'assets/offline_posters/everything_everywhere.jpg',
      posterUrl:
          'https://image.tmdb.org/t/p/w500/w3LxiVYdWWRvEVdn5RYq6jIqkb1.jpg',
      year: 2022,
      durationMinutes: 139,
      rating: 7.9,
    ),
    Movie(
      id: 'fight_club',
      title: 'Fight Club',
      genre: 'Thriller',
      synopsis:
          'Seorang pekerja kantoran berkenalan dengan dunia rahasia yang mengubah hidupnya.',
      posterAsset: 'assets/offline_posters/fight_club.jpg',
      posterUrl:
          'https://image.tmdb.org/t/p/w500/jSziioSwPVrOy9Yow3XhWIBDjq1.jpg',
      year: 1999,
      durationMinutes: 139,
      rating: 8.6,
    ),
    Movie(
      id: 'rush',
      title: 'Rush',
      genre: 'Drama',
      synopsis:
          'Persaingan dua pembalap Formula 1 mencapai puncaknya di lintasan.',
      posterAsset: 'assets/offline_posters/rush.jpg',
      posterUrl:
          'https://image.tmdb.org/t/p/w500/5hpcfL3WH5ArSPUlfD4E1TtaOd0.jpg',
      year: 2013,
      durationMinutes: 123,
      rating: 8.1,
    ),
    Movie(
      id: 'twenty_eight_days',
      title: '28 Days Later',
      genre: 'Thriller',
      synopsis:
          'Sejumlah penyintas berusaha selamat setelah wabah mematikan melanda Inggris.',
      posterAsset: 'assets/offline_posters/twenty_eight_days.jpg',
      posterUrl:
          'https://image.tmdb.org/t/p/w500/sQckQRt17VaWbo39GIu0TMOiszq.jpg',
      year: 2002,
      durationMinutes: 113,
      rating: 7.2,
    ),
    Movie(
      id: 'novocaine',
      title: 'Novocaine',
      genre: 'Aksi',
      synopsis:
          'Seorang pria memanfaatkan kondisi uniknya untuk menyelamatkan orang yang dicintai.',
      posterAsset: 'assets/offline_posters/novocaine.jpg',
      posterUrl:
          'https://image.tmdb.org/t/p/w500/xmMHGz9dVRaMY6rRAlEX4W0Wdhm.jpg',
      year: 2025,
      durationMinutes: 110,
      rating: 6.8,
    ),
  ];

  static Movie find(String id) => movies.firstWhere((movie) => movie.id == id);

  static List<Movie> get featured => [
        find('dune_part_two'),
        find('spider_verse'),
        find('oppenheimer'),
      ];

  static List<Movie> get trending => [
        find('spider_verse'),
        find('dune_part_two'),
        find('inside_out_2'),
        find('novocaine'),
        find('the_batman'),
        find('everything_everywhere'),
        find('oppenheimer'),
        find('interstellar'),
      ];

  static List<Movie> get popular => [
        find('interstellar'),
        find('kung_fu_panda_4'),
        find('the_batman'),
        find('spider_verse'),
        find('rush'),
        find('inside_out_2'),
        find('fight_club'),
        find('dune_part_two'),
      ];

  static List<Movie> get topRated {
    final result = [...movies]..sort((a, b) => b.rating.compareTo(a.rating));
    return result;
  }

  static List<Movie> get topTen => topRated.take(10).toList();
}

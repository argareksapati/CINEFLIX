import 'dart:math' as math;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../data/movie_catalog.dart';
import '../models/movie.dart';
import '../widgets/movie_artwork.dart';
import '../widgets/movie_detail_sheet.dart';
import '../widgets/movie_poster_card.dart';
import 'collection_screen.dart';

/// Halaman beranda: katalog horizontal + banner Now Playing.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.savedIds,
    required this.onToggleSaved,
    required this.onPlayMovie,
    required this.onOpenProfile,
  });

  final Set<String> savedIds;
  final ValueChanged<Movie> onToggleSaved;
  final ValueChanged<Movie> onPlayMovie;
  final VoidCallback onOpenProfile;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _red = Color(0xFFE50914);
  static const _muted = Color(0xFF9B9BA8);

  final _searchController = TextEditingController();
  String _selectedCategory = 'Semua';
  String _searchText = '';
  bool _searchOpen = false;
  int _currentFeatured = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Movie> _filter(List<Movie> movies) {
    return movies.where((movie) {
      final categoryOk =
          _selectedCategory == 'Semua' || movie.genre == _selectedCategory;
      final queryOk = _searchText.isEmpty ||
          movie.title.toLowerCase().contains(_searchText.toLowerCase()) ||
          movie.genre.toLowerCase().contains(_searchText.toLowerCase());
      return categoryOk && queryOk;
    }).toList();
  }

  void _openDetails(Movie movie) {
    showMovieDetailSheet(
      context,
      movie: movie,
      saved: widget.savedIds.contains(movie.id),
      onToggleSaved: widget.onToggleSaved,
      onPlayMovie: widget.onPlayMovie,
    );
  }

  /// Membuka halaman daftar film untuk satu koleksi.
  void _openCollection(String title, String subtitle, List<Movie> movies) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CollectionScreen(
          title: title,
          subtitle: subtitle,
          movies: movies,
          savedIds: widget.savedIds,
          onToggleSaved: widget.onToggleSaved,
          onPlayMovie: widget.onPlayMovie,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final featureHeight =
        math.min(455.0, math.max(360.0, screenSize.height * 0.49));
    final matchingMovies = _filter(MovieCatalog.movies);
    final primaryFeatured = _filter(MovieCatalog.featured);
    final featured = primaryFeatured.isNotEmpty
        ? primaryFeatured
        : matchingMovies.take(3).toList();
    final trending = _filter(MovieCatalog.trending);
    final popular = _filter(MovieCatalog.popular);
    final rated = _filter(MovieCatalog.topRated);

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(child: _buildCategoryBar()),
          if (matchingMovies.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.movie_filter_outlined,
                          color: _muted, size: 56),
                      SizedBox(height: 14),
                      Text(
                        'Film tidak ditemukan',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Coba kata kunci atau kategori lain.',
                          style: TextStyle(color: _muted)),
                    ],
                  ),
                ),
              ),
            )
          else ...[
            SliverToBoxAdapter(child: _buildHeadline(featured)),
            SliverToBoxAdapter(
              child: CarouselSlider.builder(
                key: ValueKey('$_selectedCategory/$_searchText'),
                itemCount: featured.length,
                itemBuilder: (context, index, realIndex) =>
                    _buildFeaturedCard(featured[index]),
                options: CarouselOptions(
                  height: featureHeight,
                  viewportFraction: screenSize.width > 700 ? 0.54 : 0.88,
                  enlargeCenterPage: true,
                  enlargeFactor: 0.09,
                  enableInfiniteScroll: featured.length > 1,
                  autoPlay: featured.length > 1 && !_searchOpen,
                  autoPlayInterval: const Duration(seconds: 5),
                  autoPlayAnimationDuration: const Duration(milliseconds: 700),
                  autoPlayCurve: Curves.easeInOutCubic,
                  onPageChanged: (index, reason) {
                    if (mounted) {
                      setState(() => _currentFeatured = index);
                    }
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildIndicators(featured.length)),
            SliverToBoxAdapter(
              child: MovieSection(
                title: 'Trending Now',
                subtitle: 'Lagi ramai',
                movies: trending,
                onMovieTap: _openDetails,
                onSubtitleTap: () => _openCollection(
                  'Trending Now',
                  'Film yang lagi ramai ditonton',
                  trending,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: MovieSection(
                title: 'Popular',
                subtitle: 'Favorit penonton',
                movies: popular,
                onMovieTap: _openDetails,
                onSubtitleTap: () => _openCollection(
                  'Popular',
                  'Favorit penonton CINEFLIX',
                  popular,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: MovieSection(
                title: 'Top Rated',
                subtitle: 'Rating tertinggi',
                movies: rated,
                onMovieTap: _openDetails,
                onSubtitleTap: () => _openCollection(
                  'Top Rated',
                  'Rating tertinggi versi demo',
                  rated,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: TopTenSection(
                movies: _filter(MovieCatalog.topTen),
                onMovieTap: _openDetails,
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(22, 5, 22, 32),
                child: Text(
                  'CINEFLIX UI DEMO • Poster online melalui TMDB. '
                  'Hak gambar milik pemegang hak terkait. '
                  'Nilai rating adalah data contoh, bukan skor real-time.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, height: 1.5, color: _muted),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 17, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_searchOpen)
            Container(
              height: 47,
              decoration: BoxDecoration(
                color: const Color(0xFF202029),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(Icons.search, color: _muted, size: 21),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      onChanged: (text) => setState(() {
                        _searchText = text;
                        _currentFeatured = 0;
                      }),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Cari judul atau genre...',
                        hintStyle: TextStyle(color: _muted),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Tutup pencarian',
                    onPressed: () {
                      _searchController.clear();
                      FocusScope.of(context).unfocus();
                      setState(() {
                        _searchOpen = false;
                        _searchText = '';
                        _currentFeatured = 0;
                      });
                    },
                    icon: const Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'CINE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 26,
                          letterSpacing: -1.3,
                        ),
                      ),
                      TextSpan(
                        text: 'FLIX',
                        style: TextStyle(
                          color: _red,
                          fontWeight: FontWeight.w900,
                          fontSize: 26,
                          letterSpacing: -1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Cari film',
                  onPressed: () => setState(() => _searchOpen = true),
                  icon: const Icon(Icons.search_rounded, color: Colors.white),
                ),
                const SizedBox(width: 4),
                Tooltip(
                  message: 'Profil',
                  child: InkWell(
                    onTap: widget.onOpenProfile,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6F1B32),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFB14B6A)),
                      ),
                      child: const Icon(Icons.person_rounded,
                          color: Color(0xFFFFB6C9), size: 20),
                    ),
                  ),
                ),
              ],
            ),
          if (!_searchOpen) ...[
            const SizedBox(height: 5),
            const Text(
              'DUNIA CERITA, DALAM GENGGAMAN',
              style: TextStyle(
                color: _muted,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.1,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryBar() {
    return SizedBox(
      height: 62,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 11),
        itemCount: MovieCatalog.categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = MovieCatalog.categories[index];
          final selected = category == _selectedCategory;
          return InkWell(
            onTap: () => setState(() {
              _selectedCategory = category;
              _currentFeatured = 0;
            }),
            borderRadius: BorderRadius.circular(30),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 17),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? _red : const Color(0xFF202029),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: selected ? _red : const Color(0xFF303039),
                ),
              ),
              child: Text(
                category,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                  color: selected ? Colors.white : const Color(0xFFC1C1CA),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeadline(List<Movie> featured) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 17, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FEATURED COLLECTION',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _red,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.4,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Now Playing',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 27,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: () => _openCollection(
              'Now Playing',
              'Pilihan yang sedang tayang di beranda',
              featured,
            ),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.local_fire_department_rounded,
                      color: Color(0xFFFFB256), size: 22),
                  SizedBox(width: 4),
                  Text('Hot picks',
                      style: TextStyle(color: Color(0xFFCACAD1), fontSize: 11)),
                  Icon(Icons.chevron_right_rounded,
                      size: 16, color: Color(0xFFCACAD1)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(Movie movie) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          MovieArtwork(movie: movie),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.38, 0.68, 1.0],
                colors: [
                  Color(0x22000000),
                  Color(0x00000000),
                  Color(0xAA000000),
                  Color(0xF9000000),
                ],
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 17,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xC9111115),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.white24),
              ),
              child: const Text(
                'C  •  FEATURED',
                style: TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4),
              ),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 19,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 17, color: Color(0xFFFFC94B)),
                    const SizedBox(width: 4),
                    Text(
                      movie.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text('•', style: TextStyle(color: Colors.white70)),
                    const SizedBox(width: 10),
                    Text(
                      '${movie.year}  •  ${movie.genre}',
                      style: const TextStyle(
                          color: Color(0xFFE8E8E8), fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  movie.title.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 29,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                    height: 1.01,
                    shadows: [Shadow(color: Colors.black87, blurRadius: 12)],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  movie.synopsis,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.42,
                    color: Color(0xFFDBDBE1),
                  ),
                ),
                const SizedBox(height: 17),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => widget.onPlayMovie(movie),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded, size: 20),
                        label: const Text(
                          'Play',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => _openDetails(movie),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0x66323238),
                        side: const BorderSide(color: Colors.white38),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 13, vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.info_outline_rounded, size: 18),
                      label: const Text('Info', style: TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicators(int count) {
    final activeIndex = _currentFeatured < count ? _currentFeatured : 0;
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (index) {
          final selected = index == activeIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: selected ? 25 : 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: selected ? _red : const Color(0xFF4B4B55),
              borderRadius: BorderRadius.circular(8),
            ),
          );
        }),
      ),
    );
  }
}

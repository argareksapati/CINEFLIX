import 'package:flutter/material.dart';

import '../data/movie_catalog.dart';
import '../models/movie.dart';
import '../widgets/movie_detail_sheet.dart';
import '../widgets/movie_grid.dart';

/// Halaman Explore: menjelajah seluruh katalog dengan pencarian dan filter
/// kategori. Tetap satu halaman (tanpa push route), hanya berganti tab.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({
    super.key,
    required this.savedIds,
    required this.onToggleSaved,
    required this.onPlayMovie,
  });

  final Set<String> savedIds;
  final ValueChanged<Movie> onToggleSaved;
  final ValueChanged<Movie> onPlayMovie;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  static const _red = Color(0xFFE50914);
  static const _muted = Color(0xFF9B9BA8);

  final _searchController = TextEditingController();
  String _selectedCategory = 'Semua';
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Movie> get _results => MovieCatalog.movies
      .where((movie) =>
          (_selectedCategory == 'Semua' || movie.genre == _selectedCategory) &&
          (_query.isEmpty ||
              movie.title.toLowerCase().contains(_query.toLowerCase()) ||
              movie.genre.toLowerCase().contains(_query.toLowerCase())))
      .toList();

  void _openDetails(Movie movie) {
    showMovieDetailSheet(
      context,
      movie: movie,
      saved: widget.savedIds.contains(movie.id),
      onToggleSaved: widget.onToggleSaved,
      onPlayMovie: widget.onPlayMovie,
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: PageHeading(
              title: 'Explore',
              subtitle: 'Jelajahi seluruh katalog CINEFLIX',
              trailing: Text(
                '${results.length} film',
                style: const TextStyle(color: _muted, fontSize: 11),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF202029),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2C2C36)),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    const Icon(Icons.search, color: _muted, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (text) => setState(() => _query = text),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Cari judul atau genre...',
                          hintStyle: TextStyle(color: _muted),
                        ),
                      ),
                    ),
                    if (_query.isNotEmpty)
                      IconButton(
                        tooltip: 'Hapus pencarian',
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.close, color: Colors.white70),
                      ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 58,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                itemCount: MovieCatalog.categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = MovieCatalog.categories[index];
                  final selected = category == _selectedCategory;
                  return InkWell(
                    onTap: () => setState(() => _selectedCategory = category),
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
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 12,
                          color:
                              selected ? Colors.white : const Color(0xFFC1C1CA),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (results.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded, color: _muted, size: 52),
                      SizedBox(height: 14),
                      Text(
                        'Tidak ada hasil',
                        style: TextStyle(
                          fontSize: 19,
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
          else
            MovieGridSliver(movies: results, onMovieTap: _openDetails),
        ],
      ),
    );
  }
}

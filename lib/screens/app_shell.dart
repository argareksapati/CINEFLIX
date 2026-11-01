import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../widgets/cineflix_bottom_bar.dart';
import '../widgets/cineflix_intro.dart';
import 'explore_screen.dart';
import 'home_screen.dart';
import 'my_list_screen.dart';
import 'player_screen.dart';
import 'profile_screen.dart';

/// Kerangka aplikasi: menyalakan animasi intro sekali di awal, menyimpan
/// state bersama (film yang disimpan), dan menjadi tempat bottom navigation
/// berpindah halaman.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with TickerProviderStateMixin {
  int _index = 0;
  bool _showIntro = true;
  final Set<String> _savedIds = <String>{};

  /// Animasi masuk konten setelah intro selesai.
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 720),
  );
  late final Animation<double> _entranceFade = CurvedAnimation(
    parent: _entrance,
    curve: const Interval(0, 0.85, curve: Curves.easeOut),
  );
  late final Animation<Offset> _entranceSlide = Tween<Offset>(
    begin: const Offset(0, 0.045),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic));

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  void _onIntroFinished() {
    if (!mounted || !_showIntro) return;
    setState(() => _showIntro = false);
    _entrance.forward();
  }

  void _selectTab(int index) {
    if (index == _index) return;
    setState(() => _index = index);
  }

  void _toggleSaved(Movie movie) {
    setState(() {
      if (!_savedIds.add(movie.id)) {
        _savedIds.remove(movie.id);
      }
    });
  }

  void _openPlayer(Movie movie) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => PlayerScreen(movie: movie)),
    );
  }

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProfileScreen(
          savedCount: _savedIds.length,
          onOpenMyList: () => _selectTab(2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tombol back di tab lain kembali ke Home dulu, bukan keluar aplikasi.
    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _index != 0) {
          setState(() => _index = 0);
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Scaffold(
            backgroundColor: const Color(0xFF0B0B0D),
            body: FadeTransition(
              opacity: _entranceFade,
              child: SlideTransition(
                position: _entranceSlide,
                child: IndexedStack(
                  index: _index,
                  children: [
                    HomeScreen(
                      savedIds: _savedIds,
                      onToggleSaved: _toggleSaved,
                      onPlayMovie: _openPlayer,
                      onOpenProfile: _openProfile,
                    ),
                    ExploreScreen(
                      savedIds: _savedIds,
                      onToggleSaved: _toggleSaved,
                      onPlayMovie: _openPlayer,
                    ),
                    MyListScreen(
                      savedIds: _savedIds,
                      onToggleSaved: _toggleSaved,
                      onPlayMovie: _openPlayer,
                      onExplore: () => _selectTab(1),
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: CineflixBottomBar(
              index: _index,
              onSelected: _selectTab,
              savedCount: _savedIds.length,
            ),
          ),
          if (_showIntro)
            Positioned.fill(
              child: CineflixIntro(onFinished: _onIntroFinished),
            ),
        ],
      ),
    );
  }
}

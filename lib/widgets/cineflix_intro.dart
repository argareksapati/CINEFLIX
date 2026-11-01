import 'package:flutter/material.dart';

/// Animasi pembuka bergaya aplikasi streaming (RBTV-like):
///
/// 1. layar gelap dengan glow merah yang tumbuh,
/// 2. garis merah merekah dari tengah,
/// 3. logo CINEFLIX muncul dengan skala *pop* + kilau cahaya menyapu,
/// 4. tagline naik dan memudar masuk,
/// 5. seluruh lapisan memudar & sedikit membesar, membuka halaman beranda.
///
/// Animasi hanya diputar sekali saat beranda pertama kali dibangun dan
/// otomatis dilewati bila pengguna mengaktifkan "remove animations" di
/// sistem (aksesibilitas).
class CineflixIntro extends StatefulWidget {
  const CineflixIntro({
    super.key,
    required this.onFinished,
    this.duration = const Duration(milliseconds: 2100),
  });

  /// Dipanggil sekali setelah animasi selesai (atau langsung dilewati).
  final VoidCallback onFinished;

  final Duration duration;

  @override
  State<CineflixIntro> createState() => _CineflixIntroState();
}

class _CineflixIntroState extends State<CineflixIntro>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  bool _finished = false;
  bool _checkedAccessibility = false;

  static const _red = Color(0xFFE50914);

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) _finish();
    });
    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_checkedAccessibility) return;
    _checkedAccessibility = true;
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _controller.stop();
      WidgetsBinding.instance.addPostFrameCallback((_) => _finish());
    }
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    widget.onFinished();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Potongan kurva pada rentang [start, end] dari nilai 0..1.
  double _seg(double t, double start, double end,
      [Curve curve = Curves.linear]) {
    if (end <= start) return t >= end ? 1 : 0;
    final v = ((t - start) / (end - start)).clamp(0.0, 1.0);
    return curve.transform(v);
  }

  Widget _wordmark() {
    return RichText(
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'CINE',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 46,
              letterSpacing: -1.8,
              height: 1,
            ),
          ),
          TextSpan(
            text: 'FLIX',
            style: TextStyle(
              color: _red,
              fontWeight: FontWeight.w900,
              fontSize: 46,
              letterSpacing: -1.8,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Material dipakai agar DefaultTextStyle normal (bukan style fallback
    // bertanda garis bawah) karena lapisan ini berada di atas Scaffold.
    return Material(
      type: MaterialType.transparency,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;

          final outro = _seg(t, 0.82, 1.0, Curves.easeInCubic);
          if (outro >= 1) return const SizedBox.shrink();

          final lineWidth = _seg(t, 0.02, 0.20, Curves.easeOutCubic) * 132;
          final logoIn = _seg(t, 0.12, 0.44, Curves.easeOutBack);
          final logoFade = _seg(t, 0.12, 0.32, Curves.easeOut);
          final glow = _seg(t, 0.08, 0.72, Curves.easeOut);
          final sweep = _seg(t, 0.44, 0.70, Curves.easeInOutCubic);

          return Opacity(
            opacity: 1 - outro,
            child: Transform.scale(
              scale: 1 + 0.06 * outro,
              child: ColoredBox(
                color: const Color(0xFF07070A),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Glow merah lembut di belakang logo.
                    Center(
                      child: Opacity(
                        opacity: 0.10 + 0.90 * glow,
                        child: Container(
                          width: 430,
                          height: 430,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [Color(0x38E50914), Color(0x00E50914)],
                              stops: [0.0, 0.72],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo + kilau yang menyapu dari kiri ke kanan.
                          SizedBox(
                            width: 260,
                            height: 78,
                            child: ClipRect(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Opacity(
                                    opacity: logoFade.clamp(0.0, 1.0),
                                    child: Transform.scale(
                                      scale: 0.72 + 0.28 * logoIn,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: _wordmark(),
                                      ),
                                    ),
                                  ),
                                  if (sweep > 0 && sweep < 1)
                                    Positioned(
                                      top: -30,
                                      bottom: -30,
                                      left: -70 + 300 * sweep,
                                      child: Transform.rotate(
                                        angle: 0.34,
                                        child: Container(
                                          width: 38,
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0x00FFFFFF),
                                                Color(0x40FFFFFF),
                                                Color(0x00FFFFFF),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Garis merah yang merekah.
                          Container(
                            width: lineWidth,
                            height: 3,
                            decoration: BoxDecoration(
                              color: _red,
                              borderRadius: BorderRadius.circular(3),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x66E50914),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

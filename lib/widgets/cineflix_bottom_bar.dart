import 'package:flutter/material.dart';

/// Bottom navigation yang benar-benar berfungsi.
///
/// [index] menentukan item yang aktif, sehingga tampilan bar selalu sinkron
/// dengan halaman yang sedang ditampilkan oleh [AppShell].
class CineflixBottomBar extends StatelessWidget {
  const CineflixBottomBar({
    super.key,
    required this.index,
    required this.onSelected,
    this.savedCount = 0,
  });

  final int index;
  final ValueChanged<int> onSelected;

  /// Jumlah film di My List, ditampilkan sebagai badge kecil.
  final int savedCount;

  static const _items = <_NavItem>[
    _NavItem(
        id: 'nav-home',
        icon: Icons.home_filled,
        outlineIcon: Icons.home_outlined,
        label: 'Home'),
    _NavItem(
        id: 'nav-explore',
        icon: Icons.explore,
        outlineIcon: Icons.explore_outlined,
        label: 'Explore'),
    _NavItem(
        id: 'nav-my-list',
        icon: Icons.bookmark,
        outlineIcon: Icons.bookmark_border,
        label: 'My List'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111116),
        border: Border(top: BorderSide(color: Color(0xFF272730))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: _BottomItem(
                    key: ValueKey(_items[i].id),
                    item: _items[i],
                    active: i == index,
                    badge: i == 2 ? savedCount : 0,
                    onTap: () => onSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.id,
    required this.icon,
    required this.outlineIcon,
    required this.label,
  });

  final String id;
  final IconData icon;
  final IconData outlineIcon;
  final String label;
}

class _BottomItem extends StatelessWidget {
  const _BottomItem({
    super.key,
    required this.item,
    required this.active,
    required this.onTap,
    this.badge = 0,
  });

  final _NavItem item;
  final bool active;
  final VoidCallback onTap;
  final int badge;

  static const _activeColor = Color(0xFFE50914);
  static const _idleColor = Color(0xFF84848F);

  @override
  Widget build(BuildContext context) {
    final color = active ? _activeColor : _idleColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      splashColor: const Color(0x22E50914),
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: active ? 1 : 0),
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) => Transform.scale(
                scale: 1 + 0.12 * value,
                child: child,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    active ? item.icon : item.outlineIcon,
                    color: color,
                    size: 22,
                  ),
                  if (badge > 0)
                    Positioned(
                      right: -8,
                      top: -5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        constraints: const BoxConstraints(minWidth: 14),
                        decoration: BoxDecoration(
                          color: _activeColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFF111116), width: 1.5),
                        ),
                        child: Text(
                          '$badge',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: active ? FontWeight.w800 : FontWeight.w500,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

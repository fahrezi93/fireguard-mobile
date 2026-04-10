import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/theme.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  static const _items = <_NavItem>[
    _NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Beranda', path: '/dashboard'),
    _NavItem(icon: Icons.add_circle_outline, activeIcon: Icons.add_circle, label: 'Lapor', path: '/report/new'),
    _NavItem(icon: Icons.notifications_outlined, activeIcon: Icons.notifications, label: 'Notifikasi', path: '/notifications'),
    _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profil', path: '/profile'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _items.length; i++) {
      if (location.startsWith(_items[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04), // Lighter, modern shadow
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_items.length, (i) {
                final item = _items[i];
                final isActive = i == index;

                return Expanded(
                  child: InkWell(
                    onTap: () => context.go(item.path),
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isActive ? item.activeIcon : item.icon,
                            color: isActive
                                ? FGColors.primary
                                : FGColors.textTertiary,
                            size: 26, // Slightly larger icon
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight:
                                  isActive ? FontWeight.w600 : FontWeight.w500, // Make inactive a bit bolder than usual
                              color: isActive
                                  ? FGColors.primary
                                  : FGColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String path;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.path,
  });
}

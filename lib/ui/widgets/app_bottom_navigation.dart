import 'package:flutter/material.dart';

import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';

class AppBottomNavigation extends StatelessWidget {
  static const double _bottomMargin = UiTokens.spacingMd;
  static const double _shadowOverlap = 20;
  static const double _contentClearance = UiTokens.spacingXl;

  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static double reservedScrollPadding(BuildContext context) {
    // The shell keeps the body above the navigation bar, so scrollables only
    // need a final comfortable clearance instead of compensating for the full
    // bar height inside their own content.
    return _shadowOverlap + _contentClearance;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(
        UiTokens.spacingMd,
        0,
        UiTokens.spacingMd,
        _bottomMargin,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: UiTokens.surface,
          borderRadius: BorderRadius.circular(UiTokens.radiusXl),
          boxShadow: const [
            BoxShadow(
              color: UiTokens.shadow,
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          backgroundColor: Colors.transparent,
          selectedItemColor: UiTokens.primaryStrong,
          unselectedItemColor: colorScheme.onSurfaceVariant,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.toys_outlined),
              activeIcon: Icon(Icons.toys_rounded),
              label: 'Brinquedos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2_rounded),
              label: 'Caixas',
            ),
          ],
        ),
      ),
    );
  }
}

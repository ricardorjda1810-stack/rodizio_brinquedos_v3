import 'package:flutter/material.dart';

import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';

class AppBottomNavigation extends StatelessWidget {
  static const double _bottomMargin = UiTokens.spacingMd;
  static const double _barHeight = kBottomNavigationBarHeight;
  static const double _contentClearance = UiTokens.spacingXl;

  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static double reservedScrollPadding(BuildContext context) {
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;
    if (isTablet) {
      return safeBottom + _contentClearance;
    }

    final bottomInset = safeBottom > _bottomMargin ? safeBottom : _bottomMargin;
    return _barHeight + bottomInset + _contentClearance;
  }

  @override
  Widget build(BuildContext context) {
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
          selectedItemColor: const Color(0xFFF97316),
          unselectedItemColor: const Color(0xFFA8896A),
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

class AppTopNavigation extends StatelessWidget {
  final int currentIndex;
  final VoidCallback onHomeTap;
  final VoidCallback onRoundTap;
  final VoidCallback onWeeklyPlanningTap;
  final VoidCallback onToysTap;
  final VoidCallback onBoxesTap;
  final VoidCallback onSettingsTap;

  const AppTopNavigation({
    super.key,
    required this.currentIndex,
    required this.onHomeTap,
    required this.onRoundTap,
    required this.onWeeklyPlanningTap,
    required this.onToysTap,
    required this.onBoxesTap,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = <_AppTopNavigationItemData>[
      _AppTopNavigationItemData(
        label: 'In\u00edcio',
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        selected: currentIndex == 0,
        onTap: onHomeTap,
      ),
      _AppTopNavigationItemData(
        label: 'Rodada',
        icon: Icons.play_circle_outline_rounded,
        activeIcon: Icons.play_circle_fill_rounded,
        selected: currentIndex == 3,
        onTap: onRoundTap,
      ),
      _AppTopNavigationItemData(
        label: 'Planejamento',
        icon: Icons.calendar_month_outlined,
        activeIcon: Icons.calendar_month_rounded,
        selected: false,
        onTap: onWeeklyPlanningTap,
      ),
      _AppTopNavigationItemData(
        label: 'Brinquedos',
        icon: Icons.toys_outlined,
        activeIcon: Icons.toys_rounded,
        selected: currentIndex == 1,
        onTap: onToysTap,
      ),
      _AppTopNavigationItemData(
        label: 'Caixas',
        icon: Icons.inventory_2_outlined,
        activeIcon: Icons.inventory_2_rounded,
        selected: currentIndex == 2,
        onTap: onBoxesTap,
      ),
      _AppTopNavigationItemData(
        label: 'Config.',
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings_rounded,
        selected: false,
        onTap: onSettingsTap,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: UiTokens.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFF3E2D0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1AF97316),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0) const SizedBox(width: 4),
                    _AppTopNavigationItem(data: items[i]),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AppTopNavigationItemData {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool selected;
  final VoidCallback onTap;

  const _AppTopNavigationItemData({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.selected,
    required this.onTap,
  });
}

class _AppTopNavigationItem extends StatelessWidget {
  final _AppTopNavigationItemData data;

  const _AppTopNavigationItem({required this.data});

  @override
  Widget build(BuildContext context) {
    final selected = data.selected;
    final foreground = selected ? Colors.white : const Color(0xFF6B4F30);
    final background = selected ? const Color(0xFFF97316) : Colors.transparent;

    return Tooltip(
      message: data.label,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: data.onTap,
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            constraints: const BoxConstraints(minHeight: 46, minWidth: 92),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              boxShadow: selected
                  ? const [
                      BoxShadow(
                        color: Color(0x40F97316),
                        blurRadius: 14,
                        offset: Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  selected ? data.activeIcon : data.icon,
                  size: 20,
                  color: foreground,
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    data.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: UiTokens.textCaption.copyWith(
                      color: foreground,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

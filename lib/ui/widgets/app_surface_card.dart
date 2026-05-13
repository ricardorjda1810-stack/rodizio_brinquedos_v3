import 'package:flutter/material.dart';

import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';

class AppSurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double radius;

  const AppSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(UiTokens.spacingMd),
    this.color,
    this.radius = UiTokens.radiusCard,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: color ?? scheme.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: isDark ? 0.70 : 0.85),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? UiTokens.shadowDark : UiTokens.shadow,
            blurRadius: isDark ? 12 : 18,
            offset: Offset(0, isDark ? 4 : 8),
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

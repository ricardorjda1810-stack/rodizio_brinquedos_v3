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
    return Container(
      decoration: BoxDecoration(
        color: color ?? UiTokens.surface,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
            color: UiTokens.shadow,
            blurRadius: 18,
            offset: Offset(0, 6),
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

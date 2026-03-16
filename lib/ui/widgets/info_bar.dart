import 'package:flutter/material.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';

class InfoBar extends StatelessWidget {
  final String message;

  const InfoBar({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = 12.0;
    const verticalPadding = 10.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: UiTokens.surface,
        borderRadius: BorderRadius.circular(UiTokens.radiusCard),
        border: Border.all(color: UiTokens.border),
      ),
      child: Text(
        message,
        style: UiTokens.textCaption.copyWith(
          color: UiTokens.textSecondary,
        ),
      ),
    );
  }
}

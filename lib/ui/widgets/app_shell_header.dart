import 'package:flutter/material.dart';

import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';

class AppShellHeaderAction {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const AppShellHeaderAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });
}

class AppShellHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  final List<AppShellHeaderAction> actions;
  final Widget? bottom;

  const AppShellHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    this.actions = const <AppShellHeaderAction>[],
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        UiTokens.spacingMd,
        UiTokens.spacingMd,
        UiTokens.spacingMd,
        UiTokens.spacingMd,
      ),
      padding: const EdgeInsets.all(UiTokens.spacingLg),
      decoration: BoxDecoration(
        color: UiTokens.primarySoft,
        borderRadius: BorderRadius.circular(UiTokens.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eyebrow,
                      style: UiTokens.textMicro.copyWith(
                        color: UiTokens.primaryStrong,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: UiTokens.spacingSm),
                    Text(
                      title,
                      style: UiTokens.textTitle.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: UiTokens.spacingXs),
                    Text(
                      subtitle,
                      style: UiTokens.textBody.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (actions.isNotEmpty) ...[
                const SizedBox(width: UiTokens.spacingSm),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: actions
                      .map(
                        (action) => Padding(
                          padding: const EdgeInsets.only(left: UiTokens.spacingXs),
                          child: Tooltip(
                            message: action.tooltip,
                            child: IconButton.filledTonal(
                              onPressed: action.onTap,
                              icon: Icon(action.icon, size: 20),
                            ),
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
              ],
            ],
          ),
          if (bottom != null) ...[
            const SizedBox(height: UiTokens.spacingMd),
            bottom!,
          ],
        ],
      ),
    );
  }
}

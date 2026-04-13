import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';

class ToyRowItem extends StatelessWidget {
  final String name;
  final String? imagePath;
  final VoidCallback? onTap;
  final bool showDivider;

  const ToyRowItem({
    super.key,
    required this.name,
    this.imagePath,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    const itemHeight = 64.0;
    const horizontalPadding = 8.0;
    const thumbnailSize = 44.0;
    const gap = 12.0;
    const iconSize = 20.0;
    final trimmedPath = (imagePath ?? '').trim();

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(UiTokens.radiusMd),
            child: SizedBox(
              height: itemHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Row(
                  children: [
                    _ToyThumbnail(
                      imagePath: trimmedPath,
                      thumbnailSize: thumbnailSize,
                      iconSize: iconSize,
                    ),
                    const SizedBox(width: gap),
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: UiTokens.textBody.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: UiTokens.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: UiTokens.spacingSm),
                    const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: UiTokens.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (showDivider)
          Container(
            height: 1,
            margin: const EdgeInsets.only(left: 64),
            color: UiTokens.border.withValues(alpha: 0.7),
          ),
      ],
    );
  }
}

class _ToyThumbnail extends StatelessWidget {
  final String imagePath;
  final double thumbnailSize;
  final double iconSize;

  const _ToyThumbnail({
    required this.imagePath,
    required this.thumbnailSize,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath.isEmpty) {
      return Container(
        width: thumbnailSize,
        height: thumbnailSize,
        decoration: BoxDecoration(
          color: UiTokens.primarySoft,
          borderRadius: BorderRadius.circular(UiTokens.radiusPhoto),
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.image_outlined,
          size: iconSize,
          color: UiTokens.textSecondary,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(UiTokens.radiusPhoto),
      child: Image.file(
        File(imagePath),
        width: thumbnailSize,
        height: thumbnailSize,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) {
          return Container(
            width: thumbnailSize,
            height: thumbnailSize,
            decoration: BoxDecoration(
              color: UiTokens.primarySoft,
              borderRadius: BorderRadius.circular(UiTokens.radiusPhoto),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.broken_image_outlined,
              size: iconSize,
              color: UiTokens.textSecondary,
            ),
          );
        },
      ),
    );
  }
}

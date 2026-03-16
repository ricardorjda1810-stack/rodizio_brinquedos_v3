import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';

class ToyCard extends StatelessWidget {
  final String name;
  final String? imagePath;
  final VoidCallback? onTap;

  const ToyCard({
    super.key,
    required this.name,
    this.imagePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = 12.0;
    const verticalPadding = 10.0;
    const thumbnailSize = 44.0;
    const minHeight = 64.0;
    const gap = 12.0;
    const iconSize = 20.0;
    final trimmedPath = (imagePath ?? '').trim();

    return Material(
      color: UiTokens.surface,
      borderRadius: BorderRadius.circular(UiTokens.radiusCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UiTokens.radiusCard),
        child: Container(
          constraints: const BoxConstraints(minHeight: minHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(UiTokens.radiusCard),
            border: Border.all(color: UiTokens.border),
          ),
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
                    color: UiTokens.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
          color: UiTokens.bg,
          borderRadius: BorderRadius.circular(UiTokens.radiusPhoto),
          border: Border.all(color: UiTokens.border),
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
              color: UiTokens.bg,
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

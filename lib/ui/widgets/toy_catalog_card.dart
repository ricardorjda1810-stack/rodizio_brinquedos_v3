import 'dart:io';

import 'package:flutter/material.dart';

class ToyCatalogCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final String? photoPath;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onExpandPhoto;

  const ToyCatalogCard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.photoPath,
    required this.onTap,
    this.onLongPress,
    this.onExpandPhoto,
  });

  Widget _photo(BuildContext context) {
    final path = (photoPath ?? '').trim();
    if (path.isEmpty) return _placeholder(context);

    return Image.file(
      File(path),
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => _placeholder(context),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withValues(alpha: 0.25),
      child: const Center(
        child: Icon(Icons.image_outlined, size: 42),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName = name.trim().isEmpty ? 'Sem nome' : name.trim();
    final displaySubtitle =
        subtitle.trim().isEmpty ? 'Sem caixa' : subtitle.trim();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _photo(context),
                  if (onExpandPhoto != null)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: IconButton.filledTonal(
                        tooltip: 'Ampliar foto',
                        onPressed: onExpandPhoto,
                        icon: const Icon(Icons.open_in_full_outlined),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 2),
              child: Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Text(
                displaySubtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

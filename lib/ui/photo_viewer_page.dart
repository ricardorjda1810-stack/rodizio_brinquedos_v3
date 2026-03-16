import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';

class PhotoViewerPage extends StatelessWidget {
  final String photoPath;
  final String title;
  final String boxLabel;
  final String categoryLabel;
  final String locationFieldLabel;
  final String locationLabel;

  const PhotoViewerPage({
    super.key,
    required this.photoPath,
    this.title = 'Foto',
    this.boxLabel = 'Sem caixa',
    this.categoryLabel = 'Sem categoria',
    this.locationFieldLabel = 'Local',
    this.locationLabel = 'Sem local',
  });

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: UiTokens.textCaption.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: UiTokens.spacingSm),
        Expanded(
          child: Text(
            value,
            style: UiTokens.textBody.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final path = photoPath.trim();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(title),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 5.0,
                  child: Image.file(
                    File(path),
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                    errorBuilder: (_, __, ___) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Não foi possível carregar a foto.',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(UiTokens.spacingMd),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow('Caixa', boxLabel),
                  const SizedBox(height: UiTokens.spacingSm),
                  _infoRow('Categoria', categoryLabel),
                  const SizedBox(height: UiTokens.spacingSm),
                  _infoRow(locationFieldLabel, locationLabel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';

class PhotoViewerPage extends StatelessWidget {
  final String photoPath;
  final String title;

  const PhotoViewerPage({
    super.key,
    required this.photoPath,
    this.title = 'Foto',
  });

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
                    style: TextStyle(
                        color: Colors.white), // ✅ branco no fundo preto
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:rodizio_brinquedos_v3/data/services/photo_cropper_service.dart';

class PhotoCropPage extends StatefulWidget {
  final String sourcePath;

  const PhotoCropPage({super.key, required this.sourcePath});

  static Future<String?> open(
    BuildContext context, {
    required String sourcePath,
  }) {
    return Navigator.of(context).push<String?>(
      MaterialPageRoute(builder: (_) => PhotoCropPage(sourcePath: sourcePath)),
    );
  }

  @override
  State<PhotoCropPage> createState() => _PhotoCropPageState();
}

class _PhotoCropPageState extends State<PhotoCropPage> {
  bool _saving = false;

  Future<void> _crop() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      final croppedPath = await PhotoCropperService.cropToSquare(
        sourcePath: widget.sourcePath,
      ).timeout(const Duration(seconds: 15));
      if (!mounted) return;

      if (croppedPath == null) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nao foi possivel usar a foto. Tente novamente.'),
          ),
        );
        return;
      }

      Navigator.of(context).pop(croppedPath);
    } catch (e, st) {
      debugPrint('crop failed: $e');
      debugPrintStack(stackTrace: st);
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao processar a foto.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustar foto'),
        leading: IconButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(null),
          icon: const Icon(Icons.close),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.crop_square, size: 40),
              const SizedBox(height: 16),
              const Text(
                'Toque em "Usar foto" para abrir o ajuste e concluir o recorte.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _crop,
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Usar foto'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed:
                    _saving ? null : () => Navigator.of(context).pop(null),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

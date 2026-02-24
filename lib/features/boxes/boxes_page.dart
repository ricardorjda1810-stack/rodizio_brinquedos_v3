// lib/features/boxes/boxes_page.dart
import 'package:flutter/material.dart';
import 'package:rodizio_brinquedos_v3/ui/box_create_page.dart';

import '../../data/db/app_database.dart';
import '../../data/repositories/toy_repository.dart';
import 'boxes_controller.dart';
import 'boxes_state.dart';

class BoxesPage extends StatefulWidget {
  final ToyRepository toyRepository;

  const BoxesPage({
    super.key,
    required this.toyRepository,
  });

  @override
  State<BoxesPage> createState() => _BoxesPageState();
}

class _BoxesPageState extends State<BoxesPage> {
  late final BoxesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = BoxesController(toyRepository: widget.toyRepository);
    _controller.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showAddBoxDialog(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BoxCreatePage(toyRepository: widget.toyRepository),
      ),
    );
  }

  Future<void> _confirmDeleteBox(BuildContext context, Boxe box) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Apagar caixa/local?'),
          content: Text(
            'Isso remove a caixa "Caixa ${box.number}" e desassocia dos brinquedos.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Apagar'),
            ),
          ],
        );
      },
    );

    if (ok == true) {
      await _controller.deleteBox(boxId: box.id);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Caixa apagada.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caixas/Locais'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBoxDialog(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<BoxesState>(
        stream: _controller.stream,
        initialData: BoxesState.empty,
        builder: (context, snap) {
          final state = snap.data ?? BoxesState.empty;
          final boxes = state.boxes;

          return Padding(
            padding: const EdgeInsets.all(12),
            child: (boxes.isEmpty)
                ? const Center(
                    child: Text('Nenhuma caixa ainda. Toque em + para adicionar.'),
                  )
                : ListView.separated(
                    itemCount: boxes.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final box = boxes[index];
                      final local = box.local.trim();
                      return ListTile(
                        title: Text('Caixa ${box.number}'),
                        subtitle: Text(local.isEmpty ? 'Local: —' : 'Local: $local'),
                        onLongPress: () => _confirmDeleteBox(context, box),
                        trailing: IconButton(
                          tooltip: 'Apagar',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _confirmDeleteBox(context, box),
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
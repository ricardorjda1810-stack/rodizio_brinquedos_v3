// lib/ui/toys/toys_page.dart
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/features/toys/toys_controller.dart';
import 'package:rodizio_brinquedos_v3/features/toys/toys_state.dart';
import 'package:rodizio_brinquedos_v3/ui/toy_detail_page.dart';

class ToysPage extends StatefulWidget {
  final ToyRepository toyRepository;

  const ToysPage({
    super.key,
    required this.toyRepository,
  });

  @override
  State<ToysPage> createState() => _ToysPageState();
}

class _ToysPageState extends State<ToysPage> {
  late final ToysController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ToysController(toyRepository: widget.toyRepository);
    _controller.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showAddToyDialog(BuildContext context, ToysState state) async {
    final nameController = TextEditingController();
    String? selectedBoxId;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Adicionar brinquedo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  hintText: 'Ex.: Carrinho, Boneca...',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                // value deprecated → initialValue
                initialValue: selectedBoxId,
                decoration: const InputDecoration(
                  labelText: 'Caixa (opcional)',
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Sem caixa'),
                  ),
                  ...state.boxes.map((b) {
                    return DropdownMenuItem<String?>(
                      value: b.id,
                      child: Text(b.name),
                    );
                  }),
                ],
                onChanged: (v) {
                  selectedBoxId = v;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    if (result != true) return;

    final name = nameController.text.trim();
    if (name.isEmpty) return;

    await _controller.addToy(name: name, boxId: selectedBoxId);
  }

  String _formatDateTime(int millis) {
    final dt = DateTime.fromMillisecondsSinceEpoch(millis).toLocal();
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final yyyy = dt.year.toString();
    final hh = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$dd/$mm/$yyyy $hh:$min';
  }

  Widget _buildLeadingPhoto(String? photoPath) {
    final path = (photoPath ?? '').trim();
    if (path.isEmpty) {
      return const CircleAvatar(child: Icon(Icons.toys));
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.file(
        File(path),
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return const CircleAvatar(child: Icon(Icons.toys));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brinquedos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: StreamBuilder<ToysState>(
          stream: _controller.stream,
          initialData: ToysState.empty,
          builder: (context, snap) {
            final state = snap.data ?? ToysState.empty;
            final toys = state.toys;

            if (snap.connectionState == ConnectionState.waiting && toys.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (toys.isEmpty) {
              return Center(
                child: TextButton.icon(
                  onPressed: () => _showAddToyDialog(context, state),
                  icon: const Icon(Icons.add),
                  label: const Text('Nenhum brinquedo. Toque para adicionar.'),
                ),
              );
            }

            return Card(
              child: ListView.separated(
                itemCount: toys.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = toys[index];
                  final toy = item.toy;
                  final boxName = item.box?.name;

                  return ListTile(
                    leading: _buildLeadingPhoto(toy.photoPath),
                    title: Text(toy.name),
                    subtitle: Text(
                      [
                        if (boxName != null && boxName.isNotEmpty) 'Caixa: $boxName',
                        'Criado em: ${_formatDateTime(toy.createdAt)}',
                      ].join(' • '),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ToyDetailPage(
                            toyRepository: widget.toyRepository,
                            toyId: toy.id,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: StreamBuilder<ToysState>(
        stream: _controller.stream,
        initialData: ToysState.empty,
        builder: (context, snap) {
          final state = snap.data ?? ToysState.empty;
          return FloatingActionButton.extended(
            onPressed: () => _showAddToyDialog(context, state),
            icon: const Icon(Icons.add),
            label: const Text('Adicionar'),
          );
        },
      ),
    );
  }
}

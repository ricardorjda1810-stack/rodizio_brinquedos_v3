import 'package:flutter/material.dart';
import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/ui/services/app_feedback.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';

class LocationsManagePage extends StatelessWidget {
  final ToyRepository toyRepository;
  final SettingsRepository? settingsRepository;

  const LocationsManagePage({
    super.key,
    required this.toyRepository,
    this.settingsRepository,
  });

  Future<void> _showAddDialog(BuildContext context) async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Novo local'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nome'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await toyRepository.addLocationDefinition(name: controller.text);
    }
  }

  Future<void> _showRenameDialog(
    BuildContext context,
    LocationDefinition location,
  ) async {
    final controller = TextEditingController(text: location.name);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar local'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nome'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await toyRepository.renameLocation(
        locationId: location.id,
        newName: controller.text,
      );
    }
  }

  Future<void> _remove(BuildContext context, LocationDefinition location) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover local?'),
        content: Text(location.name),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (ok == true) {
      final settings = settingsRepository;
      if (settings != null) {
        await AppFeedback(settings).onDeleteConfirmed();
      }
      await toyRepository.removeLocation(locationId: location.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciar locais')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(UiTokens.m),
        child: StreamBuilder<List<LocationDefinition>>(
          stream: toyRepository.watchLocations(),
          builder: (context, snapshot) {
            final locations = snapshot.data ?? const <LocationDefinition>[];
            if (snapshot.connectionState == ConnectionState.waiting && locations.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (locations.isEmpty) {
              return const Center(child: Text('Nenhum local.'));
            }

            return ListView.separated(
              itemCount: locations.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, index) {
                final l = locations[index];
                return ListTile(
                  title: Text(l.name),
                  subtitle: Text(l.id),
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      IconButton(
                        tooltip: 'Editar',
                        onPressed: () => _showRenameDialog(context, l),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Remover',
                        onPressed: () => _remove(context, l),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

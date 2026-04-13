import 'package:flutter/material.dart';
import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/ui/services/app_feedback.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_surface_card.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/empty_state.dart';

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
            style: FilledButton.styleFrom(
              backgroundColor: UiTokens.danger,
              foregroundColor: UiTokens.surface,
            ),
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
      backgroundColor: UiTokens.bg,
      appBar: AppBar(title: const Text('Gerenciar locais')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Novo local'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(UiTokens.m),
        child: StreamBuilder<List<LocationDefinition>>(
          stream: toyRepository.watchLocations(),
          builder: (context, snapshot) {
            final locations = snapshot.data ?? const <LocationDefinition>[];
            if (snapshot.connectionState == ConnectionState.waiting &&
                locations.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (locations.isEmpty) {
              return EmptyState(
                icon: Icons.place_outlined,
                title: 'Nenhum local cadastrado',
                message:
                    'Crie locais para deixar a organiza\u00e7\u00e3o da casa mais clara no cadastro das caixas e brinquedos.',
                actionLabel: 'Novo local',
                onAction: () => _showAddDialog(context),
              );
            }

            return ListView(
              padding: const EdgeInsets.only(bottom: 104),
              children: [
                AppSurfaceCard(
                  padding: const EdgeInsets.all(UiTokens.spacingLg),
                  color: UiTokens.primarySoft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Locais da casa',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: UiTokens.spacingXs),
                      Text(
                        'Use nomes simples e f\u00e1ceis de reconhecer para manter caixas e brinquedos sempre bem localizados.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: UiTokens.spacingMd),
                ...locations.map((location) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: UiTokens.spacingSm),
                    child: AppSurfaceCard(
                      padding: const EdgeInsets.all(UiTokens.spacingMd),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: UiTokens.primarySoft,
                              borderRadius:
                                  BorderRadius.circular(UiTokens.radiusLg),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.place_outlined,
                              color: UiTokens.primaryStrong,
                            ),
                          ),
                          const SizedBox(width: UiTokens.spacingMd),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  location.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall,
                                ),
                                const SizedBox(height: UiTokens.spacingXs),
                                Text(
                                  'Sugest\u00e3o usada em caixas e brinquedos sem caixa.',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            tooltip: 'A\u00e7\u00f5es do local',
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showRenameDialog(context, location);
                                return;
                              }
                              if (value == 'delete') {
                                _remove(context, location);
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem<String>(
                                value: 'edit',
                                child: Text('Editar'),
                              ),
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: Text('Remover'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}

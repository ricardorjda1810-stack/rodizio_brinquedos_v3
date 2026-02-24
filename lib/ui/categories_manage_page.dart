import 'package:flutter/material.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/ui/services/app_feedback.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';

class CategoriesManagePage extends StatelessWidget {
  final ToyRepository toyRepository;
  final SettingsRepository? settingsRepository;

  const CategoriesManagePage({
    super.key,
    required this.toyRepository,
    this.settingsRepository,
  });

  Future<void> _showAddDialog(BuildContext context) async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nova categoria'),
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
      await toyRepository.addCategory(name: controller.text);
    }
  }

  Future<void> _showRenameDialog(
    BuildContext context,
    CategoryDefinition category,
  ) async {
    final controller = TextEditingController(text: category.name);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar categoria'),
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
      await toyRepository.renameCategory(
        categoryId: category.id,
        newName: controller.text,
      );
    }
  }

  Future<void> _remove(BuildContext context, CategoryDefinition category) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover categoria?'),
        content: const Text(
          'Se a categoria estiver em uso, ela será marcada como inativa.',
        ),
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
      await toyRepository.removeCategory(categoryId: category.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar categorias'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(UiTokens.m),
        child: StreamBuilder<List<CategoryDefinition>>(
          stream: toyRepository.watchCategories(activeOnly: false),
          builder: (context, snapshot) {
            final categories = snapshot.data ?? const <CategoryDefinition>[];
            if (snapshot.connectionState == ConnectionState.waiting && categories.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (categories.isEmpty) {
              return const Center(child: Text('Nenhuma categoria.'));
            }

            return ListView.separated(
              itemCount: categories.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, index) {
                final c = categories[index];
                return ListTile(
                  title: Text(c.name),
                  subtitle: Text(c.id + (c.isActive ? '' : ' · inativa')),
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      if (!c.isActive)
                        IconButton(
                          tooltip: 'Reativar',
                          onPressed: () => toyRepository.reactivateCategory(categoryId: c.id),
                          icon: const Icon(Icons.visibility_outlined),
                        ),
                      IconButton(
                        tooltip: 'Editar',
                        onPressed: () => _showRenameDialog(context, c),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Remover',
                        onPressed: () => _remove(context, c),
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

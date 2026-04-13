import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/ui/services/app_feedback.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_surface_card.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/empty_state.dart';

class CategoriesManagePage extends StatelessWidget {
  final ToyRepository toyRepository;
  final SettingsRepository? settingsRepository;

  const CategoriesManagePage({
    super.key,
    required this.toyRepository,
    this.settingsRepository,
  });

  String _decodeDisplayText(String input) {
    if (!(input.contains('\u00c3') || input.contains('\u00c2'))) return input;
    try {
      return utf8.decode(latin1.encode(input));
    } catch (_) {
      return input;
    }
  }

  Future<void> _showCategoryDialog(
    BuildContext context, {
    CategoryDefinition? category,
  }) async {
    final nameController = TextEditingController(text: category?.name ?? '');
    final examplesController = TextEditingController(
      text: category?.examples ?? '',
    );

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(category == null ? 'Nova categoria' : 'Editar categoria'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: UiTokens.m),
            TextField(
              controller: examplesController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Exemplos',
                hintText: 'Ex.: carrinho, caminh\u00e3o, trenzinho',
              ),
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
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    if (category == null) {
      await toyRepository.addCategory(
        name: nameController.text,
        examples: examplesController.text,
      );
      return;
    }

    await toyRepository.renameCategory(
      categoryId: category.id,
      newName: nameController.text,
      examples: examplesController.text,
    );
  }

  Future<void> _remove(BuildContext context, CategoryDefinition category) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover categoria?'),
        content: const Text(
          'Se a categoria estiver em uso, ela ser\u00e1 marcada como inativa.',
        ),
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
      await toyRepository.removeCategory(categoryId: category.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UiTokens.bg,
      appBar: AppBar(
        title: const Text('Gerenciar categorias'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Nova categoria'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(UiTokens.m),
        child: StreamBuilder<List<CategoryDefinition>>(
          stream: toyRepository.watchCategories(activeOnly: false),
          builder: (context, snapshot) {
            final categories = snapshot.data ?? const <CategoryDefinition>[];
            if (snapshot.connectionState == ConnectionState.waiting &&
                categories.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (categories.isEmpty) {
              return EmptyState(
                icon: Icons.category_outlined,
                title: 'Nenhuma categoria',
                message:
                    'Crie categorias para organizar o cat\u00e1logo com mais clareza.',
                actionLabel: 'Nova categoria',
                onAction: () => _showCategoryDialog(context),
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
                        'Categorias do cat\u00e1logo',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: UiTokens.spacingXs),
                      Text(
                        'Mantenha nomes e exemplos claros para facilitar a escolha na hora de cadastrar.',
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
                ...categories.map((c) {
                  final examples =
                      _decodeDisplayText((c.examples ?? '').trim());
                  final statusSuffix = c.isActive ? 'Ativa' : 'Inativa';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: UiTokens.spacingSm),
                    child: AppSurfaceCard(
                      padding: const EdgeInsets.all(UiTokens.spacingMd),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _decodeDisplayText(c.name),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                    const SizedBox(height: UiTokens.spacingXs),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: UiTokens.spacingSm,
                                        vertical: UiTokens.spacingXs,
                                      ),
                                      decoration: BoxDecoration(
                                        color: c.isActive
                                            ? UiTokens.primarySoft
                                            : Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(
                                          UiTokens.radiusLg,
                                        ),
                                      ),
                                      child: Text(
                                        statusSuffix,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: c.isActive
                                                  ? UiTokens.primaryStrong
                                                  : UiTokens.textSecondary,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                tooltip: 'A\u00e7\u00f5es da categoria',
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showCategoryDialog(
                                      context,
                                      category: c,
                                    );
                                    return;
                                  }
                                  if (value == 'reactivate') {
                                    toyRepository.reactivateCategory(
                                      categoryId: c.id,
                                    );
                                    return;
                                  }
                                  if (value == 'delete') {
                                    _remove(context, c);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem<String>(
                                    value: 'edit',
                                    child: Text('Editar'),
                                  ),
                                  if (!c.isActive)
                                    const PopupMenuItem<String>(
                                      value: 'reactivate',
                                      child: Text('Reativar'),
                                    ),
                                  const PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Text('Remover'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: UiTokens.spacingMd),
                          Text(
                            'Exemplos',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: UiTokens.spacingXs),
                          Text(
                            examples.isEmpty
                                ? 'Ainda sem exemplos cadastrados.'
                                : examples,
                            style: Theme.of(context).textTheme.bodyMedium,
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



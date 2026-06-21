import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/services/purchase_service.dart';
import 'package:rodizio_brinquedos_v3/ui/services/app_feedback.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_bottom_navigation.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_surface_card.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/empty_state.dart';

class CategoriesManagePage extends StatelessWidget {
  final ToyRepository toyRepository;
  final SettingsRepository? settingsRepository;
  final PurchaseService? purchaseService;
  final int topNavigationIndex;
  final VoidCallback? onOpenHomeTab;
  final VoidCallback? onOpenRoundTab;
  final VoidCallback? onOpenWeeklyPlanning;
  final VoidCallback? onOpenToysTab;
  final VoidCallback? onOpenBoxesTab;
  final VoidCallback? onOpenSettings;

  const CategoriesManagePage({
    super.key,
    required this.toyRepository,
    this.settingsRepository,
    this.purchaseService,
    this.topNavigationIndex = 4,
    this.onOpenHomeTab,
    this.onOpenRoundTab,
    this.onOpenWeeklyPlanning,
    this.onOpenToysTab,
    this.onOpenBoxesTab,
    this.onOpenSettings,
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

  Future<void> _remove(
      BuildContext context, CategoryDefinition category) async {
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

  Future<void> _reactivate(
    BuildContext context,
    CategoryDefinition category,
  ) async {
    await toyRepository.reactivateCategory(categoryId: category.id);
  }

  void _closeRoute(BuildContext context) {
    Navigator.of(context).maybePop();
  }

  VoidCallback _navigationAction(BuildContext context, VoidCallback? action) {
    return action ?? () => _closeRoute(context);
  }

  Widget _buildIpadTopNavigation(BuildContext context) {
    return AppTopNavigation(
      currentIndex: topNavigationIndex,
      onHomeTap: _navigationAction(context, onOpenHomeTab),
      onRoundTap: _navigationAction(context, onOpenRoundTab),
      onWeeklyPlanningTap: _navigationAction(context, onOpenWeeklyPlanning),
      onToysTap: _navigationAction(context, onOpenToysTab),
      onBoxesTap: _navigationAction(context, onOpenBoxesTab),
      onSettingsTap: _navigationAction(context, onOpenSettings),
    );
  }

  Widget _buildIpadScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: _ManageIpadPalette.bg,
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<List<CategoryDefinition>>(
          stream: toyRepository.watchCategories(activeOnly: false),
          builder: (context, snapshot) {
            final categories = snapshot.data ?? const <CategoryDefinition>[];
            if (snapshot.connectionState == ConnectionState.waiting &&
                categories.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return _buildIpadContent(context, categories);
          },
        ),
      ),
    );
  }

  Widget _buildIpadContent(
    BuildContext context,
    List<CategoryDefinition> categories,
  ) {
    final bottomPadding = AppBottomNavigation.reservedScrollPadding(context);
    final activeCount =
        categories.where((category) => category.isActive).length;
    final inactiveCount = categories.length - activeCount;

    return ListView(
      padding: EdgeInsets.fromLTRB(24, 18, 24, bottomPadding),
      physics: const BouncingScrollPhysics(),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1032),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildIpadTopNavigation(context),
                const SizedBox(height: 18),
                _ManageIpadHeader(
                  icon: Icons.category_outlined,
                  title: 'Gerenciar categorias',
                  subtitle:
                      'Organize os tipos de brinquedo usados no cat\u00e1logo e nas rodadas.',
                  primaryLabel: 'Nova categoria',
                  onPrimary: () => _showCategoryDialog(context),
                  onBack: () => _closeRoute(context),
                ),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final gap = constraints.maxWidth >= 980 ? 22.0 : 18.0;
                    final leftWidth = (constraints.maxWidth - gap) * 0.61;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: leftWidth.clamp(540.0, 680.0),
                          child: _ManageIpadSurface(
                            child: _buildIpadCategoryList(
                              context,
                              categories,
                            ),
                          ),
                        ),
                        SizedBox(width: gap),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _ManageIpadSummaryCard(
                                title: 'Resumo',
                                stats: [
                                  _ManageIpadStat(
                                    label: 'Categorias',
                                    value: '${categories.length}',
                                    icon: Icons.category_outlined,
                                  ),
                                  _ManageIpadStat(
                                    label: 'Ativas',
                                    value: '$activeCount',
                                    icon: Icons.check_circle_outline,
                                    semantic: true,
                                  ),
                                  _ManageIpadStat(
                                    label: 'Inativas',
                                    value: '$inactiveCount',
                                    icon: Icons.pause_circle_outline,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const _ManageIpadTipCard(
                                title: 'Dica',
                                message:
                                    'Use nomes curtos e exemplos claros. Isso ajuda a equilibrar as rodadas sem transformar o cadastro em trabalho extra.',
                              ),
                              const SizedBox(height: 16),
                              _ManageIpadActionsCard(
                                title: 'A\u00e7\u00f5es r\u00e1pidas',
                                primaryLabel: 'Nova categoria',
                                onPrimary: () => _showCategoryDialog(context),
                                secondaryLabel: 'Voltar',
                                onSecondary: () => _closeRoute(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIpadCategoryList(
    BuildContext context,
    List<CategoryDefinition> categories,
  ) {
    if (categories.isEmpty) {
      return _ManageIpadEmptyPanel(
        icon: Icons.category_outlined,
        title: 'Nenhuma categoria',
        message:
            'Crie categorias para organizar o cat\u00e1logo com mais clareza.',
        actionLabel: 'Nova categoria',
        onAction: () => _showCategoryDialog(context),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ManageIpadSectionTitle(
          icon: Icons.category_outlined,
          title: 'Categorias do cat\u00e1logo',
          subtitle: 'Lista real de categorias ativas e inativas.',
        ),
        const SizedBox(height: 18),
        for (final category in categories) ...[
          _buildIpadCategoryRow(context, category),
          if (category != categories.last)
            const Divider(height: 18, color: _ManageIpadPalette.border),
        ],
      ],
    );
  }

  Widget _buildIpadCategoryRow(
    BuildContext context,
    CategoryDefinition category,
  ) {
    final examples = _decodeDisplayText((category.examples ?? '').trim());
    final aspect = _decodeDisplayText(
      (category.developmentAspect ?? '').trim(),
    );
    final statusLabel = category.isActive ? 'Ativa' : 'Inativa';

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ManageIpadIconBox(
              icon: category.isActive
                  ? Icons.category_outlined
                  : Icons.category_rounded,
              semantic: category.isActive,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _decodeDisplayText(category.name),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: UiTokens.textBody.copyWith(
                            color: _ManageIpadPalette.text,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _ManageIpadStatusPill(
                        label: statusLabel,
                        active: category.isActive,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    examples.isEmpty
                        ? 'Ainda sem exemplos cadastrados.'
                        : examples,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: UiTokens.textCaption.copyWith(
                      color: _ManageIpadPalette.textMid,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                  if (aspect.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      aspect,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: UiTokens.textMicro.copyWith(
                        color: _ManageIpadPalette.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            _ManageIpadMiniButton(
              tooltip: 'Editar categoria',
              icon: Icons.edit_outlined,
              onTap: () => _showCategoryDialog(context, category: category),
            ),
            if (!category.isActive) ...[
              const SizedBox(width: 8),
              _ManageIpadMiniButton(
                tooltip: 'Reativar categoria',
                icon: Icons.refresh_rounded,
                onTap: () => _reactivate(context, category),
              ),
            ],
            const SizedBox(width: 8),
            _ManageIpadMiniButton(
              tooltip: 'Remover categoria',
              icon: Icons.delete_outline_rounded,
              destructive: true,
              onTap: () => _remove(context, category),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIpad = MediaQuery.sizeOf(context).shortestSide >= 600;
    if (isIpad) return _buildIpadScaffold(context);

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
                  final aspect = _decodeDisplayText(
                    (c.developmentAspect ?? '').trim(),
                  );
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
                                    _reactivate(context, c);
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
                          if (aspect.isNotEmpty) ...[
                            const SizedBox(height: UiTokens.spacingSm),
                            Text(
                              'Aspecto',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: UiTokens.spacingXs),
                            Text(
                              aspect,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: UiTokens.textSecondary,
                                    height: 1.3,
                                  ),
                            ),
                          ],
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

class _ManageIpadPalette {
  static const bg = Color(0xFFFDF7F0);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFF3E2D0);
  static const orange = Color(0xFFF97316);
  static const orangeDark = Color(0xFFC2410C);
  static const orangeLight = Color(0xFFFFF3E8);
  static const orangeBorder = Color(0xFFFFD2AE);
  static const text = Color(0xFF25180A);
  static const textMid = Color(0xFF6B4F30);
  static const textMuted = Color(0xFFA8896A);
  static const green = Color(0xFF16A34A);
  static const greenLight = Color(0xFFEAFBF0);
  static const greenBorder = Color(0xFFBBF7D0);
  static const red = Color(0xFFDC2626);
  static const redLight = Color(0xFFFFF1F2);
  static const redBorder = Color(0xFFFECACA);
  static const shadow = Color(0x14F97316);
}

class _ManageIpadSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _ManageIpadSurface({
    required this.child,
    this.padding = const EdgeInsets.all(22),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _ManageIpadPalette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _ManageIpadPalette.border),
        boxShadow: const [
          BoxShadow(
            color: _ManageIpadPalette.shadow,
            blurRadius: 30,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ManageIpadHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback onBack;

  const _ManageIpadHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.primaryLabel,
    required this.onPrimary,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return _ManageIpadSurface(
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 26),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFA11F), _ManageIpadPalette.orange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x45F97316),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 31),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ROD\u00cdZIO DE BRINQUEDOS',
                  style: UiTokens.textMicro.copyWith(
                    color: _ManageIpadPalette.orange,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textTitle.copyWith(
                    color: _ManageIpadPalette.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: UiTokens.textBody.copyWith(
                    color: _ManageIpadPalette.textMid,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Voltar'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(116, 52),
                  foregroundColor: _ManageIpadPalette.orangeDark,
                  side:
                      const BorderSide(color: _ManageIpadPalette.orangeBorder),
                ),
              ),
              FilledButton.icon(
                onPressed: onPrimary,
                icon: const Icon(Icons.add_rounded),
                label: Text(primaryLabel),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(164, 52),
                  backgroundColor: _ManageIpadPalette.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ManageIpadSectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ManageIpadSectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _ManageIpadPalette.orangeLight,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: _ManageIpadPalette.orangeBorder),
          ),
          child: Icon(icon, color: _ManageIpadPalette.orange, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: UiTokens.textSectionTitle.copyWith(
                  color: _ManageIpadPalette.text,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: UiTokens.textCaption.copyWith(
                  color: _ManageIpadPalette.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ManageIpadIconBox extends StatelessWidget {
  final IconData icon;
  final bool semantic;

  const _ManageIpadIconBox({
    required this.icon,
    this.semantic = false,
  });

  @override
  Widget build(BuildContext context) {
    final foreground =
        semantic ? _ManageIpadPalette.green : _ManageIpadPalette.orange;
    final background = semantic
        ? _ManageIpadPalette.greenLight
        : _ManageIpadPalette.orangeLight;
    final border = semantic
        ? _ManageIpadPalette.greenBorder
        : _ManageIpadPalette.orangeBorder;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Icon(icon, color: foreground, size: 23),
    );
  }
}

class _ManageIpadStatusPill extends StatelessWidget {
  final String label;
  final bool active;

  const _ManageIpadStatusPill({
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active
            ? _ManageIpadPalette.greenLight
            : _ManageIpadPalette.orangeLight,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active
              ? _ManageIpadPalette.greenBorder
              : _ManageIpadPalette.orangeBorder,
        ),
      ),
      child: Text(
        label,
        style: UiTokens.textMicro.copyWith(
          color:
              active ? _ManageIpadPalette.green : _ManageIpadPalette.orangeDark,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ManageIpadMiniButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;
  final bool destructive;

  const _ManageIpadMiniButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: destructive
            ? _ManageIpadPalette.redLight
            : _ManageIpadPalette.orangeLight,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: destructive
                    ? _ManageIpadPalette.redBorder
                    : _ManageIpadPalette.orangeBorder,
              ),
            ),
            child: Icon(
              icon,
              color: destructive
                  ? _ManageIpadPalette.red
                  : _ManageIpadPalette.orange,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _ManageIpadStat {
  final String label;
  final String value;
  final IconData icon;
  final bool semantic;

  const _ManageIpadStat({
    required this.label,
    required this.value,
    required this.icon,
    this.semantic = false,
  });
}

class _ManageIpadSummaryCard extends StatelessWidget {
  final String title;
  final List<_ManageIpadStat> stats;

  const _ManageIpadSummaryCard({
    required this.title,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return _ManageIpadSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ManageIpadSectionTitle(
            icon: Icons.insights_outlined,
            title: title,
            subtitle: 'Vis\u00e3o r\u00e1pida desta organiza\u00e7\u00e3o.',
          ),
          const SizedBox(height: 16),
          for (final stat in stats) ...[
            Row(
              children: [
                _ManageIpadIconBox(icon: stat.icon, semantic: stat.semantic),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    stat.label,
                    style: UiTokens.textCaption.copyWith(
                      color: _ManageIpadPalette.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  stat.value,
                  style: UiTokens.textSectionTitle.copyWith(
                    color: stat.semantic
                        ? _ManageIpadPalette.green
                        : _ManageIpadPalette.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            if (stat != stats.last)
              const Divider(height: 18, color: _ManageIpadPalette.border),
          ],
        ],
      ),
    );
  }
}

class _ManageIpadTipCard extends StatelessWidget {
  final String title;
  final String message;

  const _ManageIpadTipCard({
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return _ManageIpadSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ManageIpadIconBox(icon: Icons.lightbulb_outline_rounded),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: UiTokens.textBody.copyWith(
                    color: _ManageIpadPalette.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: UiTokens.textCaption.copyWith(
                    color: _ManageIpadPalette.textMid,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ManageIpadActionsCard extends StatelessWidget {
  final String title;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String secondaryLabel;
  final VoidCallback onSecondary;

  const _ManageIpadActionsCard({
    required this.title,
    required this.primaryLabel,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return _ManageIpadSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ManageIpadSectionTitle(
            icon: Icons.touch_app_outlined,
            title: title,
            subtitle: 'A\u00e7\u00f5es reais desta tela.',
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onPrimary,
            icon: const Icon(Icons.add_rounded),
            label: Text(primaryLabel),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: _ManageIpadPalette.orange,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onSecondary,
            icon: const Icon(Icons.arrow_back_rounded),
            label: Text(secondaryLabel),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              foregroundColor: _ManageIpadPalette.orangeDark,
              side: const BorderSide(color: _ManageIpadPalette.orangeBorder),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManageIpadEmptyPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _ManageIpadEmptyPanel({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        _ManageIpadIconBox(icon: icon),
        const SizedBox(height: 14),
        Text(
          title,
          style: UiTokens.textSectionTitle.copyWith(
            color: _ManageIpadPalette.text,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: UiTokens.textCaption.copyWith(
            color: _ManageIpadPalette.textMid,
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onAction,
          icon: const Icon(Icons.add_rounded),
          label: Text(actionLabel),
          style: FilledButton.styleFrom(
            backgroundColor: _ManageIpadPalette.orange,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rodizio_brinquedos_v3/l10n/app_localizations.dart';
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
    final copy = _CategoriesCopy(context.l10n.isEn);
    final nameController = TextEditingController(text: category?.name ?? '');
    final examplesController = TextEditingController(
      text: category?.examples ?? '',
    );

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(category == null ? copy.newCategory : copy.editCategory),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: InputDecoration(labelText: copy.name),
            ),
            const SizedBox(height: UiTokens.m),
            TextField(
              controller: examplesController,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: copy.examples,
                hintText: copy.examplesHint,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(copy.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(copy.save),
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
    BuildContext context,
    CategoryDefinition category,
  ) async {
    final copy = _CategoriesCopy(context.l10n.isEn);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(copy.removeCategoryQuestion),
        content: Text(copy.removeCategoryMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(copy.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: UiTokens.danger,
              foregroundColor: UiTokens.surface,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(copy.remove),
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
    final l10n = context.l10n;
    final copy = _CategoriesCopy(l10n.isEn);
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
                  title: copy.manageCategories,
                  subtitle: copy.manageSubtitle,
                  primaryLabel: copy.newCategory,
                  onPrimary: () => _showCategoryDialog(context),
                  onBack: () => _closeRoute(context),
                ),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final useSingleColumn = constraints.maxWidth < 900;
                    final gap = constraints.maxWidth >= 980 ? 22.0 : 18.0;
                    final leftWidth = (constraints.maxWidth - gap) * 0.61;
                    final list = _ManageIpadSurface(
                      child: _buildIpadCategoryList(context, categories),
                    );
                    final details = Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ManageIpadSummaryCard(
                          title: copy.summary,
                          stats: [
                            _ManageIpadStat(
                              label: copy.categories,
                              value: '${categories.length}',
                              icon: Icons.category_outlined,
                            ),
                            _ManageIpadStat(
                              label: copy.activePlural,
                              value: '$activeCount',
                              icon: Icons.check_circle_outline,
                              semantic: true,
                            ),
                            _ManageIpadStat(
                              label: copy.inactivePlural,
                              value: '$inactiveCount',
                              icon: Icons.pause_circle_outline,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _ManageIpadTipCard(
                          title: copy.tip,
                          message: copy.tipMessage,
                        ),
                        const SizedBox(height: 16),
                        _ManageIpadActionsCard(
                          title: copy.quickActions,
                          primaryLabel: copy.newCategory,
                          onPrimary: () => _showCategoryDialog(context),
                          secondaryLabel: copy.back,
                          onSecondary: () => _closeRoute(context),
                        ),
                      ],
                    );

                    if (useSingleColumn) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          list,
                          SizedBox(height: gap),
                          details,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: leftWidth.clamp(540.0, 680.0),
                          child: list,
                        ),
                        SizedBox(width: gap),
                        Expanded(child: details),
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
    final copy = _CategoriesCopy(context.l10n.isEn);
    if (categories.isEmpty) {
      return _ManageIpadEmptyPanel(
        icon: Icons.category_outlined,
        title: copy.noCategories,
        message: copy.noCategoriesMessage,
        actionLabel: copy.newCategory,
        onAction: () => _showCategoryDialog(context),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ManageIpadSectionTitle(
          icon: Icons.category_outlined,
          title: copy.catalogCategories,
          subtitle: copy.listSubtitle,
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
    final copy = _CategoriesCopy(context.l10n.isEn);
    final rawExamples = _decodeDisplayText((category.examples ?? '').trim());
    final rawAspect = _decodeDisplayText(
      (category.developmentAspect ?? '').trim(),
    );
    final examples = copy.categoryDetail(category.id, rawExamples);
    final aspect = copy.categoryDetail(category.id, rawAspect);
    final statusLabel = category.isActive ? copy.active : copy.inactive;

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
                          context.l10n.categoryNameById(
                            category.id,
                            _decodeDisplayText(category.name),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.appTypography.body.copyWith(
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
                    examples.isEmpty ? copy.noExamples : examples,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.appTypography.caption.copyWith(
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
                      style: context.appTypography.micro.copyWith(
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
              tooltip: copy.editCategory,
              icon: Icons.edit_outlined,
              onTap: () => _showCategoryDialog(context, category: category),
            ),
            if (!category.isActive) ...[
              const SizedBox(width: 8),
              _ManageIpadMiniButton(
                tooltip: copy.reactivateCategory,
                icon: Icons.refresh_rounded,
                onTap: () => _reactivate(context, category),
              ),
            ],
            const SizedBox(width: 8),
            _ManageIpadMiniButton(
              tooltip: copy.removeCategory,
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
    final copy = _CategoriesCopy(context.l10n.isEn);
    final isIpad = context.usesTabletPresentation;
    if (isIpad) return _buildIpadScaffold(context);

    return Scaffold(
      backgroundColor: UiTokens.bg,
      appBar: AppBar(title: Text(copy.manageCategories)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryDialog(context),
        icon: const Icon(Icons.add),
        label: Text(copy.newCategory),
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
                title: copy.noCategories,
                message: copy.noCategoriesMessage,
                actionLabel: copy.newCategory,
                onAction: () => _showCategoryDialog(context),
              );
            }

            return ListView(
              padding: const EdgeInsets.only(bottom: 104),
              children: [
                AppSurfaceCard(
                  padding: const EdgeInsets.all(UiTokens.spacingLg),
                  color: UiTokens.actionOrangeSoft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        copy.catalogCategories,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: UiTokens.spacingXs),
                      Text(
                        copy.clearNamesMessage,
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
                  final rawExamples = _decodeDisplayText(
                    (c.examples ?? '').trim(),
                  );
                  final rawAspect = _decodeDisplayText(
                    (c.developmentAspect ?? '').trim(),
                  );
                  final examples = copy.categoryDetail(c.id, rawExamples);
                  final aspect = copy.categoryDetail(c.id, rawAspect);
                  final statusSuffix = c.isActive ? copy.active : copy.inactive;
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
                                      context.l10n.categoryNameById(
                                        c.id,
                                        _decodeDisplayText(c.name),
                                      ),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleSmall,
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
                                tooltip: copy.categoryActions,
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showCategoryDialog(context, category: c);
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
                                  PopupMenuItem<String>(
                                    value: 'edit',
                                    child: Text(copy.edit),
                                  ),
                                  if (!c.isActive)
                                    PopupMenuItem<String>(
                                      value: 'reactivate',
                                      child: Text(copy.reactivate),
                                    ),
                                  PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Text(copy.remove),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: UiTokens.spacingMd),
                          Text(
                            copy.examples,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: UiTokens.spacingXs),
                          Text(
                            examples.isEmpty ? copy.noExamples : examples,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          if (aspect.isNotEmpty) ...[
                            const SizedBox(height: UiTokens.spacingSm),
                            Text(
                              copy.aspect,
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

class _CategoriesCopy {
  final bool isEn;

  const _CategoriesCopy(this.isEn);

  String get newCategory => isEn ? 'New category' : 'Nova categoria';
  String get editCategory => isEn ? 'Edit category' : 'Editar categoria';
  String get removeCategory => isEn ? 'Remove category' : 'Remover categoria';
  String get reactivateCategory =>
      isEn ? 'Reactivate category' : 'Reativar categoria';
  String get removeCategoryQuestion =>
      isEn ? 'Remove category?' : 'Remover categoria?';
  String get removeCategoryMessage => isEn
      ? 'If the category is in use, it will be marked as inactive.'
      : 'Se a categoria estiver em uso, ela ser\u00e1 marcada como inativa.';
  String get name => isEn ? 'Name' : 'Nome';
  String get examples => isEn ? 'Examples' : 'Exemplos';
  String get examplesHint => isEn
      ? 'e.g. car, truck, train'
      : 'Ex.: carrinho, caminh\u00e3o, trenzinho';
  String get cancel => isEn ? 'Cancel' : 'Cancelar';
  String get save => isEn ? 'Save' : 'Salvar';
  String get remove => isEn ? 'Remove' : 'Remover';
  String get edit => isEn ? 'Edit' : 'Editar';
  String get reactivate => isEn ? 'Reactivate' : 'Reativar';
  String get back => isEn ? 'Back' : 'Voltar';
  String get manageCategories =>
      isEn ? 'Manage categories' : 'Gerenciar categorias';
  String get manageSubtitle => isEn
      ? 'Organize the toy types used in the catalog and rotations.'
      : 'Organize os tipos de brinquedo usados no cat\u00e1logo e nas rodadas.';
  String get summary => isEn ? 'Summary' : 'Resumo';
  String get categories => isEn ? 'Categories' : 'Categorias';
  String get activePlural => isEn ? 'Active' : 'Ativas';
  String get inactivePlural => isEn ? 'Inactive' : 'Inativas';
  String get active => isEn ? 'Active' : 'Ativa';
  String get inactive => isEn ? 'Inactive' : 'Inativa';
  String get tip => isEn ? 'Tip' : 'Dica';
  String get tipMessage => isEn
      ? 'Use short names and clear examples. This helps balance rotations without adding extra work.'
      : 'Use nomes curtos e exemplos claros. Isso ajuda a equilibrar as rodadas sem transformar o cadastro em trabalho extra.';
  String get quickActions =>
      isEn ? 'Quick actions' : 'A\u00e7\u00f5es r\u00e1pidas';
  String get noCategories => isEn ? 'No categories yet' : 'Nenhuma categoria';
  String get noCategoriesMessage => isEn
      ? 'Create categories to organize the catalog more clearly.'
      : 'Crie categorias para organizar o cat\u00e1logo com mais clareza.';
  String get catalogCategories =>
      isEn ? 'Catalog categories' : 'Categorias do cat\u00e1logo';
  String get listSubtitle => isEn
      ? 'The complete list of active and inactive categories.'
      : 'Lista real de categorias ativas e inativas.';
  String get noExamples => isEn
      ? 'No examples have been added yet.'
      : 'Ainda sem exemplos cadastrados.';
  String get clearNamesMessage => isEn
      ? 'Use clear names so choosing a category stays effortless.'
      : 'Mantenha nomes claros para escolher categoria sem pensar demais.';
  String get categoryActions =>
      isEn ? 'Category actions' : 'A\u00e7\u00f5es da categoria';
  String get aspect => isEn ? 'Development area' : 'Aspecto';

  String categoryDetail(String categoryId, String value) {
    if (!isEn || value.isEmpty) return value;
    final officialPortuguese = _officialPortugueseDetails[categoryId];
    if (officialPortuguese == null ||
        !officialPortuguese.contains(value.toLowerCase())) {
      return value;
    }
    return _officialEnglishDetails[categoryId] ?? value;
  }

  static const _officialPortugueseDetails = <String, Set<String>>{
    'corpo': {'movimento, equilíbrio, sopro e pausa corporal'},
    'exploracao': {'texturas, sons, cores, água, areia e descoberta'},
    'maos': {'encaixar, empilhar, montar e resolver problemas'},
    'imaginacao': {'faz de conta, arte, criação e expressão'},
    'comunicacao': {'livros, fala, escuta, narrativa e conversa'},
  };

  static const _officialEnglishDetails = <String, String>{
    'corpo': 'Movement, balance, breathing, and body breaks',
    'exploracao': 'Textures, sounds, colors, water, sand, and discovery',
    'maos': 'Fitting, stacking, building, and problem-solving',
    'imaginacao': 'Pretend play, art, creation, and expression',
    'comunicacao': 'Books, speech, listening, storytelling, and conversation',
  };
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
    final hero = Container(
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
    );
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.appNameUpper,
          style: context.appTypography.micro.copyWith(
            color: _ManageIpadPalette.orange,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          title,
          style: context.appTypography.pageTitle.copyWith(
            color: _ManageIpadPalette.text,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: context.appTypography.body.copyWith(
            color: _ManageIpadPalette.textMid,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
    final actions = Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
          label: Text(context.l10n.isEn ? 'Back' : 'Voltar'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(116, 52),
            foregroundColor: _ManageIpadPalette.orangeDark,
            side: const BorderSide(color: _ManageIpadPalette.orangeBorder),
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
    );

    return _ManageIpadSurface(
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 26),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 900;
          final heading = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              hero,
              const SizedBox(width: 20),
              Expanded(child: copy),
            ],
          );
          return compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    heading,
                    const SizedBox(height: 18),
                    Align(alignment: Alignment.centerRight, child: actions),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: heading),
                    const SizedBox(width: 18),
                    actions,
                  ],
                );
        },
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
                style: context.appTypography.sectionTitle.copyWith(
                  color: _ManageIpadPalette.text,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.appTypography.caption.copyWith(
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

  const _ManageIpadIconBox({required this.icon, this.semantic = false});

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

  const _ManageIpadStatusPill({required this.label, required this.active});

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
        style: context.appTypography.micro.copyWith(
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

  const _ManageIpadSummaryCard({required this.title, required this.stats});

  @override
  Widget build(BuildContext context) {
    return _ManageIpadSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ManageIpadSectionTitle(
            icon: Icons.insights_outlined,
            title: title,
            subtitle: context.l10n.isEn
                ? 'A quick view of this organization.'
                : 'Vis\u00e3o r\u00e1pida desta organiza\u00e7\u00e3o.',
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
                    style: context.appTypography.caption.copyWith(
                      color: _ManageIpadPalette.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  stat.value,
                  style: context.appTypography.sectionTitle.copyWith(
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

  const _ManageIpadTipCard({required this.title, required this.message});

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
                  style: context.appTypography.body.copyWith(
                    color: _ManageIpadPalette.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: context.appTypography.caption.copyWith(
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
            subtitle: context.l10n.isEn
                ? 'Actions available on this screen.'
                : 'A\u00e7\u00f5es reais desta tela.',
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
          style: context.appTypography.sectionTitle.copyWith(
            color: _ManageIpadPalette.text,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: context.appTypography.caption.copyWith(
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

import 'package:flutter/material.dart';

import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/demo/demo_data_loader.dart';
import 'package:rodizio_brinquedos_v3/domain/child_age/child_age_range.dart';
import 'package:rodizio_brinquedos_v3/features/paywall/paywall_page.dart';
import 'package:rodizio_brinquedos_v3/services/paywall_platform.dart';
import 'package:rodizio_brinquedos_v3/services/age_preset_service.dart';
import 'package:rodizio_brinquedos_v3/services/purchase_service.dart';
import 'package:rodizio_brinquedos_v3/ui/categories_manage_page.dart';
import 'package:rodizio_brinquedos_v3/ui/locations_manage_page.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_surface_card.dart';

class SettingsPage extends StatefulWidget {
  final SettingsRepository settingsRepository;
  final ToyRepository toyRepository;
  final PurchaseService purchaseService;

  const SettingsPage({
    super.key,
    required this.settingsRepository,
    required this.toyRepository,
    required this.purchaseService,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final Map<String, bool> _includedDraft = <String, bool>{};
  final Map<String, int> _quotaDraft = <String, int>{};
  final Set<String> _autoClampPending = <String>{};

  List<RoundCategorySettingRow> _latestRows = const <RoundCategorySettingRow>[];
  bool _draftInitialized = false;
  bool _demoActionInProgress = false;

  void _initializeDraftIfNeeded(
    List<RoundCategorySettingRow> rows,
    Map<String, int> availableCounts,
  ) {
    if (_draftInitialized) return;

    final autoClamp = <String, int>{};

    for (final row in rows) {
      final id = row.category.id;
      _includedDraft[id] = row.isIncluded;

      var quota = row.quota < 0 ? 0 : row.quota;
      final maxSelectable = _maxSelectableForRow(row, availableCounts);
      if (quota > maxSelectable) {
        quota = maxSelectable;
        autoClamp[id] = quota;
      }

      _quotaDraft[id] = quota;
    }

    _draftInitialized = true;

    if (autoClamp.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _persistAutoClamp(autoClamp);
      });
    }
  }

  int _maxSelectableForRow(
    RoundCategorySettingRow row,
    Map<String, int> availableCounts,
  ) {
    final availableCount = availableCounts[row.category.id] ?? 0;
    return availableCount < 0 ? 0 : availableCount;
  }

  void _syncDraftWithAvailability(
    List<RoundCategorySettingRow> rows,
    Map<String, int> availableCounts,
  ) {
    final autoClamp = <String, int>{};
    var changed = false;

    for (final row in rows) {
      final id = row.category.id;
      final currentQuota = _quotaDraft[id] ?? (row.quota < 0 ? 0 : row.quota);
      final maxSelectable = _maxSelectableForRow(row, availableCounts);

      if (currentQuota > maxSelectable) {
        _quotaDraft[id] = maxSelectable;
        autoClamp[id] = maxSelectable;
        changed = true;
      }
    }

    if (changed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {});
      });
    }

    if (autoClamp.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _persistAutoClamp(autoClamp);
      });
    }
  }

  Future<void> _persistAutoClamp(Map<String, int> values) async {
    for (final entry in values.entries) {
      if (_autoClampPending.contains(entry.key)) continue;
      _autoClampPending.add(entry.key);

      try {
        await widget.toyRepository.setCategoryQuotaInRound(
          categoryId: entry.key,
          quota: entry.value,
        );
      } finally {
        _autoClampPending.remove(entry.key);
      }
    }
  }

  Future<void> _save() async {
    for (final row in _latestRows) {
      final id = row.category.id;
      final included = _includedDraft[id] ?? row.isIncluded;
      final quota = _quotaDraft[id] ?? row.quota;

      await widget.toyRepository.setCategoryQuotaInRound(
        categoryId: id,
        quota: quota,
      );
      await widget.toyRepository.setCategoryIncludedInRound(
        categoryId: id,
        isIncluded: included,
      );
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configurações salvas.')),
    );
  }

  void _openCategories() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoriesManagePage(
          toyRepository: widget.toyRepository,
          settingsRepository: widget.settingsRepository,
          purchaseService: widget.purchaseService,
        ),
      ),
    );
  }

  void _openLocations() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LocationsManagePage(
          toyRepository: widget.toyRepository,
          settingsRepository: widget.settingsRepository,
          purchaseService: widget.purchaseService,
        ),
      ),
    );
  }

  void _openPaywall() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaywallPage(
          purchaseService: widget.purchaseService,
          source: 'settings',
        ),
      ),
    );
  }

  AgePresetService? _agePresetService() {
    final db = widget.toyRepository.db;
    if (db == null) return null;
    return AgePresetService(
      db: db,
      settingsRepository: widget.settingsRepository,
    );
  }

  Future<void> _openChildAgeRangeSelector() async {
    final service = _agePresetService();
    if (service == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Banco local indisponivel.')),
      );
      return;
    }

    final selected = await showModalBottomSheet<ChildAgeRange>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final current = widget.settingsRepository.childAgeRange;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Idade da criança',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              for (final range in ChildAgeRange.values)
                ListTile(
                  title: Text(range.label),
                  trailing: current == range ? const Icon(Icons.check) : null,
                  onTap: () => Navigator.of(context).pop(range),
                ),
            ],
          ),
        );
      },
    );

    if (selected == null) return;

    await service.saveAgeRangeOnly(selected);
    if (!mounted) return;

    final shouldApply = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rodízio sugerido'),
          content: const Text(
            'Encontramos uma configuração equilibrada para esta fase.\nNo fim de semana, incluímos 1 brinquedo extra para dar mais variedade.\n\nDeseja aplicar ao rodízio?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Não agora'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Aplicar'),
            ),
          ],
        );
      },
    );

    if (shouldApply != true) return;

    try {
      await service.applyAgePreset(selected);
      if (!mounted) return;
      setState(_resetRoundDrafts);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuração aplicada ao rodízio.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao aplicar configuração: $error')),
      );
    }
  }

  Future<void> _restoreRoundDefaults() async {
    await widget.toyRepository.restoreRoundCategoryDefaults();

    if (!mounted) return;
    setState(_resetRoundDrafts);
  }

  void _resetRoundDrafts() {
    _draftInitialized = false;
    _includedDraft.clear();
    _quotaDraft.clear();
  }

  Future<void> _runDemoAction({
    required Future<void> Function() action,
    required String successMessage,
  }) async {
    if (_demoActionInProgress) return;

    final db = widget.toyRepository.db;
    if (db == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Banco local indisponivel.')),
      );
      return;
    }

    setState(() => _demoActionInProgress = true);

    try {
      await action();
      await widget.settingsRepository.load();
      if (!mounted) return;
      setState(_resetRoundDrafts);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage)),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao atualizar dados demo: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _demoActionInProgress = false);
      }
    }
  }

  Future<void> _populateDemoData() async {
    await _runDemoAction(
      action: () async {
        final db = widget.toyRepository.db!;
        await DemoDataLoader.populate(db);
      },
      successMessage: 'Dados de demonstracao recriados.',
    );
  }

  Future<void> _clearDemoData() async {
    await _runDemoAction(
      action: () async {
        final db = widget.toyRepository.db!;
        await DemoDataLoader.clear(db);
        await widget.toyRepository.ensureSeedData();
      },
      successMessage: 'Dados de demonstracao limpos.',
    );
  }

  Future<void> _onSwitchChanged(
    RoundCategorySettingRow row,
    bool enabled,
    int availableCount,
  ) async {
    final id = row.category.id;

    setState(() {
      _includedDraft[id] = enabled;

      if (enabled) {
        final current = _quotaDraft[id] ?? (row.quota < 0 ? 0 : row.quota);
        if (current <= 0) {
          _quotaDraft[id] = availableCount > 0 ? 1 : 0;
        } else if (current > availableCount) {
          _quotaDraft[id] = availableCount;
        }
      } else {
        _quotaDraft[id] = 0;
      }
    });
  }

  Future<int?> _openManualQuotaDialog({
    required int initialValue,
    required int maxValue,
  }) async {
    final controller = TextEditingController(text: '$initialValue');
    String? errorText;

    final value = await showDialog<int>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('Definir cota'),
              content: TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantidade',
                  helperText: 'Mínimo 0, máximo $maxValue',
                  errorText: errorText,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('CANCELAR'),
                ),
                FilledButton(
                  onPressed: () {
                    final parsed = int.tryParse(controller.text.trim());
                    if (parsed == null) {
                      setLocalState(
                        () => errorText = 'Digite um número inteiro.',
                      );
                      return;
                    }
                    if (parsed < 0) {
                      setLocalState(() => errorText = 'O valor mínimo é 0.');
                      return;
                    }
                    if (parsed > maxValue) {
                      setLocalState(
                        () => errorText = 'O valor máximo é $maxValue.',
                      );
                      return;
                    }

                    Navigator.of(context).pop(parsed);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
    return value;
  }

  Future<void> _selectQuota(
    RoundCategorySettingRow row,
    int availableCount,
  ) async {
    final id = row.category.id;
    final maxSelectable = availableCount < 0 ? 0 : availableCount;
    var currentQuota = _quotaDraft[id] ?? (row.quota < 0 ? 0 : row.quota);

    if (currentQuota > maxSelectable) {
      currentQuota = maxSelectable;
      setState(() {
        _quotaDraft[id] = maxSelectable;
      });
    }

    const customValue = -1;

    final selected = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final baseOptions = <int>[1, 2, 3, 4, 5, 6];

        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (maxSelectable == 0)
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Text('Nenhum disponível nesta categoria'),
                    ),
                  ListTile(
                    title: const Text('0'),
                    trailing:
                        currentQuota == 0 ? const Icon(Icons.check) : null,
                    onTap: () => Navigator.of(context).pop(0),
                  ),
                  ...baseOptions.map((value) {
                    final enabled = value <= maxSelectable;
                    return ListTile(
                      enabled: enabled,
                      title: Text('$value'),
                      trailing: currentQuota == value
                          ? const Icon(Icons.check)
                          : null,
                      onTap: enabled
                          ? () => Navigator.of(context).pop(value)
                          : null,
                    );
                  }),
                  ListTile(
                    title: const Text('Mais de 6...'),
                    enabled: maxSelectable > 6,
                    onTap: maxSelectable > 6
                        ? () => Navigator.of(context).pop(customValue)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (selected == null) return;

    if (selected == customValue) {
      final manual = await _openManualQuotaDialog(
        initialValue: currentQuota,
        maxValue: maxSelectable,
      );
      if (manual == null) return;
      setState(() {
        _quotaDraft[id] = manual;
      });
      return;
    }

    setState(() {
      _quotaDraft[id] = selected;
    });
  }

  int _currentTotal() {
    var total = 0;
    for (final row in _latestRows) {
      final id = row.category.id;
      final included = _includedDraft[id] ?? row.isIncluded;
      if (!included) continue;
      final quota = _quotaDraft[id] ?? row.quota;
      total += quota < 0 ? 0 : quota;
    }
    return total;
  }

  Widget _buildManageCard(TextTheme textTheme) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(UiTokens.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Organiza\u00e7\u00e3o da casa',
            style: textTheme.titleSmall,
          ),
          const SizedBox(height: UiTokens.spacingSm),
          _SettingsTile(
            icon: Icons.category_outlined,
            title: 'Gerenciar categorias',
            subtitle: 'Editar, adicionar e inativar categorias',
            onTap: _openCategories,
          ),
          const SizedBox(height: UiTokens.spacingSm),
          _SettingsTile(
            icon: Icons.place_outlined,
            title: 'Gerenciar locais',
            subtitle: 'Editar e adicionar locais sugeridos',
            onTap: _openLocations,
          ),
        ],
      ),
    );
  }

  Widget _buildChildAgeCard(TextTheme textTheme) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(UiTokens.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Idade da criança',
            style: textTheme.titleSmall,
          ),
          const SizedBox(height: UiTokens.spacingSm),
          StreamBuilder<ChildAgeRange?>(
            stream: widget.settingsRepository.watchChildAgeRange(),
            initialData: widget.settingsRepository.childAgeRange,
            builder: (context, snapshot) {
              final ageRange = snapshot.data;
              return _SettingsTile(
                icon: Icons.child_care_outlined,
                title: 'Idade da criança',
                subtitle: ageRange == null
                    ? 'Escolha uma faixa etária para sugerir um rodízio equilibrado.'
                    : 'Faixa atual: ${ageRange.label}',
                onTap: _openChildAgeRangeSelector,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(TextTheme textTheme) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(UiTokens.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Prefer\u00eancias do app',
            style: textTheme.titleSmall,
          ),
          const SizedBox(height: UiTokens.spacingSm),
          StreamBuilder<bool>(
            stream: widget.settingsRepository.watchDarkModeEnabled(),
            initialData: widget.settingsRepository.darkModeEnabled,
            builder: (context, snapshot) {
              final enabled = snapshot.data ?? false;
              return SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Modo escuro'),
                subtitle: const Text('Altera apenas a aparencia do app'),
                value: enabled,
                onChanged: widget.settingsRepository.setDarkModeEnabled,
              );
            },
          ),
          StreamBuilder<bool>(
            stream: widget.settingsRepository.watchHapticEnabled(),
            initialData: widget.settingsRepository.hapticEnabled,
            builder: (context, snapshot) {
              final enabled = snapshot.data ?? true;
              return SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Vibração (haptic)'),
                subtitle: const Text('Toques leves nas ações principais'),
                value: enabled,
                onChanged: widget.settingsRepository.setHapticEnabled,
              );
            },
          ),
          StreamBuilder<bool>(
            stream: widget.settingsRepository.watchSoundEnabled(),
            initialData: widget.settingsRepository.soundEnabled,
            builder: (context, snapshot) {
              final enabled = snapshot.data ?? false;
              return SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Sons do app'),
                subtitle: const Text('Feedback sonoro em eventos do app'),
                value: enabled,
                onChanged: widget.settingsRepository.setSoundEnabled,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard(TextTheme textTheme) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(UiTokens.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Premium',
            style: textTheme.titleSmall,
          ),
          const SizedBox(height: UiTokens.spacingSm),
          _SettingsTile(
            icon: Icons.workspace_premium_outlined,
            title: isPaywallEnabledForCurrentPlatform
                ? 'Planejamento semanal Premium'
                : 'Premium no Android',
            subtitle: widget.purchaseService.isPremium
                ? 'Assinatura ativa neste aparelho'
                : isPaywallEnabledForCurrentPlatform
                    ? 'Abrir tela de assinatura'
                    : 'Assinatura em breve. Recursos liberados por enquanto.',
            onTap: _openPaywall,
          ),
        ],
      ),
    );
  }

  Widget _buildMarketingDemoCard(TextTheme textTheme) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(UiTokens.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Marketing / Demonstração',
            style: textTheme.titleSmall,
          ),
          const SizedBox(height: UiTokens.spacingSm),
          Text(
            'Ferramenta interna para simuladores. Substitui os dados locais por um conjunto previsivel para screenshots.',
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: UiTokens.spacingMd),
          FilledButton.icon(
            onPressed: _demoActionInProgress ? null : _populateDemoData,
            icon: const Icon(Icons.auto_awesome_outlined),
            label: Text(
              _demoActionInProgress
                  ? 'Atualizando...'
                  : 'Popular dados de demonstração',
            ),
          ),
          const SizedBox(height: UiTokens.spacingSm),
          OutlinedButton.icon(
            onPressed: _demoActionInProgress ? null : _clearDemoData,
            icon: const Icon(Icons.cleaning_services_outlined),
            label: const Text('Limpar dados de demonstração'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: UiTokens.bg,
      appBar: AppBar(
        title: const Text('Configurações'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Gerenciar',
            onSelected: (value) {
              if (value == 'categorias') {
                _openCategories();
                return;
              }
              if (value == 'locais') {
                _openLocations();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'categorias',
                child: Text('Gerenciar categorias'),
              ),
              PopupMenuItem<String>(
                value: 'locais',
                child: Text('Gerenciar locais'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(UiTokens.m),
          child: ListView(
            children: [
              AppSurfaceCard(
                padding: const EdgeInsets.all(UiTokens.spacingLg),
                color: UiTokens.primarySoft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configura\u00e7\u00f5es do app',
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: UiTokens.spacingXs),
                    Text(
                      'Ajuste prefer\u00eancias e a composi\u00e7\u00e3o da rodada de forma simples e organizada.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: UiTokens.s),
              _buildManageCard(textTheme),
              const SizedBox(height: UiTokens.s),
              _buildChildAgeCard(textTheme),
              const SizedBox(height: UiTokens.s),
              _buildFeedbackCard(textTheme),
              const SizedBox(height: UiTokens.s),
              _buildPremiumCard(textTheme),
              const SizedBox(height: UiTokens.s),
              if (DemoDataLoader.controlsEnabled) ...[
                _buildMarketingDemoCard(textTheme),
                const SizedBox(height: UiTokens.s),
              ],
              AppSurfaceCard(
                padding: const EdgeInsets.all(UiTokens.spacingMd),
                child: StreamBuilder<Map<String, int>>(
                  stream:
                      widget.toyRepository.watchAvailableToyCountByCategory(),
                  builder: (context, availableSnapshot) {
                    final availableCounts =
                        availableSnapshot.data ?? const <String, int>{};

                    return StreamBuilder<List<RoundCategorySettingRow>>(
                      stream: widget.toyRepository.watchRoundCategorySettings(),
                      builder: (context, snapshot) {
                        final rows =
                            snapshot.data ?? const <RoundCategorySettingRow>[];
                        _latestRows = rows;

                        _initializeDraftIfNeeded(rows, availableCounts);
                        _syncDraftWithAvailability(rows, availableCounts);

                        final availableTotal = rows.fold<int>(
                          0,
                          (sum, row) =>
                              sum + (availableCounts[row.category.id] ?? 0),
                        );

                        final totalSelected = _currentTotal();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Composi\u00e7\u00e3o da rodada',
                              style: textTheme.titleSmall,
                            ),
                            const SizedBox(height: UiTokens.spacingSm),
                            Text(
                              'Disponíveis no catálogo: $availableTotal',
                              style: textTheme.bodySmall,
                            ),
                            const SizedBox(height: UiTokens.spacingXs),
                            Text(
                              'Total desta rodada: $totalSelected brinquedos',
                              style: textTheme.bodySmall,
                            ),
                            const SizedBox(height: UiTokens.spacingMd),
                            if (rows.isEmpty)
                              const Text('Nenhuma categoria encontrada.')
                            else
                              ...rows.map((row) {
                                final id = row.category.id;
                                final included =
                                    _includedDraft[id] ?? row.isIncluded;
                                final quota = _quotaDraft[id] ??
                                    (row.quota < 0 ? 0 : row.quota);
                                final available = availableCounts[id] ?? 0;

                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: UiTokens.spacingSm,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(
                                      UiTokens.spacingMd,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(
                                        UiTokens.radiusLg,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                row.category.name,
                                                style: textTheme.bodyMedium
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: UiTokens.spacingXs,
                                              ),
                                              Text(
                                                !row.category.isActive
                                                    ? 'Disponíveis: $available - Categoria inativa'
                                                    : 'Disponíveis: $available',
                                                style: textTheme.bodySmall,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                            width: UiTokens.spacingSm),
                                        InkWell(
                                          borderRadius:
                                              BorderRadius.circular(999),
                                          onTap: () =>
                                              _selectQuota(row, available),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: included
                                                  ? UiTokens.primarySoft
                                                  : Theme.of(context)
                                                      .disabledColor
                                                      .withValues(alpha: 0.18),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              '$quota',
                                              style: textTheme.labelMedium
                                                  ?.copyWith(
                                                color: included
                                                    ? UiTokens.primaryStrong
                                                    : UiTokens.textSecondary,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: UiTokens.s),
                                        Switch(
                                          value: included,
                                          onChanged: (value) =>
                                              _onSwitchChanged(
                                            row,
                                            value,
                                            available,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            const SizedBox(height: UiTokens.spacingSm),
                            FilledButton(
                              onPressed: _save,
                              child: const Text('Salvar configurações'),
                            ),
                            const SizedBox(height: UiTokens.spacingSm),
                            OutlinedButton(
                              onPressed: _restoreRoundDefaults,
                              child: const Text('Restaurar padrão'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UiTokens.radiusLg),
        child: Ink(
          padding: const EdgeInsets.all(UiTokens.spacingMd),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(UiTokens.radiusLg),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: UiTokens.primarySoft,
                  borderRadius: BorderRadius.circular(UiTokens.radiusLg),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: 20,
                  color: UiTokens.primaryStrong,
                ),
              ),
              const SizedBox(width: UiTokens.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: UiTokens.spacingXs),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

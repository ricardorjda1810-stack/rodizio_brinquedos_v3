import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/demo/demo_data_loader.dart';
import 'package:rodizio_brinquedos_v3/domain/child_age/child_age_range.dart';
import 'package:rodizio_brinquedos_v3/features/paywall/paywall_page.dart';
import 'package:rodizio_brinquedos_v3/l10n/app_localizations.dart';
import 'package:rodizio_brinquedos_v3/services/paywall_platform.dart';
import 'package:rodizio_brinquedos_v3/services/age_preset_service.dart';
import 'package:rodizio_brinquedos_v3/services/purchase_service.dart';
import 'package:rodizio_brinquedos_v3/ui/categories_manage_page.dart';
import 'package:rodizio_brinquedos_v3/ui/locations_manage_page.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_bottom_navigation.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_surface_card.dart';

const String _settingsPrivacyPolicyUrl =
    'https://first-lime-7b2.notion.site/Pol-tica-de-Privacidade-Rod-zio-de-Brinquedos-d40b83abf35f4d089e1ae5f46423b4ca?pvs=143';
const String _settingsTermsOfUseUrl =
    'https://first-lime-7b2.notion.site/Termos-de-Uso-Rod-zio-de-Brinquedos-34c496b60a598015ba29cb3322ebfbc6?pvs=143';
const String _settingsAppVersionLabel = '1.0.5+93';

class SettingsPage extends StatefulWidget {
  final SettingsRepository settingsRepository;
  final ToyRepository toyRepository;
  final PurchaseService purchaseService;
  final VoidCallback? onOpenHomeTab;
  final VoidCallback? onOpenRoundTab;
  final VoidCallback? onOpenWeeklyPlanning;
  final VoidCallback? onOpenToysTab;
  final VoidCallback? onOpenBoxesTab;

  const SettingsPage({
    super.key,
    required this.settingsRepository,
    required this.toyRepository,
    required this.purchaseService,
    this.onOpenHomeTab,
    this.onOpenRoundTab,
    this.onOpenWeeklyPlanning,
    this.onOpenToysTab,
    this.onOpenBoxesTab,
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
          topNavigationIndex: 4,
          onOpenHomeTab: widget.onOpenHomeTab,
          onOpenRoundTab: widget.onOpenRoundTab,
          onOpenWeeklyPlanning: widget.onOpenWeeklyPlanning,
          onOpenToysTab: widget.onOpenToysTab,
          onOpenBoxesTab: widget.onOpenBoxesTab,
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
          topNavigationIndex: 4,
          onOpenHomeTab: widget.onOpenHomeTab,
          onOpenRoundTab: widget.onOpenRoundTab,
          onOpenWeeklyPlanning: widget.onOpenWeeklyPlanning,
          onOpenToysTab: widget.onOpenToysTab,
          onOpenBoxesTab: widget.onOpenBoxesTab,
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

  Future<void> _selectChildAgeRange(ChildAgeRange selected) async {
    final service = _agePresetService();
    if (service == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Banco local indisponivel.')),
      );
      return;
    }

    await service.saveAgeRangeOnly(selected);
    if (!mounted) return;
    await _confirmAndApplyAgePreset(service, selected);
  }

  Future<void> _confirmAndApplyAgePreset(
    AgePresetService service,
    ChildAgeRange selected,
  ) async {
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

  Future<void> _applySelectedAgePreset() async {
    final service = _agePresetService();
    if (service == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Banco local indisponivel.')),
      );
      return;
    }

    final selected = widget.settingsRepository.childAgeRange;
    if (selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escolha uma faixa etária antes de aplicar.'),
        ),
      );
      return;
    }

    await _confirmAndApplyAgePreset(service, selected);
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
    await _selectChildAgeRange(selected);
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

  void _closeSettingsRoute() {
    Navigator.of(context).maybePop();
  }

  Future<void> _changeRoundSize(int delta) async {
    final next =
        (widget.settingsRepository.roundSize + delta).clamp(1, 50).toInt();
    if (next == widget.settingsRepository.roundSize) return;
    await widget.settingsRepository.setRoundSize(next);
    if (!mounted) return;
    setState(() {});
  }

  void _changeCategoryQuota(
    RoundCategorySettingRow row,
    int availableCount,
    int delta,
  ) {
    final id = row.category.id;
    final current = _quotaDraft[id] ?? (row.quota < 0 ? 0 : row.quota);
    final maxSelectable = _maxSelectableForRow(row, {id: availableCount});
    final next = (current + delta).clamp(0, maxSelectable).toInt();
    if (next == current) return;

    setState(() {
      _quotaDraft[id] = next;
      if (next > 0) {
        _includedDraft[id] = true;
      }
    });
  }

  String _compactAgeLabel(ChildAgeRange range) {
    switch (range) {
      case ChildAgeRange.months0To6:
        return '0–6m';
      case ChildAgeRange.months6To12:
        return '6–12m';
      case ChildAgeRange.years1To2:
        return '1–2a';
      case ChildAgeRange.years2To3:
        return '2–3a';
      case ChildAgeRange.years3To5:
        return '3–5a';
      case ChildAgeRange.years5To7:
        return '5–7a';
    }
  }

  Future<void> _openExternalLink(String url) async {
    final uri = Uri.parse(url);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (opened || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Não foi possível abrir o link.')),
    );
  }

  Widget _buildIpadTopNavigation() {
    return AppTopNavigation(
      currentIndex: 4,
      onHomeTap: widget.onOpenHomeTab ?? _closeSettingsRoute,
      onRoundTap: widget.onOpenRoundTab ?? _closeSettingsRoute,
      onWeeklyPlanningTap: widget.onOpenWeeklyPlanning ?? _closeSettingsRoute,
      onToysTap: widget.onOpenToysTab ?? _closeSettingsRoute,
      onBoxesTap: widget.onOpenBoxesTab ?? _closeSettingsRoute,
      onSettingsTap: () {},
    );
  }

  Widget _buildIpadLayout(TextTheme textTheme) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 28;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F0),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1032),
            child: ListView(
              padding: EdgeInsets.fromLTRB(24, 18, 24, bottomPadding),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildIpadTopNavigation(),
                const SizedBox(height: 18),
                _buildIpadHeader(textTheme),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final useSingleColumn = constraints.maxWidth < 900;
                    final gap = constraints.maxWidth >= 980 ? 22.0 : 18.0;
                    final leftWidth = (constraints.maxWidth - gap) * 0.58;
                    final primaryColumn = Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildIpadChildAgeCard(textTheme),
                        const SizedBox(height: 16),
                        _buildIpadRoundCard(textTheme),
                      ],
                    );
                    final secondaryColumn = Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildIpadPremiumCard(textTheme),
                        const SizedBox(height: 16),
                        _buildIpadExampleToysCard(textTheme),
                        if (DemoDataLoader.controlsEnabled) ...[
                          const SizedBox(height: 16),
                          _buildIpadDemoDataCard(textTheme),
                        ],
                        const SizedBox(height: 16),
                        _buildIpadAboutCard(textTheme),
                      ],
                    );

                    if (useSingleColumn) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          primaryColumn,
                          SizedBox(height: gap),
                          secondaryColumn,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: leftWidth.clamp(520.0, 620.0),
                          child: primaryColumn,
                        ),
                        SizedBox(width: gap),
                        Expanded(child: secondaryColumn),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIpadHeader(TextTheme textTheme) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFA51E), Color(0xFFF97316)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33F97316),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.settings_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.appNameUpper,
                  style: textTheme.labelMedium?.copyWith(
                    color: const Color(0xFFF97316),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.l10n.settings,
                  style: textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFF25180A),
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.isEn
                      ? 'Adjust age, rotation, subscription, and app preferences.'
                      : 'Ajuste idade, rodízio, assinatura e preferências do app.',
                  style: textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF6B4F30),
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

  Widget _buildIpadChildAgeCard(TextTheme textTheme) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(24),
      child: StreamBuilder<ChildAgeRange?>(
        stream: widget.settingsRepository.watchChildAgeRange(),
        initialData: widget.settingsRepository.childAgeRange,
        builder: (context, snapshot) {
          final selected = snapshot.data;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IpadSettingsSectionHeader(
                icon: Icons.child_care_rounded,
                title: context.l10n.isEn ? 'Child and age' : 'Criança e idade',
                subtitle: context.l10n.isEn
                    ? 'The age range helps the app balance activities.'
                    : 'A faixa etária ajuda o app a equilibrar estímulos.',
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final range in ChildAgeRange.values)
                    ChoiceChip(
                      label: Text(_compactAgeLabel(range)),
                      selected: selected == range,
                      showCheckmark: false,
                      selectedColor: const Color(0xFFF97316),
                      backgroundColor: const Color(0xFFFFF7ED),
                      side: BorderSide(
                        color: selected == range
                            ? const Color(0xFFF97316)
                            : const Color(0xFFF3E2D0),
                      ),
                      labelStyle: textTheme.labelLarge?.copyWith(
                        color: selected == range
                            ? Colors.white
                            : const Color(0xFF6B4F30),
                        fontWeight: FontWeight.w800,
                      ),
                      onSelected: (_) => _selectChildAgeRange(range),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: selected == null
                        ? const Color(0xFFFFD7AA)
                        : const Color(0xFFFED7AA),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      selected == null
                          ? Icons.info_outline_rounded
                          : Icons.check_circle_outline_rounded,
                      color: const Color(0xFFF97316),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selected == null
                            ? (context.l10n.isEn
                                ? 'Choose an age range to enable recommendations.'
                                : 'Escolha uma faixa etária para ativar recomendações.')
                            : (context.l10n.isEn
                                ? 'Set for ${selected.label} · Suggestions adjust automatically'
                                : 'Configurado para ${selected.label} · Sugestões ajustadas automaticamente'),
                        style: textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF6B4F30),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildIpadRoundCard(TextTheme textTheme) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(24),
      child: StreamBuilder<Map<String, int>>(
        stream: widget.toyRepository.watchAvailableToyCountByCategory(),
        builder: (context, availableSnapshot) {
          final availableCounts =
              availableSnapshot.data ?? const <String, int>{};

          return StreamBuilder<List<RoundCategorySettingRow>>(
            stream: widget.toyRepository.watchRoundCategorySettings(),
            builder: (context, snapshot) {
              final rows = snapshot.data ?? const <RoundCategorySettingRow>[];
              _latestRows = rows;

              _initializeDraftIfNeeded(rows, availableCounts);
              _syncDraftWithAvailability(rows, availableCounts);

              final availableTotal = rows.fold<int>(
                0,
                (sum, row) => sum + (availableCounts[row.category.id] ?? 0),
              );
              final totalSelected = _currentTotal();
              final activeRows = rows.where((row) {
                final id = row.category.id;
                return _includedDraft[id] ?? row.isIncluded;
              }).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _IpadSettingsSectionHeader(
                    icon: Icons.tune_rounded,
                    title: context.l10n.isEn ? 'Rotation' : 'Rodízio',
                    subtitle: context.l10n.isEn
                        ? 'How rotations are assembled.'
                        : 'Como as rodadas são montadas.',
                  ),
                  const SizedBox(height: 20),
                  StreamBuilder<int>(
                    stream: widget.settingsRepository.watchRoundSize(),
                    initialData: widget.settingsRepository.roundSize,
                    builder: (context, roundSizeSnapshot) {
                      final roundSize = roundSizeSnapshot.data ??
                          widget.settingsRepository.roundSize;
                      return _IpadRoundSizeControl(
                        value: roundSize,
                        effectiveTotal: totalSelected,
                        onDecrease: () => _changeRoundSize(-1),
                        onIncrease: () => _changeRoundSize(1),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _IpadSettingsMetric(
                          label:
                              context.l10n.isEn ? 'Available' : 'Disponíveis',
                          value: '$availableTotal',
                          color: const Color(0xFFF97316),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _IpadSettingsMetric(
                          label:
                              context.l10n.isEn ? 'In rotation' : 'Na rodada',
                          value: '$totalSelected',
                          color: const Color(0xFF7C3AED),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    context.l10n.isEn
                        ? 'Active categories'
                        : 'Categorias ativas',
                    style: textTheme.titleSmall?.copyWith(
                      color: const Color(0xFF25180A),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (rows.isEmpty)
                    const Text('Nenhuma categoria encontrada.')
                  else ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final row in activeRows)
                          _IpadSettingsPill(
                            label: context.l10n.categoryName(row.category.name),
                            icon: Icons.check_rounded,
                          ),
                        if (activeRows.isEmpty)
                          const _IpadSettingsPill(
                            label: 'Nenhuma categoria ativa',
                            icon: Icons.info_outline_rounded,
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    for (final row in rows)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildIpadCategoryQuotaRow(
                          textTheme: textTheme,
                          row: row,
                          available: availableCounts[row.category.id] ?? 0,
                        ),
                      ),
                  ],
                  const SizedBox(height: 10),
                  _buildIpadWeekendPresetInfo(textTheme),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _restoreRoundDefaults,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Restaurar padrão'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _save,
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('Salvar rodízio'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFF97316),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonalIcon(
                    onPressed: _applySelectedAgePreset,
                    icon: const Icon(Icons.auto_awesome_outlined),
                    label: const Text('Aplicar configuração recomendada'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFFEDD5),
                      foregroundColor: const Color(0xFFC2410C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _IpadSettingsActionButton(
                          icon: Icons.category_outlined,
                          label: 'Categorias',
                          onTap: _openCategories,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _IpadSettingsActionButton(
                          icon: Icons.place_outlined,
                          label: 'Locais',
                          onTap: _openLocations,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildIpadCategoryQuotaRow({
    required TextTheme textTheme,
    required RoundCategorySettingRow row,
    required int available,
  }) {
    final id = row.category.id;
    final included = _includedDraft[id] ?? row.isIncluded;
    final quota = _quotaDraft[id] ?? (row.quota < 0 ? 0 : row.quota);
    final canDecrease = quota > 0;
    final canIncrease = quota < available;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF3E2D0)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color:
                  included ? const Color(0xFFFFEDD5) : const Color(0xFFF4EDE5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.category_outlined,
              color:
                  included ? const Color(0xFFF97316) : const Color(0xFFA8896A),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.categoryName(row.category.name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF25180A),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  !row.category.isActive
                      ? (context.l10n.isEn
                          ? 'Available: $available · Inactive category'
                          : 'Disponíveis: $available · Categoria inativa')
                      : (context.l10n.isEn
                          ? 'Available: $available'
                          : 'Disponíveis: $available'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF8A6B4B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _IpadSettingsIconButton(
            icon: Icons.remove_rounded,
            onTap: canDecrease
                ? () => _changeCategoryQuota(row, available, -1)
                : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => _selectQuota(row, available),
              child: Container(
                width: 42,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFFFD7AA)),
                ),
                child: Text(
                  '$quota',
                  style: textTheme.titleSmall?.copyWith(
                    color: const Color(0xFFF97316),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          _IpadSettingsIconButton(
            icon: Icons.add_rounded,
            onTap: canIncrease
                ? () => _changeCategoryQuota(row, available, 1)
                : null,
          ),
          const SizedBox(width: 8),
          Switch(
            value: included,
            activeThumbColor: const Color(0xFFF97316),
            onChanged: (value) => _onSwitchChanged(row, value, available),
          ),
        ],
      ),
    );
  }

  Widget _buildIpadWeekendPresetInfo(TextTheme textTheme) {
    return StreamBuilder<ChildAgeRange?>(
      stream: widget.settingsRepository.watchChildAgeRange(),
      initialData: widget.settingsRepository.childAgeRange,
      builder: (context, snapshot) {
        final ageRange = snapshot.data;
        final text = ageRange == null
            ? 'Escolha uma faixa etária para ativar sugestão de fim de semana.'
            : 'Fim de semana +1 · Preset de ${ageRange.label} adiciona variedade no sábado e domingo.';
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFFFD7AA)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.weekend_outlined,
                color: Color(0xFFF97316),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6B4F30),
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIpadPremiumCard(TextTheme textTheme) {
    final l10n = context.l10n;
    final isPremium = widget.purchaseService.isPremium;
    final subtitle = isPremium
        ? (l10n.isEn
            ? 'Subscription active on this device.'
            : 'Assinatura ativa neste aparelho.')
        : isPaywallEnabledForCurrentPlatform
            ? (l10n.isEn
                ? 'Choose a plan to keep using the app.'
                : 'Escolha um plano para continuar usando o app.')
            : (l10n.isEn
                ? 'Subscription coming soon. Features are available for now.'
                : 'Assinatura em breve. Recursos liberados por enquanto.');

    return AppSurfaceCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IpadSettingsSectionHeader(
            icon: Icons.workspace_premium_outlined,
            title: l10n.subscription,
            subtitle: subtitle,
          ),
          const SizedBox(height: 16),
          _IpadBenefitRow(
            label: l10n.isEn
                ? 'Continue using the full app after the trial'
                : 'Continue usando o app completo após o teste',
          ),
          const SizedBox(height: 10),
          _IpadBenefitRow(
            label: l10n.isEn
                ? 'Organize each day of the week'
                : 'Organize cada dia da semana',
          ),
          const SizedBox(height: 10),
          _IpadBenefitRow(
            label: l10n.isEn
                ? 'Adjust categories by day'
                : 'Ajuste categorias por dia',
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _openPaywall,
              icon: const Icon(Icons.workspace_premium_outlined),
              label: Text(l10n.subscription),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIpadDemoDataCard(TextTheme textTheme) {
    final controlsEnabled = DemoDataLoader.controlsEnabled;
    final disabled = !controlsEnabled || _demoActionInProgress;

    return AppSurfaceCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _IpadSettingsSectionHeader(
            icon: Icons.auto_awesome_outlined,
            title: 'Marketing / Demonstração',
            subtitle: controlsEnabled
                ? 'Prepare o simulador para screenshots.'
                : 'Disponível apenas em builds de demonstração.',
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: disabled ? null : _populateDemoData,
            icon: const Icon(Icons.auto_awesome_outlined),
            label: Text(
              _demoActionInProgress
                  ? 'Atualizando...'
                  : 'Popular dados de demonstração',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFF97316),
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: disabled ? null : _clearDemoData,
            icon: const Icon(Icons.cleaning_services_outlined),
            label: const Text('Limpar dados de demonstração'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFBE123C),
              side: const BorderSide(color: Color(0xFFFDA4AF)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIpadExampleToysCard(TextTheme textTheme) {
    final db = widget.toyRepository.db;

    return DemoExamplesSettingsSection(
      padding: const EdgeInsets.all(22),
      header: const _IpadSettingsSectionHeader(
        icon: Icons.toys_outlined,
        title: 'Dados de demonstração',
        subtitle:
            'Apaga apenas os brinquedos de demonstração. Seus brinquedos cadastrados não serão apagados.',
      ),
      countExamples: db == null
          ? () async => 0
          : () => DemoDataLoader.countExampleToys(db),
      removeExamples: db == null
          ? null
          : () async {
              await DemoDataLoader.removeExamples(db);
            },
      onRemoved: _refreshAfterExampleRemoval,
      buttonSide: const BorderSide(color: Color(0xFFFDA4AF)),
      countTextBuilder: (count) =>
          '$count brinquedos de exemplo ativos para testar o app.',
      countTextStyle: textTheme.bodySmall?.copyWith(
        color: const Color(0xFF6B4F30),
        fontWeight: FontWeight.w600,
        height: 1.35,
      ),
    );
  }

  Widget _buildIpadAboutCard(TextTheme textTheme) {
    final l10n = context.l10n;

    return AppSurfaceCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _IpadSettingsSectionHeader(
            icon: Icons.info_outline_rounded,
            title: 'Sobre',
            subtitle: 'Links, versão e preferências rápidas.',
          ),
          const SizedBox(height: 16),
          _IpadSettingsLinkRow(
            icon: Icons.privacy_tip_outlined,
            label: l10n.privacyPolicy,
            onTap: () => _openExternalLink(_settingsPrivacyPolicyUrl),
          ),
          const SizedBox(height: 10),
          _IpadSettingsLinkRow(
            icon: Icons.description_outlined,
            label: l10n.termsOfUse,
            onTap: () => _openExternalLink(_settingsTermsOfUseUrl),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFFFD7AA)),
            ),
            child: Text(
              'Versão $_settingsAppVersionLabel',
              style: textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF6B4F30),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildIpadPreferenceSwitches(textTheme),
          const SizedBox(height: 16),
          Text(
            'Rodízio de Brinquedos',
            style: textTheme.titleSmall?.copyWith(
              color: const Color(0xFF25180A),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Feito com carinho para famílias que valorizam a brincadeira equilibrada.',
            style: textTheme.bodySmall?.copyWith(
              color: const Color(0xFF8A6B4B),
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIpadPreferenceSwitches(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferências do app',
          style: textTheme.titleSmall?.copyWith(
            color: const Color(0xFF25180A),
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        StreamBuilder<bool>(
          stream: widget.settingsRepository.watchHapticEnabled(),
          initialData: widget.settingsRepository.hapticEnabled,
          builder: (context, snapshot) {
            return _IpadSettingsSwitchRow(
              title: 'Vibração',
              subtitle: 'Toques leves nas ações principais',
              value: snapshot.data ?? true,
              onChanged: widget.settingsRepository.setHapticEnabled,
            );
          },
        ),
        const SizedBox(height: 8),
        StreamBuilder<bool>(
          stream: widget.settingsRepository.watchSoundEnabled(),
          initialData: widget.settingsRepository.soundEnabled,
          builder: (context, snapshot) {
            return _IpadSettingsSwitchRow(
              title: 'Sons do app',
              subtitle: 'Feedback sonoro em eventos do app',
              value: snapshot.data ?? false,
              onChanged: widget.settingsRepository.setSoundEnabled,
            );
          },
        ),
        const SizedBox(height: 8),
        StreamBuilder<bool>(
          stream: widget.settingsRepository.watchDarkModeEnabled(),
          initialData: widget.settingsRepository.darkModeEnabled,
          builder: (context, snapshot) {
            return _IpadSettingsSwitchRow(
              title: 'Modo escuro',
              subtitle: 'Altera apenas a aparência do app',
              value: snapshot.data ?? false,
              onChanged: widget.settingsRepository.setDarkModeEnabled,
            );
          },
        ),
      ],
    );
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
                activeThumbColor: UiTokens.actionOrange,
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
                activeThumbColor: UiTokens.actionOrange,
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
                activeThumbColor: UiTokens.actionOrange,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard(TextTheme textTheme) {
    final l10n = context.l10n;
    return AppSurfaceCard(
      padding: const EdgeInsets.all(UiTokens.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.subscription,
            style: textTheme.titleSmall,
          ),
          const SizedBox(height: UiTokens.spacingSm),
          _SettingsTile(
            icon: Icons.workspace_premium_outlined,
            title: isPaywallEnabledForCurrentPlatform
                ? l10n.subscription
                : (l10n.isEn
                    ? 'Android subscription'
                    : 'Assinatura no Android'),
            subtitle: widget.purchaseService.isPremium
                ? (l10n.isEn
                    ? 'Subscription active on this device'
                    : 'Assinatura ativa neste aparelho')
                : isPaywallEnabledForCurrentPlatform
                    ? (l10n.isEn
                        ? 'Open subscription screen'
                        : 'Abrir tela de assinatura')
                    : (l10n.isEn
                        ? 'Subscription coming soon. Features are available for now.'
                        : 'Assinatura em breve. Recursos liberados por enquanto.'),
            onTap: _openPaywall,
          ),
        ],
      ),
    );
  }

  Widget _buildExampleToysCard(TextTheme textTheme) {
    final db = widget.toyRepository.db;

    return DemoExamplesSettingsSection(
      padding: const EdgeInsets.all(UiTokens.spacingMd),
      countExamples: db == null
          ? () async => 0
          : () => DemoDataLoader.countExampleToys(db),
      removeExamples: db == null
          ? null
          : () async {
              await DemoDataLoader.removeExamples(db);
            },
      onRemoved: _refreshAfterExampleRemoval,
    );
  }

  Future<void> _refreshAfterExampleRemoval() async {
    await widget.settingsRepository.load();
    if (!mounted) return;
    setState(_resetRoundDrafts);
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
    final isTablet = context.usesTabletPresentation;

    if (isTablet) {
      return _buildIpadLayout(textTheme);
    }

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
                color: UiTokens.actionOrangeSoft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configura\u00e7\u00f5es do app',
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: UiTokens.spacingXs),
                    Text(
                      'Ajuste preferências e organização sem sair do fluxo.',
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
              _buildExampleToysCard(textTheme),
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
                                                context.l10n.categoryName(
                                                  row.category.name,
                                                ),
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
                                                  ? UiTokens.actionOrangeSoft
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
                                                    ? UiTokens.actionOrange
                                                    : UiTokens.textSecondary,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: UiTokens.s),
                                        Switch(
                                          value: included,
                                          activeThumbColor:
                                              UiTokens.actionOrange,
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

class DemoExamplesSettingsSection extends StatefulWidget {
  final Future<int> Function() countExamples;
  final Future<void> Function()? removeExamples;
  final Future<void> Function()? onRemoved;
  final EdgeInsetsGeometry padding;
  final BorderSide? buttonSide;
  final Widget? header;
  final String Function(int count)? countTextBuilder;
  final TextStyle? countTextStyle;

  const DemoExamplesSettingsSection({
    super.key,
    required this.countExamples,
    required this.removeExamples,
    this.onRemoved,
    this.padding = const EdgeInsets.all(UiTokens.spacingMd),
    this.buttonSide,
    this.header,
    this.countTextBuilder,
    this.countTextStyle,
  });

  @override
  State<DemoExamplesSettingsSection> createState() =>
      _DemoExamplesSettingsSectionState();
}

class _DemoExamplesSettingsSectionState
    extends State<DemoExamplesSettingsSection> {
  late Future<int> _countFuture;
  bool _actionInProgress = false;

  @override
  void initState() {
    super.initState();
    _countFuture = widget.countExamples();
  }

  @override
  void didUpdateWidget(covariant DemoExamplesSettingsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.countExamples != widget.countExamples) {
      _countFuture = widget.countExamples();
    }
  }

  Future<void> _confirmRemoveExampleToys() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remover exemplos?'),
          content: const Text(
            'Isso vai apagar apenas os brinquedos de exemplo usados para demonstração. Seus brinquedos cadastrados manualmente serão preservados.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFBE123C),
                foregroundColor: Colors.white,
              ),
              child: const Text('Remover exemplos'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _removeExampleToys();
    }
  }

  Future<void> _removeExampleToys() async {
    final removeExamples = widget.removeExamples;
    if (_actionInProgress || removeExamples == null) return;

    setState(() => _actionInProgress = true);

    try {
      await removeExamples();
      await widget.onRemoved?.call();
      if (!mounted) return;
      setState(() {
        _countFuture = widget.countExamples();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.demoExamplesRemoved)),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.removeExamplesFailure(error))),
      );
    } finally {
      if (mounted) {
        setState(() => _actionInProgress = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppSurfaceCard(
      padding: widget.padding,
      child: FutureBuilder<int>(
        future: _countFuture,
        builder: (context, snapshot) {
          final count = snapshot.data ?? 0;
          final hasExamples = count > 0;
          final disabled = _actionInProgress ||
              widget.removeExamples == null ||
              !hasExamples;
          final countText = hasExamples
              ? (widget.countTextBuilder?.call(count) ??
                  '$count brinquedos de exemplo ativos.')
              : 'Sem brinquedos de exemplo ativos.';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.header != null)
                widget.header!
              else ...[
                Text(
                  'Dados de demonstração',
                  style: textTheme.titleSmall,
                ),
                const SizedBox(height: UiTokens.spacingSm),
                Text(
                  'Apaga apenas os brinquedos de demonstração. Seus brinquedos cadastrados não serão apagados.',
                  style: textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: UiTokens.spacingSm),
              Text(
                countText,
                style: widget.countTextStyle ??
                    textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: UiTokens.spacingMd),
              OutlinedButton.icon(
                onPressed: disabled ? null : _confirmRemoveExampleToys,
                icon: const Icon(Icons.delete_outline_rounded),
                label: Text(
                  _actionInProgress
                      ? 'Atualizando...'
                      : 'Remover brinquedos de exemplo',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFBE123C),
                  side: widget.buttonSide,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _IpadSettingsSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _IpadSettingsSectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1E7),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: const Color(0xFFF97316), size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF25180A),
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6B4F30),
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IpadRoundSizeControl extends StatelessWidget {
  final int value;
  final int effectiveTotal;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _IpadRoundSizeControl({
    required this.value,
    required this.effectiveTotal,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final hasCategoryTotal = effectiveTotal > 0;
    final isSynced = !hasCategoryTotal || effectiveTotal == value;
    final helperText = isSynced
        ? (l10n.isEn
            ? 'Minimum 1 · maximum 50 toys'
            : 'Mínimo 1 · máximo 50 brinquedos')
        : (l10n.isEn
            ? 'Active categories total $effectiveTotal toys'
            : 'Categorias ativas somam $effectiveTotal brinquedos');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3E2D0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.isEn ? 'Quantity per day' : 'Quantidade por dia',
                  style: textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF25180A),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  helperText,
                  style: textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF8A6B4B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _IpadSettingsIconButton(
            icon: Icons.remove_rounded,
            onTap: value > 1 ? onDecrease : null,
          ),
          Container(
            width: 58,
            height: 46,
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFD7AA)),
            ),
            child: Text(
              '$value',
              style: textTheme.headlineSmall?.copyWith(
                color: const Color(0xFFF97316),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          _IpadSettingsIconButton(
            icon: Icons.add_rounded,
            onTap: value < 50 ? onIncrease : null,
          ),
          if (!isSynced) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFC4B5FD)),
              ),
              child: Text(
                'Total $effectiveTotal',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelMedium?.copyWith(
                  color: const Color(0xFF7C3AED),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _IpadSettingsIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _IpadSettingsIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Tooltip(
      message: icon == Icons.add_rounded ? 'Adicionar' : 'Remover',
      child: Material(
        color: enabled ? const Color(0xFFF97316) : const Color(0xFFF4EDE5),
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(
              icon,
              color: enabled ? Colors.white : const Color(0xFFC7AA8B),
            ),
          ),
        ),
      ),
    );
  }
}

class _IpadSettingsMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _IpadSettingsMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.34)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6B4F30),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _IpadSettingsPill extends StatelessWidget {
  final String label;
  final IconData icon;

  const _IpadSettingsPill({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFFFD7AA)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFFF97316)),
          const SizedBox(width: 6),
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: const Color(0xFF6B4F30),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _IpadSettingsActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _IpadSettingsActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFC2410C),
        side: const BorderSide(color: Color(0xFFFFD7AA)),
      ),
    );
  }
}

class _IpadBenefitRow extends StatelessWidget {
  final String label;

  const _IpadBenefitRow({required this.label});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 18,
            color: Color(0xFFF97316),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6B4F30),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _IpadSettingsLinkRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _IpadSettingsLinkRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBF7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF3E2D0)),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFFF97316)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF25180A),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Icon(
                Icons.open_in_new_rounded,
                size: 18,
                color: Color(0xFFA8896A),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IpadSettingsSwitchRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _IpadSettingsSwitchRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3E2D0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF25180A),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF8A6B4B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: const Color(0xFFF97316),
            onChanged: onChanged,
          ),
        ],
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
                  color: UiTokens.actionOrangeSoft,
                  borderRadius: BorderRadius.circular(UiTokens.radiusLg),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: 20,
                  color: UiTokens.actionOrange,
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

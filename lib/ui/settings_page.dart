import 'package:flutter/material.dart';

import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/ui/categories_manage_page.dart';
import 'package:rodizio_brinquedos_v3/ui/locations_manage_page.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';

class SettingsPage extends StatefulWidget {
  final SettingsRepository settingsRepository;
  final ToyRepository toyRepository;

  const SettingsPage({
    super.key,
    required this.settingsRepository,
    required this.toyRepository,
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
      const SnackBar(content: Text('Configuracoes salvas.')),
    );
  }

  void _openCategories() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            CategoriesManagePage(
          toyRepository: widget.toyRepository,
          settingsRepository: widget.settingsRepository,
        ),
      ),
    );
  }

  void _openLocations() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            LocationsManagePage(
          toyRepository: widget.toyRepository,
          settingsRepository: widget.settingsRepository,
        ),
      ),
    );
  }

  Future<void> _restoreRoundDefaults() async {
    await widget.toyRepository.restoreRoundCategoryDefaults();

    if (!mounted) return;
    setState(() {
      _draftInitialized = false;
      _includedDraft.clear();
      _quotaDraft.clear();
    });
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
                  helperText: 'Minimo 0, maximo $maxValue',
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
                          () => errorText = 'Digite um numero inteiro.');
                      return;
                    }
                    if (parsed < 0) {
                      setLocalState(() => errorText = 'O valor minimo e 0.');
                      return;
                    }
                    if (parsed > maxValue) {
                      setLocalState(
                          () => errorText = 'O valor maximo e $maxValue.');
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
                      child: Text('Nenhum disponivel nesta categoria'),
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
                      trailing:
                          currentQuota == value ? const Icon(Icons.check) : null,
                      onTap:
                          enabled ? () => Navigator.of(context).pop(value) : null,
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
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                UiTokens.m, UiTokens.m, UiTokens.m, UiTokens.s),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Gerenciar',
                style: textTheme.titleMedium,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('Gerenciar categorias'),
            subtitle: const Text('Editar, adicionar e inativar categorias'),
            onTap: _openCategories,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.place_outlined),
            title: const Text('Gerenciar locais'),
            subtitle: const Text('Editar e adicionar locais sugeridos'),
            onTap: _openLocations,
          ),
          const SizedBox(height: UiTokens.s),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(TextTheme textTheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UiTokens.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Feedback do app',
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: UiTokens.s),
            StreamBuilder<bool>(
              stream: widget.settingsRepository.watchDarkModeEnabled(),
              initialData: widget.settingsRepository.darkModeEnabled,
              builder: (context, snapshot) {
                final enabled = snapshot.data ?? false;
                return SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Modo escuro'),
                  value: enabled,
                  onChanged: widget.settingsRepository.setDarkModeEnabled,
                );
              },
            ),
            const SizedBox(height: UiTokens.s),
            StreamBuilder<bool>(
              stream: widget.settingsRepository.watchHapticEnabled(),
              initialData: widget.settingsRepository.hapticEnabled,
              builder: (context, snapshot) {
                final enabled = snapshot.data ?? true;
                return SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Vibracao (haptic)'),
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
                  value: enabled,
                  onChanged: widget.settingsRepository.setSoundEnabled,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuracoes'),
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
              _buildManageCard(textTheme),
              const SizedBox(height: UiTokens.s),
              _buildFeedbackCard(textTheme),
              const SizedBox(height: UiTokens.s),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(UiTokens.m),
                  child: StreamBuilder<Map<String, int>>(
                    stream:
                        widget.toyRepository.watchAvailableToyCountByCategory(),
                    builder: (context, availableSnapshot) {
                      final availableCounts =
                          availableSnapshot.data ?? const <String, int>{};

                      return StreamBuilder<List<RoundCategorySettingRow>>(
                        stream:
                            widget.toyRepository.watchRoundCategorySettings(),
                        builder: (context, snapshot) {
                          final rows = snapshot.data ??
                              const <RoundCategorySettingRow>[];
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
                                'Rodizio',
                                style: textTheme.titleMedium,
                              ),
                              const SizedBox(height: UiTokens.s),
                              Text(
                                'Categorias do rodizio',
                                style: textTheme.titleSmall,
                              ),
                              const SizedBox(height: UiTokens.s),
                              Text('Disponiveis no catalogo: $availableTotal'),
                              const SizedBox(height: UiTokens.xs),
                              Text(
                                  'Total desta rodada: $totalSelected brinquedos'),
                              const SizedBox(height: UiTokens.s),
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
                                  final enabledColor = Theme.of(context)
                                      .colorScheme
                                      .primaryContainer;
                                  final disabledColor = Theme.of(context)
                                      .disabledColor
                                      .withValues(alpha: 0.2);

                                  var subtitle = 'Disponiveis: $available';
                                  if (!row.category.isActive) {
                                    subtitle = '$subtitle - Categoria inativa';
                                  }

                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(row.category.name),
                                    subtitle: Text(subtitle),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InkWell(
                                          borderRadius:
                                              BorderRadius.circular(999),
                                          onTap: () =>
                                              _selectQuota(row, available),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: included
                                                  ? enabledColor
                                                  : disabledColor,
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: Text('$quota'),
                                          ),
                                        ),
                                        const SizedBox(width: UiTokens.s),
                                        Switch(
                                          value: included,
                                          onChanged: (value) =>
                                              _onSwitchChanged(
                                                  row, value, available),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              const SizedBox(height: UiTokens.s),
                              FilledButton(
                                onPressed: _save,
                                child: const Text('Salvar configuracoes'),
                              ),
                              const SizedBox(height: UiTokens.s),
                              OutlinedButton(
                                onPressed: _restoreRoundDefaults,
                                child: const Text('Restaurar padrao'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

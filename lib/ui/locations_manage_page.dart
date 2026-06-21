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

class LocationsManagePage extends StatelessWidget {
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

  const LocationsManagePage({
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

  Future<void> _remove(
      BuildContext context, LocationDefinition location) async {
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
        child: StreamBuilder<List<LocationDefinition>>(
          stream: toyRepository.watchLocations(),
          builder: (context, snapshot) {
            final locations = snapshot.data ?? const <LocationDefinition>[];
            if (snapshot.connectionState == ConnectionState.waiting &&
                locations.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return _buildIpadContent(context, locations);
          },
        ),
      ),
    );
  }

  Widget _buildIpadContent(
    BuildContext context,
    List<LocationDefinition> locations,
  ) {
    final bottomPadding = AppBottomNavigation.reservedScrollPadding(context);

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
                  icon: Icons.place_outlined,
                  title: 'Gerenciar locais',
                  subtitle:
                      'Defina os lugares da casa usados em caixas e brinquedos.',
                  primaryLabel: 'Novo local',
                  onPrimary: () => _showAddDialog(context),
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
                            child: _buildIpadLocationList(
                              context,
                              locations,
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
                                    label: 'Locais cadastrados',
                                    value: '${locations.length}',
                                    icon: Icons.place_outlined,
                                    semantic: true,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const _ManageIpadTipCard(
                                title: 'Dica',
                                message:
                                    'Prefira nomes que a fam\u00edlia reconhece sem pensar: Sala, Quarto, Estante ou Tapete.',
                              ),
                              const SizedBox(height: 16),
                              _ManageIpadActionsCard(
                                title: 'A\u00e7\u00f5es r\u00e1pidas',
                                primaryLabel: 'Novo local',
                                onPrimary: () => _showAddDialog(context),
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

  Widget _buildIpadLocationList(
    BuildContext context,
    List<LocationDefinition> locations,
  ) {
    if (locations.isEmpty) {
      return _ManageIpadEmptyPanel(
        icon: Icons.place_outlined,
        title: 'Nenhum local cadastrado',
        message:
            'Crie locais para deixar a organiza\u00e7\u00e3o da casa mais clara no cadastro das caixas e brinquedos.',
        actionLabel: 'Novo local',
        onAction: () => _showAddDialog(context),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ManageIpadSectionTitle(
          icon: Icons.place_outlined,
          title: 'Locais da casa',
          subtitle: 'Lista real usada em caixas e brinquedos sem caixa.',
        ),
        const SizedBox(height: 18),
        for (final location in locations) ...[
          _buildIpadLocationRow(context, location),
          if (location != locations.last)
            const Divider(height: 18, color: _ManageIpadPalette.border),
        ],
      ],
    );
  }

  Widget _buildIpadLocationRow(
    BuildContext context,
    LocationDefinition location,
  ) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _ManageIpadIconBox(
                icon: Icons.place_outlined, semantic: true),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: UiTokens.textBody.copyWith(
                      color: _ManageIpadPalette.text,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sugest\u00e3o usada em caixas e brinquedos sem caixa.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: UiTokens.textCaption.copyWith(
                      color: _ManageIpadPalette.textMid,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _ManageIpadMiniButton(
              tooltip: 'Editar local',
              icon: Icons.edit_outlined,
              onTap: () => _showRenameDialog(context, location),
            ),
            const SizedBox(width: 8),
            _ManageIpadMiniButton(
              tooltip: 'Remover local',
              icon: Icons.delete_outline_rounded,
              destructive: true,
              onTap: () => _remove(context, location),
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
                                  style: Theme.of(context).textTheme.titleSmall,
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:rodizio_brinquedos_v3/data/repositories/round_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/services/purchase_service.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_bottom_navigation.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_shell_header.dart';
import 'brinquedos_page.dart' as brinquedos;
import 'caixas_page.dart';
import 'rodada_page.dart';
import 'settings_page.dart';

class MainShell extends StatefulWidget {
  final ToyRepository toyRepository;
  final RoundRepository roundRepository;
  final SettingsRepository settingsRepository;
  final PurchaseService purchaseService;

  const MainShell({
    super.key,
    required this.toyRepository,
    required this.roundRepository,
    required this.settingsRepository,
    required this.purchaseService,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  String? _requestedBoxFilterId;
  int _requestedBoxFilterVersion = 0;
  static const List<String> _titles = <String>[
    'Rod\u00edzio',
    'Brinquedos',
    'Caixas',
  ];

  void _goTo(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  void _openBrinquedosForBox(String boxId) {
    setState(() {
      _requestedBoxFilterId = boxId;
      _requestedBoxFilterVersion++;
      _currentIndex = 1;
    });
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsPage(
          settingsRepository: widget.settingsRepository,
          toyRepository: widget.toyRepository,
          purchaseService: widget.purchaseService,
        ),
      ),
    );
  }

  String _currentDatePtBr() {
    return DateFormat("d 'de' MMMM 'de' y", 'pt_BR').format(DateTime.now());
  }

  Widget _buildHomeHeader() {
    return AppShellHeader(
      eyebrow: 'ROTINA DA CASA',
      title: 'Tudo pronto para brincar com calma',
      subtitle:
          'Organize a rodada do dia, acompanhe os brinquedos ativos e mantenha a casa leve para usar.',
      actions: [
        AppShellHeaderAction(
          icon: Icons.settings_outlined,
          tooltip: 'Configura\u00e7\u00f5es',
          onTap: _openSettings,
        ),
      ],
      bottom: Wrap(
        spacing: UiTokens.spacingSm,
        runSpacing: UiTokens.spacingSm,
        children: [
          _HeaderChip(
            icon: Icons.calendar_today_outlined,
            label: _currentDatePtBr(),
          ),
          const _HeaderChip(
            icon: Icons.favorite_border,
            label: 'Visual simples e acolhedor',
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildStandardAppBar(BuildContext context) {
    return AppBar(
      title: Text(_titles[_currentIndex]),
      actions: [
        IconButton(
          tooltip: 'Configura\u00e7\u00f5es',
          icon: const Icon(Icons.settings_outlined),
          onPressed: _openSettings,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UiTokens.bg,
      extendBody: false,
      appBar: _currentIndex == 0 ? null : _buildStandardAppBar(context),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHomeHeader(),
                Expanded(
                  child: RodadaPage(
                    roundRepository: widget.roundRepository,
                    toyRepository: widget.toyRepository,
                    purchaseService: widget.purchaseService,
                    onOpenRodizioTab: () => _goTo(0),
                    onOpenBrinquedosTab: () => _goTo(1),
                    onOpenSettings: _openSettings,
                  ),
                ),
              ],
            ),
          ),
          brinquedos.BrinquedosPage(
            toyRepository: widget.toyRepository,
            roundRepository: widget.roundRepository,
            settingsRepository: widget.settingsRepository,
            purchaseService: widget.purchaseService,
            onOpenRodizioTab: () => _goTo(0),
            requestedBoxFilterId: _requestedBoxFilterId,
            requestedBoxFilterVersion: _requestedBoxFilterVersion,
          ),
          CaixasPage(
            toyRepository: widget.toyRepository,
            settingsRepository: widget.settingsRepository,
            purchaseService: widget.purchaseService,
            onOpenBrinquedosForBox: _openBrinquedosForBox,
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _goTo,
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeaderChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UiTokens.spacingSm,
        vertical: UiTokens.spacingSm,
      ),
      decoration: BoxDecoration(
        color: UiTokens.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(UiTokens.radiusLg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: UiTokens.primaryStrong,
          ),
          const SizedBox(width: UiTokens.spacingXs),
          Text(
            label,
            style: UiTokens.textCaption.copyWith(
              color: UiTokens.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

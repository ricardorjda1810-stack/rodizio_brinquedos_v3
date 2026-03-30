import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:rodizio_brinquedos_v3/data/repositories/round_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'brinquedos_page.dart' as brinquedos;
import 'caixas_page.dart';
import 'rodada_page.dart';
import 'settings_page.dart';

class MainShell extends StatefulWidget {
  final ToyRepository toyRepository;
  final RoundRepository roundRepository;
  final SettingsRepository settingsRepository;

  const MainShell({
    super.key,
    required this.toyRepository,
    required this.roundRepository,
    required this.settingsRepository,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  String? _requestedBoxFilterId;
  int _requestedBoxFilterVersion = 0;
  static const List<String> _titles = <String>[
    'Rodizio',
    'Brinquedos',
    'Caixas'
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
        ),
      ),
    );
  }

  String _currentDatePtBr() {
    return DateFormat("d 'de' MMMM 'de' y", 'pt_BR').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _currentIndex == 0
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_titles[_currentIndex]),
                  Text(
                    _currentDatePtBr(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              )
            : Text(_titles[_currentIndex]),
        actions: [
          IconButton(
            tooltip: 'Configuracoes',
            icon: const Icon(Icons.settings_outlined),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          RodadaPage(
            roundRepository: widget.roundRepository,
            toyRepository: widget.toyRepository,
            onOpenRodizioTab: () => _goTo(0),
            onOpenBrinquedosTab: () => _goTo(1),
            onOpenSettings: _openSettings,
          ),
          brinquedos.BrinquedosPage(
            toyRepository: widget.toyRepository,
            roundRepository: widget.roundRepository,
            settingsRepository: widget.settingsRepository,
            onOpenRodizioTab: () => _goTo(0),
            requestedBoxFilterId: _requestedBoxFilterId,
            requestedBoxFilterVersion: _requestedBoxFilterVersion,
          ),
          CaixasPage(
            toyRepository: widget.toyRepository,
            settingsRepository: widget.settingsRepository,
            onOpenBrinquedosForBox: _openBrinquedosForBox,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _goTo,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.toys_outlined),
            label: 'Brinquedos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Caixas',
          ),
        ],
      ),
    );
  }
}

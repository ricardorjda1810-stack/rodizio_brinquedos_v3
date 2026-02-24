// lib/app.dart
import 'package:flutter/material.dart';

import 'package:rodizio_brinquedos_v3/data/repositories/round_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'ui/main_shell.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/app_theme.dart';

class App extends StatelessWidget {
  final ToyRepository toyRepository;
  final RoundRepository roundRepository;
  final SettingsRepository settingsRepository;

  const App({
    super.key,
    required this.toyRepository,
    required this.roundRepository,
    required this.settingsRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rodízio de Brinquedos',
      theme: AppTheme.light(),
      home: MainShell(
        toyRepository: toyRepository,
        roundRepository: roundRepository,
        settingsRepository: settingsRepository,
      ),
    );
  }
}


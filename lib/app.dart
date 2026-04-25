// lib/app.dart
import 'package:flutter/material.dart';

import 'package:rodizio_brinquedos_v3/data/repositories/round_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/services/purchase_service.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/app_theme.dart';
import 'ui/main_shell.dart';

class App extends StatefulWidget {
  final ToyRepository toyRepository;
  final RoundRepository roundRepository;
  final SettingsRepository settingsRepository;
  final PurchaseService purchaseService;

  const App({
    super.key,
    required this.toyRepository,
    required this.roundRepository,
    required this.settingsRepository,
    required this.purchaseService,
  });

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: widget.settingsRepository.watchDarkModeEnabled(),
      initialData: widget.settingsRepository.darkModeEnabled,
      builder: (context, snapshot) {
        final isDarkMode = snapshot.data ?? false;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Rodízio de Brinquedos',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: MainShell(
            toyRepository: widget.toyRepository,
            roundRepository: widget.roundRepository,
            settingsRepository: widget.settingsRepository,
            purchaseService: widget.purchaseService,
          ),
        );
      },
    );
  }
}


// lib/app.dart
import 'package:flutter/material.dart';

import 'package:rodizio_brinquedos_v3/data/repositories/round_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/features/paywall/paywall_page.dart';
import 'package:rodizio_brinquedos_v3/l10n/app_localizations.dart';
import 'package:rodizio_brinquedos_v3/services/app_trial_service.dart';
import 'package:rodizio_brinquedos_v3/services/purchase_service.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/app_theme.dart';
import 'ui/main_shell.dart';

class App extends StatefulWidget {
  final ToyRepository toyRepository;
  final RoundRepository roundRepository;
  final SettingsRepository settingsRepository;
  final PurchaseService purchaseService;
  final AppTrialService appTrialService;

  const App({
    super.key,
    required this.toyRepository,
    required this.roundRepository,
    required this.settingsRepository,
    required this.purchaseService,
    required this.appTrialService,
  });

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    widget.purchaseService.addListener(_handleAccessChanged);
    widget.appTrialService.addListener(_handleAccessChanged);
  }

  @override
  void didUpdateWidget(covariant App oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.purchaseService != widget.purchaseService) {
      oldWidget.purchaseService.removeListener(_handleAccessChanged);
      widget.purchaseService.addListener(_handleAccessChanged);
    }
    if (oldWidget.appTrialService != widget.appTrialService) {
      oldWidget.appTrialService.removeListener(_handleAccessChanged);
      widget.appTrialService.addListener(_handleAccessChanged);
    }
  }

  @override
  void dispose() {
    widget.purchaseService.removeListener(_handleAccessChanged);
    widget.appTrialService.removeListener(_handleAccessChanged);
    super.dispose();
  }

  void _handleAccessChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final trialStatus = widget.appTrialService.status;
    final hasFullAppAccess = trialStatus.allowsFullAppAccess(
      hasActiveSubscription: widget.purchaseService.hasPremiumAccess,
    );

    return StreamBuilder<bool>(
      stream: widget.settingsRepository.watchDarkModeEnabled(),
      initialData: widget.settingsRepository.darkModeEnabled,
      builder: (context, snapshot) {
        final isDarkMode = snapshot.data ?? false;

        return MaterialApp(
          key: ValueKey(hasFullAppAccess ? 'full_app' : 'trial_expired'),
          debugShowCheckedModeBanner: false,
          title: 'Rodizio de Brinquedos',
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          builder: (context, child) {
            if (child == null ||
                MediaQuery.sizeOf(context).shortestSide < 600) {
              return child ?? const SizedBox.shrink();
            }
            return Theme(
              data: isDarkMode
                  ? AppTheme.dark(isTablet: true)
                  : AppTheme.light(isTablet: true),
              child: child,
            );
          },
          home: hasFullAppAccess
              ? MainShell(
                  toyRepository: widget.toyRepository,
                  roundRepository: widget.roundRepository,
                  settingsRepository: widget.settingsRepository,
                  purchaseService: widget.purchaseService,
                  trialStatus: trialStatus,
                  onTrialIntroAcknowledged:
                      widget.appTrialService.markIntroSeen,
                )
              : PaywallPage(
                  purchaseService: widget.purchaseService,
                  source: 'app_trial_expired',
                  blocking: true,
                ),
        );
      },
    );
  }
}

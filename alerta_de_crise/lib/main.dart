import 'package:flutter/material.dart';

import 'app_state.dart';
import 'data/repositories/mock_risk_repository.dart';
import 'data/repositories/onboarding_repository.dart';
import 'ui/calibration/calibration_page.dart';
import 'ui/guided_protocol/guided_protocol_page.dart';
import 'ui/history/history_page.dart';
import 'ui/home/home_page.dart';
import 'ui/intervention/intervention_page.dart';
import 'ui/onboarding/onboarding_page.dart';
import 'ui/research/research_page.dart';
import 'ui/settings/settings_page.dart';
import 'ui/theme/ui_tokens.dart';

void main() {
  runApp(const AlertaDeCriseApp());
}

final class AlertaDeCriseApp extends StatefulWidget {
  const AlertaDeCriseApp({super.key});

  @override
  State<AlertaDeCriseApp> createState() => _AlertaDeCriseAppState();
}

final class _AlertaDeCriseAppState extends State<AlertaDeCriseApp> {
  late final AppState _appState = AppState.fromRepository(
    const MockRiskRepository(),
  );
  late final Future<bool> _onboardingSeenFuture = const OnboardingRepository()
      .hasSeenOnboarding();

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      appState: _appState,
      child: FutureBuilder<bool>(
        future: _onboardingSeenFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return MaterialApp(
              title: 'Alerta de Crise',
              debugShowCheckedModeBanner: false,
              theme: _buildTheme(),
              home: const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          return MaterialApp(
            title: 'Alerta de Crise',
            debugShowCheckedModeBanner: false,
            theme: _buildTheme(),
            home: snapshot.data! ? const HomePage() : const OnboardingPage(),
            onGenerateRoute: _generateRoute,
          );
        },
      ),
    );
  }

  Route<void> _generateRoute(RouteSettings settings) {
    final page = switch (settings.name) {
      '/' => const HomePage(),
      '/home' => const HomePage(),
      '/onboarding' => const OnboardingPage(),
      '/intervention' => const InterventionPage(),
      '/history' => const HistoryPage(),
      '/settings' => const SettingsPage(),
      '/research' => const ResearchPage(),
      '/guided-protocol' => const GuidedProtocolPage(),
      '/calibration' => const CalibrationPage(),
      _ => const HomePage(),
    };

    return MaterialPageRoute<void>(builder: (_) => page, settings: settings);
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: UiTokens.primary,
        primary: UiTokens.primary,
        secondary: UiTokens.secondary,
        surface: UiTokens.card,
        error: UiTokens.danger,
      ),
      scaffoldBackgroundColor: UiTokens.bg,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: UiTokens.bg,
        foregroundColor: UiTokens.text,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: UiTokens.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiTokens.radiusCard),
          side: const BorderSide(color: UiTokens.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: UiTokens.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UiTokens.radiusButton),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: UiTokens.primary,
          side: const BorderSide(color: UiTokens.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UiTokens.radiusButton),
          ),
        ),
      ),
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: UiTokens.text,
        displayColor: UiTokens.text,
      ),
    );
  }
}

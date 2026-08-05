import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/round_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/l10n/app_localizations.dart';
import 'package:rodizio_brinquedos_v3/services/app_trial_service.dart';
import 'package:rodizio_brinquedos_v3/services/purchase_service.dart';
import 'package:rodizio_brinquedos_v3/ui/main_shell.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/app_theme.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_bottom_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
  });

  const viewports = <_HomeViewport>[
    _HomeViewport('SM-T735 paisagem', Size(1280, 800)),
    _HomeViewport('tablet Android retrato', Size(800, 1280)),
    _HomeViewport('celular retrato', Size(390, 844)),
    _HomeViewport('celular paisagem', Size(844, 390)),
    _HomeViewport('iPad grande paisagem', Size(1366, 1024)),
  ];

  for (final viewport in viewports) {
    testWidgets(
      'Home rola ate o ultimo conteudo em ${viewport.label}',
      (tester) async {
        final harness = await _HomeHarness.create();
        try {
          await _pumpHome(tester, harness: harness, viewport: viewport.size);

          final tablet = viewport.size.shortestSide >= 600;
          final scrollView = find.byKey(
            ValueKey(
              tablet ? 'home-tablet-scroll-view' : 'home-mobile-scroll-view',
            ),
          );
          final finalContent = find.byKey(
            ValueKey(
              tablet
                  ? 'home-tablet-final-content'
                  : 'home-mobile-final-content',
            ),
          );

          expect(scrollView, findsOneWidget);
          expect(tester.takeException(), isNull);

          final verticalScrollable = find.descendant(
            of: scrollView,
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Scrollable &&
                  axisDirectionToAxis(widget.axisDirection) == Axis.vertical &&
                  widget.physics is! NeverScrollableScrollPhysics,
            ),
          );
          expect(verticalScrollable, findsOneWidget);

          final position = tester.state<ScrollableState>(verticalScrollable);
          final offsetBefore = position.position.pixels;
          if (position.position.maxScrollExtent > 0) {
            await tester.drag(scrollView, const Offset(0, -300));
            await tester.pump(const Duration(milliseconds: 300));
            expect(position.position.pixels, greaterThan(offsetBefore));
          }

          await tester.scrollUntilVisible(
            finalContent,
            500,
            scrollable: verticalScrollable,
          );
          await tester.pump(const Duration(milliseconds: 300));

          expect(finalContent, findsOneWidget);
          expect(tester.takeException(), isNull);
          expect(
            tester.getBottomRight(finalContent).dy,
            lessThanOrEqualTo(viewport.size.height),
          );

          if (!tablet) {
            final navigation = find.byType(AppBottomNavigation);
            expect(navigation, findsOneWidget);
            expect(
              tester.getBottomRight(finalContent).dy,
              lessThanOrEqualTo(tester.getTopLeft(navigation).dy),
            );
          }
        } finally {
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump();
          harness.dispose();
        }
      },
    );
  }

  testWidgets('navegacao inferior permanece visivel e funcional', (
    tester,
  ) async {
    final harness = await _HomeHarness.create();
    try {
      await _pumpHome(
        tester,
        harness: harness,
        viewport: const Size(390, 844),
      );

      final navigation = find.byType(AppBottomNavigation);
      expect(navigation, findsOneWidget);
      expect(
        tester
            .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
            .currentIndex,
        0,
      );

      await tester.tap(find.byIcon(Icons.toys_outlined));
      await tester.pump();

      expect(navigation, findsOneWidget);
      expect(
        tester
            .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
            .currentIndex,
        1,
      );
      expect(tester.takeException(), isNull);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      harness.dispose();
    }
  });
}

Future<void> _pumpHome(
  WidgetTester tester, {
  required _HomeHarness harness,
  required Size viewport,
}) async {
  tester.view.physicalSize = viewport;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('pt', 'BR'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.light(isTablet: viewport.shortestSide >= 600),
      home: MainShell(
        toyRepository: harness.toyRepository,
        roundRepository: harness.roundRepository,
        settingsRepository: harness.settingsRepository,
        purchaseService: harness.purchaseService,
        trialStatus: AppTrialStatus.empty(DateTime(2026, 8, 5)),
        onTrialIntroAcknowledged: () async {},
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(seconds: 1));
}

class _HomeHarness {
  final SettingsRepository settingsRepository;
  final ToyRepository toyRepository;
  final RoundRepository roundRepository;
  final PurchaseService purchaseService;

  const _HomeHarness({
    required this.settingsRepository,
    required this.toyRepository,
    required this.roundRepository,
    required this.purchaseService,
  });

  static Future<_HomeHarness> create() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final settingsRepository = SettingsRepository();
    final toyRepository = ToyRepository(null);
    final roundRepository = _HomeTestRoundRepository();

    return _HomeHarness(
      settingsRepository: settingsRepository,
      toyRepository: toyRepository,
      roundRepository: roundRepository,
      purchaseService: PurchaseService.forTesting(
        preferences: preferences,
        paywallEnabled: false,
      ),
    );
  }

  void dispose() {
    purchaseService.dispose();
    settingsRepository.dispose();
  }
}

class _HomeTestRoundRepository extends RoundRepository {
  _HomeTestRoundRepository() : super(null);

  @override
  Future<List<Toy>> suggestRoundForToday() async => const <Toy>[];
}

class _HomeViewport {
  final String label;
  final Size size;

  const _HomeViewport(this.label, this.size);
}

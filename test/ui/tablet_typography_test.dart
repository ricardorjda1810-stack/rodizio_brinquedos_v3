import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rodizio_brinquedos_v3/l10n/app_localizations.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/app_theme.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_bottom_navigation.dart';

void main() {
  test('tablet typography preserves the hierarchy and mobile token sizes', () {
    expect(AppTypography.mobile.pageTitle, UiTokens.textTitle);
    expect(AppTypography.mobile.sectionTitle, UiTokens.textSectionTitle);
    expect(AppTypography.mobile.body, UiTokens.textBody);
    expect(AppTypography.mobile.caption, UiTokens.textCaption);
    expect(AppTypography.mobile.micro, UiTokens.textMicro);
    expect(AppTypography.mobile.button, UiTokens.textButton);

    const tablet = AppTypography.tablet;
    expect(
      tablet.pageTitle.fontSize,
      greaterThan(tablet.sectionTitle.fontSize!),
    );
    expect(tablet.sectionTitle.fontSize, greaterThan(tablet.body.fontSize!));
    expect(tablet.body.fontSize, greaterThan(tablet.caption.fontSize!));
    expect(tablet.caption.fontSize, greaterThan(tablet.micro.fontSize!));
    expect(tablet.navigation.fontSize, 15);
  });

  for (final locale in const [Locale('pt', 'BR'), Locale('en', 'US')]) {
    for (final viewport in const [
      Size(744, 1133),
      Size(1133, 744),
      Size(834, 1194),
      Size(1194, 834),
      Size(1024, 1366),
      Size(1366, 1024),
    ]) {
      testWidgets(
        'top navigation fits ${locale.toLanguageTag()} at $viewport',
        (tester) async {
          await tester.binding.setSurfaceSize(viewport);
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await tester.pumpWidget(
            MaterialApp(
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              theme: AppTheme.light(isTablet: true),
              home: Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(24),
                  child: AppTopNavigation(
                    currentIndex: 0,
                    onHomeTap: () {},
                    onRoundTap: () {},
                    onWeeklyPlanningTap: () {},
                    onToysTap: () {},
                    onBoxesTap: () {},
                    onSettingsTap: () {},
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
          expect(find.byType(AppTopNavigation), findsOneWidget);
        },
      );
    }
  }

  testWidgets('tablet navigation honors accessibility text scaling', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(744, 1133));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt', 'BR'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.light(isTablet: true),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: AppTopNavigation(
              currentIndex: 0,
              onHomeTap: () {},
              onRoundTap: () {},
              onWeeklyPlanningTap: () {},
              onToysTap: () {},
              onBoxesTap: () {},
              onSettingsTap: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      MediaQuery.textScalerOf(tester.element(find.byType(AppTopNavigation))),
      const TextScaler.linear(2),
    );
  });

  for (final scale in const [1.5, 2.0]) {
    testWidgets('iPad at ${scale}x uses bottom navigation scroll padding', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(744, 1133));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      late double reservedPadding;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('pt', 'BR'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: Builder(
            builder: (context) {
              reservedPadding = AppBottomNavigation.reservedScrollPadding(
                context,
              );
              return Scaffold(
                body: ListView(
                  padding: EdgeInsets.only(bottom: reservedPadding),
                  children: const [
                    SizedBox(height: 1300),
                    SizedBox(
                      key: Key('final-content'),
                      height: 48,
                      child: Text('Conteúdo final'),
                    ),
                  ],
                ),
                bottomNavigationBar: AppBottomNavigation(
                  currentIndex: 0,
                  onTap: (_) {},
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(reservedPadding, 104);
      expect(find.byType(AppBottomNavigation), findsOneWidget);

      await tester.scrollUntilVisible(
        find.byKey(const Key('final-content')),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      final contentBottom = tester
          .getBottomRight(find.byKey(const Key('final-content')))
          .dy;
      final navigationTop = tester
          .getTopLeft(find.byType(AppBottomNavigation))
          .dy;
      expect(contentBottom, lessThanOrEqualTo(navigationTop));
      expect(tester.takeException(), isNull);
    });
  }
}

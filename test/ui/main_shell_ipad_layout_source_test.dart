import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'iPad portrait Home uses scrollable content instead of fixed height flex',
      () {
    final source = File('lib/ui/main_shell.dart').readAsStringSync();
    final wideLayoutStart = source.indexOf('if (useTwoColumnLayout)');
    final portraitLayoutStart = source.indexOf(
      'return SingleChildScrollView(\n'
      '                                      physics: const ClampingScrollPhysics(),',
    );

    expect(wideLayoutStart, isNonNegative);
    expect(portraitLayoutStart, greaterThan(wideLayoutStart));
    expect(source, contains('fillHeight: useTwoColumnLayout'));
    expect(
        source,
        isNot(contains(
            'Expanded(\n                                          flex: 6')));
    expect(source, contains('maxLines: compactHeader ? 2 : 1'));
    expect(source, contains('maxLines: 2'));
    expect(source, contains('softWrap: true'));
  });

  test('Settings demo removal feedback is localized', () {
    final settingsSource = File('lib/ui/settings_page.dart').readAsStringSync();
    final l10nSource = File('lib/l10n/app_localizations.dart').readAsStringSync();

    expect(settingsSource, contains('context.l10n.demoExamplesRemoved'));
    expect(settingsSource, contains('context.l10n.removeExamplesFailure(error)'));
    expect(l10nSource, contains('String get demoExamplesRemoved'));
    expect(l10nSource, contains('String removeExamplesFailure(Object error)'));
  });
}

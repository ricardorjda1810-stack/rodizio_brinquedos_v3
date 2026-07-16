import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Configurações iPad usa localização para links legais', () {
    final source = File('lib/ui/settings_page.dart').readAsStringSync();

    expect(source, contains('label: l10n.privacyPolicy'));
    expect(source, contains('label: l10n.termsOfUse'));
    expect(source, isNot(contains("label: 'Política de privacidade'")));
    expect(source, isNot(contains("label: 'Termos de uso'")));
  });
}

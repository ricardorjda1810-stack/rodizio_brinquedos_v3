import 'package:flutter_test/flutter_test.dart';
import 'package:rodizio_brinquedos_v3/services/app_version_info.dart';

void main() {
  group('AppVersionInfo', () {
    test('normalizes version and build number', () {
      final info = AppVersionInfo(
        version: ' 1.0.11 ',
        buildNumber: ' 121 ',
      );

      expect(info.version, '1.0.11');
      expect(info.buildNumber, '121');
    });

    test('preserves empty metadata safely', () {
      final info = AppVersionInfo(version: '  ', buildNumber: ' ');

      expect(info.version, isEmpty);
      expect(info.buildNumber, isEmpty);
    });
  });

  group('loadAppVersionInfoSafely', () {
    test('uses the injected loader once and normalizes its result', () async {
      var calls = 0;

      final info = await loadAppVersionInfoSafely(() async {
        calls++;
        return AppVersionInfo(
          version: ' 1.0.11 ',
          buildNumber: ' 121 ',
        );
      });

      expect(calls, 1);
      expect(info.version, '1.0.11');
      expect(info.buildNumber, '121');
    });

    test('returns empty metadata when the loader throws', () async {
      final info = await loadAppVersionInfoSafely(() async {
        throw StateError('synthetic test failure');
      });

      expect(info.version, isEmpty);
      expect(info.buildNumber, isEmpty);
    });
  });
}

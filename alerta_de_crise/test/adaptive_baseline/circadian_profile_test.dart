import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/adaptive_baseline/circadian_window.dart';

void main() {
  group('CircadianWindow', () {
    test('maps daytime windows correctly', () {
      expect(
        CircadianWindow.forTimestamp(DateTime(2026, 5, 17, 6)).label,
        'earlyMorning',
      );
      expect(
        CircadianWindow.forTimestamp(DateTime(2026, 5, 17, 10)).label,
        'morning',
      );
      expect(
        CircadianWindow.forTimestamp(DateTime(2026, 5, 17, 15)).label,
        'afternoon',
      );
      expect(
        CircadianWindow.forTimestamp(DateTime(2026, 5, 17, 19)).label,
        'evening',
      );
    });

    test('maps wrapping night window correctly', () {
      expect(
        CircadianWindow.forTimestamp(DateTime(2026, 5, 17, 23)).label,
        'night',
      );
      expect(
        CircadianWindow.forTimestamp(DateTime(2026, 5, 17, 3)).label,
        'night',
      );
    });
  });
}

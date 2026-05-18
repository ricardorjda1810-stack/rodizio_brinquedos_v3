import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/debug_hub/debug_hub_models.dart';
import 'package:signalflow/debug_hub/debug_hub_sections.dart';

void main() {
  group('DebugHubItem', () {
    test('creates item and preserves labels', () {
      final item = DebugHubItem(
        label: 'Sensor Provider',
        description: 'Debug de sensores',
        builder: (_) => const SizedBox.shrink(),
      );

      expect(item.label, 'Sensor Provider');
      expect(item.description, 'Debug de sensores');
    });
  });

  group('DebugHubSection', () {
    test('creates section and counts items', () {
      final section = DebugHubSection(
        title: 'Sensors',
        items: [
          DebugHubItem(
            label: 'Sensor Provider',
            description: 'Debug de sensores',
            builder: (_) => const SizedBox.shrink(),
          ),
          DebugHubItem(
            label: 'Apple Health',
            description: 'Debug HealthKit',
            builder: (_) => const SizedBox.shrink(),
          ),
        ],
      );

      expect(section.title, 'Sensors');
      expect(section.itemCount, 2);
      expect(section.items.map((item) => item.label), [
        'Sensor Provider',
        'Apple Health',
      ]);
    });

    test('default hub sections include expected groups and item counts', () {
      final sections = SignalFlowDebugHubSections.build();

      expect(sections.map((section) => section.title), [
        'Crisis Detection',
        'Sensors',
        'Watch Sessions',
        'Replay & Research',
        'Intervention',
        'Consent & Safety',
        'Export Tools',
      ]);
      expect(
        sections.fold<int>(0, (total, section) => total + section.itemCount),
        31,
      );
    });
  });
}

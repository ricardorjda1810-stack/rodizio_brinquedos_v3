import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/replay/csv_replay_parser.dart';

void main() {
  group('CsvReplayParser', () {
    test('parses valid csv', () {
      const parser = CsvReplayParser();

      final result = parser.parseCsv(
        'timestamp,heartRate,hrv,spo2,movement,respiratoryRate\n'
        '2026-05-16T10:00:00Z,72,45,98,0.10,16\n'
        '2026-05-16T10:00:05Z,88,30,98,0.12,20',
      );

      expect(result.samples, hasLength(2));
      expect(result.samples.first.heartRateBpm, 72);
      expect(result.samples.last.hrvRmssdMs, 30);
      expect(result.validLineCount, 2);
      expect(result.invalidLineCount, 0);
    });

    test('ignores invalid lines', () {
      const parser = CsvReplayParser();

      final result = parser.parseCsv(
        'timestamp,heartRate,hrv,spo2,movement,respiratoryRate\n'
        'not-a-date,72,45,98,0.10,16\n'
        '2026-05-16T10:00:05Z,88,30,98,0.12,20\n'
        '2026-05-16T10:00:10Z,400,30,98,0.12,20',
      );

      expect(result.samples, hasLength(1));
      expect(result.samples.single.heartRateBpm, 88);
      expect(result.invalidLineCount, 2);
    });
  });
}

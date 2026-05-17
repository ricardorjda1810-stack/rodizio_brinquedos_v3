import '../core/crisis_detection/physiological_sample.dart';
import 'csv_replay_models.dart';

class CsvReplayParser {
  static const List<String> expectedHeader = [
    'timestamp',
    'heartRate',
    'hrv',
    'spo2',
    'movement',
    'respiratoryRate',
  ];

  const CsvReplayParser();

  CsvReplayParseResult parseCsv(String csv) {
    final lines = csv
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);

    if (lines.isEmpty || !_hasExpectedHeader(lines.first)) {
      return const CsvReplayParseResult(
        samples: [],
        validLineCount: 0,
        invalidLineCount: 0,
      );
    }

    final samples = <PhysiologicalSample>[];
    var invalidLineCount = 0;

    for (final line in lines.skip(1)) {
      final sample = _parseLine(line);
      if (sample == null) {
        invalidLineCount += 1;
      } else {
        samples.add(sample);
      }
    }

    return CsvReplayParseResult(
      samples: List.unmodifiable(samples),
      validLineCount: samples.length,
      invalidLineCount: invalidLineCount,
    );
  }

  bool _hasExpectedHeader(String headerLine) {
    final columns = headerLine.split(',').map((column) => column.trim());
    return columns.join(',') == expectedHeader.join(',');
  }

  PhysiologicalSample? _parseLine(String line) {
    final columns = line.split(',').map((column) => column.trim()).toList();
    if (columns.length != expectedHeader.length) {
      return null;
    }

    final timestamp = DateTime.tryParse(columns[0]);
    final heartRate = double.tryParse(columns[1]);
    final hrv = _optionalDouble(columns[2]);
    final spo2 = _optionalDouble(columns[3]);
    final movement = double.tryParse(columns[4]);
    final respiratoryRate = _optionalDouble(columns[5]);

    if (timestamp == null ||
        heartRate == null ||
        movement == null ||
        heartRate < 35 ||
        heartRate > 220 ||
        movement < 0 ||
        movement > 1 ||
        (hrv != null && (hrv <= 0 || hrv >= 250)) ||
        (spo2 != null && (spo2 < 50 || spo2 > 100)) ||
        (respiratoryRate != null &&
            (respiratoryRate < 6 || respiratoryRate > 40))) {
      return null;
    }

    return PhysiologicalSample(
      timestamp: timestamp,
      heartRateBpm: heartRate,
      hrvRmssdMs: hrv,
      spo2Percent: spo2,
      movementIntensity: movement,
      respiratoryRate: respiratoryRate,
    );
  }

  double? _optionalDouble(String value) {
    if (value.isEmpty) {
      return null;
    }

    return double.tryParse(value);
  }
}

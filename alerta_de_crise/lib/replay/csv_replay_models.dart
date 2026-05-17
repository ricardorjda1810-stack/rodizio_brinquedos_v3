import '../core/crisis_detection/physiological_sample.dart';

class CsvReplayParseResult {
  final List<PhysiologicalSample> samples;
  final int validLineCount;
  final int invalidLineCount;

  const CsvReplayParseResult({
    required this.samples,
    required this.validLineCount,
    required this.invalidLineCount,
  });
}

import 'physiological_sample.dart';
import 'physiological_sensor_provider.dart';
import 'sensor_provider_type.dart';

class CsvReplaySensorProvider implements PhysiologicalSensorProvider {
  final List<PhysiologicalSample> _samples;
  int _cursor = 0;
  PhysiologicalSample? _latestSample;

  CsvReplaySensorProvider({required List<PhysiologicalSample> samples})
    : _samples = List.unmodifiable(samples);

  @override
  SensorProviderType get type => SensorProviderType.csvReplay;

  int get cursor => _cursor;

  bool get isComplete => _cursor >= _samples.length;

  Future<PhysiologicalSample?> nextSample() async {
    if (isComplete) {
      return null;
    }

    _latestSample = _samples[_cursor];
    _cursor += 1;
    return _latestSample;
  }

  void reset() {
    _cursor = 0;
    _latestSample = null;
  }

  @override
  Future<PhysiologicalSample?> getLatestSample() async {
    return _latestSample ?? nextSample();
  }

  @override
  Future<List<PhysiologicalSample>> getRecentSamples({int limit = 30}) async {
    if (limit <= 0) {
      return const [];
    }

    return List.unmodifiable(_samples.take(limit));
  }
}

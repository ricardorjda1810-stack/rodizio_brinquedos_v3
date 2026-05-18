import '../core/crisis_detection/physiological_sample.dart';

class PhysiologicalStreamBuffer {
  final int maxSize;
  final DateTime createdAt;
  final List<PhysiologicalSample> _samples;
  DateTime updatedAt;

  PhysiologicalStreamBuffer({
    required this.maxSize,
    DateTime? createdAt,
    List<PhysiologicalSample> samples = const [],
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = createdAt ?? DateTime.now(),
       _samples = List.of(samples) {
    while (_samples.length > maxSize) {
      _samples.removeAt(0);
    }
  }

  List<PhysiologicalSample> get samples => List.unmodifiable(_samples);

  void addSample(PhysiologicalSample sample) {
    _samples.add(sample);
    while (_samples.length > maxSize) {
      removeOldest();
    }
    updatedAt = sample.timestamp;
  }

  PhysiologicalSample? removeOldest() {
    if (_samples.isEmpty) {
      return null;
    }
    final removed = _samples.removeAt(0);
    updatedAt = _samples.isEmpty ? updatedAt : _samples.last.timestamp;
    return removed;
  }

  void clear() {
    _samples.clear();
    updatedAt = DateTime.now();
  }

  PhysiologicalSample? latestSample() {
    if (_samples.isEmpty) {
      return null;
    }
    return _samples.last;
  }

  List<PhysiologicalSample> getWindow(Duration duration, {DateTime? now}) {
    final reference = now ?? latestSample()?.timestamp ?? DateTime.now();
    final start = reference.subtract(duration);
    return List.unmodifiable(
      _samples.where((sample) => !sample.timestamp.isBefore(start)),
    );
  }
}

import 'polar_h10_models.dart';
import 'polar_h10_rr_sample.dart';

class PolarH10Parser {
  const PolarH10Parser();

  PolarH10Measurement? parseHeartRateMeasurement(
    List<int> value, {
    DateTime? timestamp,
  }) {
    if (value.length < 2) {
      return null;
    }

    final flags = value[0];
    final isHeartRateUint16 = (flags & 0x01) != 0;
    final sensorContactSupported = (flags & 0x04) != 0;
    final sensorContactDetected = sensorContactSupported && (flags & 0x02) != 0;
    final hasEnergyExpended = (flags & 0x08) != 0;
    final hasRrIntervals = (flags & 0x10) != 0;

    var offset = 1;
    if (value.length <= offset) {
      return null;
    }

    final heartRate = isHeartRateUint16
        ? _readUint16(value, offset)
        : value[offset];
    offset += isHeartRateUint16 ? 2 : 1;

    if (heartRate == null || heartRate <= 0) {
      return null;
    }

    if (hasEnergyExpended) {
      offset += 2;
    }

    final now = timestamp ?? DateTime.now();
    final samples = <PolarH10RrSample>[];
    if (hasRrIntervals) {
      while (offset + 1 < value.length) {
        final rawRr = _readUint16(value, offset);
        offset += 2;
        if (rawRr == null || rawRr <= 0) {
          continue;
        }

        samples.add(
          PolarH10RrSample(
            timestamp: now,
            rrIntervalMs: rawRr * 1000 / 1024,
            heartRate: heartRate.toDouble(),
            contactDetected: sensorContactDetected,
          ),
        );
      }
    }

    return PolarH10Measurement(
      heartRate: heartRate,
      contactDetected: sensorContactDetected,
      rrSamples: List.unmodifiable(samples),
    );
  }

  int? _readUint16(List<int> value, int offset) {
    if (offset + 1 >= value.length) {
      return null;
    }

    return value[offset] | (value[offset + 1] << 8);
  }
}

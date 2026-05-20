import 'polar_h10_device.dart';
import 'polar_h10_rr_sample.dart';

enum PolarH10ConnectionStatus { disconnected, scanning, connecting, connected }

class PolarH10ScanResult {
  final List<PolarH10Device> devices;
  final DateTime scannedAt;

  const PolarH10ScanResult({required this.devices, required this.scannedAt});
}

class PolarH10Measurement {
  final int heartRate;
  final bool contactDetected;
  final List<PolarH10RrSample> rrSamples;

  const PolarH10Measurement({
    required this.heartRate,
    required this.contactDetected,
    required this.rrSamples,
  });

  PolarH10RrSample? get latestRrSample {
    if (rrSamples.isEmpty) {
      return null;
    }

    return rrSamples.last;
  }
}

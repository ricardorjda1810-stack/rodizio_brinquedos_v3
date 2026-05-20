import 'dart:async';

import '../core/crisis_detection/baseline_profile.dart';
import '../core/crisis_detection/physiological_sensor_provider.dart';
import 'physiological_stream_buffer.dart';
import 'realtime_pipeline_service.dart';
import 'realtime_stream_models.dart';

class RealtimeIngestionController {
  final PhysiologicalSensorProvider provider;
  final PhysiologicalStreamBuffer buffer;
  final RealtimePipelineService pipelineService;
  final Duration frequency;
  final BaselineProfile? baseline;
  final bool persistSnapshots;

  Timer? _timer;
  RealtimeStreamingState _state = RealtimeStreamingState.stopped;
  RealtimePipelineSnapshot? _latestSnapshot;

  RealtimeIngestionController({
    required this.provider,
    required this.buffer,
    RealtimePipelineService? pipelineService,
    this.frequency = const Duration(seconds: 5),
    this.baseline,
    this.persistSnapshots = false,
  }) : pipelineService = pipelineService ?? RealtimePipelineService();

  RealtimeStreamingState get state => _state;

  RealtimePipelineSnapshot? get latestSnapshot => _latestSnapshot;

  bool get isRunning => _state == RealtimeStreamingState.running;

  Future<void> startStreaming() async {
    if (_state == RealtimeStreamingState.running) {
      return;
    }
    _state = RealtimeStreamingState.running;
    await _tick();
    _timer?.cancel();
    _timer = Timer.periodic(frequency, (_) {
      unawaited(_tick());
    });
  }

  void stopStreaming() {
    _timer?.cancel();
    _timer = null;
    _state = RealtimeStreamingState.stopped;
  }

  void pauseStreaming() {
    if (_state != RealtimeStreamingState.running) {
      return;
    }
    _timer?.cancel();
    _timer = null;
    _state = RealtimeStreamingState.paused;
  }

  Future<void> resumeStreaming() async {
    if (_state != RealtimeStreamingState.paused) {
      return;
    }
    await startStreaming();
  }

  Future<void> _tick() async {
    if (_state != RealtimeStreamingState.running) {
      return;
    }
    final sample = await provider.getLatestSample();
    if (sample == null) {
      _latestSnapshot = pipelineService.generateRealtimeSnapshot(
        buffer: buffer,
        baseline: baseline,
        streamingState: _state,
      );
      return;
    }
    _latestSnapshot = await pipelineService.ingestSample(
      sample: sample,
      buffer: buffer,
      baseline: baseline,
      streamingState: _state,
      persist: persistSnapshots,
    );
  }
}

import 'watch_connectivity_bridge.dart';
import 'watch_connectivity_models.dart';

class WatchConnectivityService {
  final WatchConnectivityBridge _bridge;

  const WatchConnectivityService({
    WatchConnectivityBridge bridge = const PlaceholderWatchConnectivityBridge(),
  }) : _bridge = bridge;

  Future<WatchConnectivityStatus> activate() async {
    try {
      return _bridge.activate();
    } catch (error) {
      return WatchConnectivityStatus(
        state: WatchConnectivityState.unsupported,
        message: 'Watch connectivity indisponível: $error',
      );
    }
  }

  Future<bool> sendMessage(WatchConnectivityMessage message) async {
    try {
      return _bridge.sendMessage(message);
    } catch (_) {
      return false;
    }
  }
}

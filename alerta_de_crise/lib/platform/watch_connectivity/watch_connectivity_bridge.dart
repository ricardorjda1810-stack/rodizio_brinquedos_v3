import 'watch_connectivity_models.dart';

abstract class WatchConnectivityBridge {
  Future<WatchConnectivityStatus> activate();

  Future<bool> sendMessage(WatchConnectivityMessage message);
}

class PlaceholderWatchConnectivityBridge implements WatchConnectivityBridge {
  const PlaceholderWatchConnectivityBridge();

  @override
  Future<WatchConnectivityStatus> activate() async {
    return const WatchConnectivityStatus(
      state: WatchConnectivityState.inactive,
      message: 'WCSession ainda não conectada nesta camada Dart.',
    );
  }

  @override
  Future<bool> sendMessage(WatchConnectivityMessage message) async {
    return false;
  }
}

enum WatchConnectivityState { unsupported, inactive, active }

class WatchConnectivityMessage {
  final String type;
  final Map<String, Object?> payload;
  final DateTime sentAt;

  const WatchConnectivityMessage({
    required this.type,
    required this.payload,
    required this.sentAt,
  });
}

class WatchConnectivityStatus {
  final WatchConnectivityState state;
  final String message;

  const WatchConnectivityStatus({required this.state, required this.message});

  bool get isActive => state == WatchConnectivityState.active;
}

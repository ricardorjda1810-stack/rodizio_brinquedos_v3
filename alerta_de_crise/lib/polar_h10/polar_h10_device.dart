class PolarH10Device {
  final String id;
  final String name;
  final int rssi;
  final bool connectable;

  const PolarH10Device({
    required this.id,
    required this.name,
    required this.rssi,
    this.connectable = true,
  });

  String get label {
    if (name.trim().isEmpty) {
      return id;
    }

    return '$name ($id)';
  }
}

class SignalFlowMigrationInfo {
  final int fromVersion;
  final int toVersion;
  final String description;

  const SignalFlowMigrationInfo({
    required this.fromVersion,
    required this.toVersion,
    required this.description,
  });
}

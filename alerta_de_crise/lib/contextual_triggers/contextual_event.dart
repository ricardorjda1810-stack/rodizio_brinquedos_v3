enum ContextualCategory {
  work,
  social,
  sleep,
  exercise,
  caffeine,
  conflict,
  noise,
  environment,
  manual,
  unknown,
}

enum ContextualIntensity { low, medium, high }

class ContextualEvent {
  final String id;
  final DateTime timestamp;
  final ContextualCategory category;
  final String label;
  final String description;
  final ContextualIntensity intensity;
  final String source;

  const ContextualEvent({
    required this.id,
    required this.timestamp,
    required this.category,
    required this.label,
    required this.description,
    required this.intensity,
    required this.source,
  });
}

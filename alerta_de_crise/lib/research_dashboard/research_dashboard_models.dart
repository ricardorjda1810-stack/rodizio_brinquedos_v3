import 'dashboard_metrics.dart';
import 'longitudinal_insights.dart';

class ResearchDashboardSnapshot {
  final String id;
  final DateTime generatedAt;
  final DashboardMetrics metrics;
  final LongitudinalInsights insights;

  const ResearchDashboardSnapshot({
    required this.id,
    required this.generatedAt,
    required this.metrics,
    required this.insights,
  });
}

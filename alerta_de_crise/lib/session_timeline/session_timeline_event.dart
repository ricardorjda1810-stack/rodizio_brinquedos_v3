import 'physiological_event_marker.dart';

class SessionTimelineEvent {
  final String timelineId;
  final PhysiologicalEventMarker marker;

  const SessionTimelineEvent({required this.timelineId, required this.marker});
}

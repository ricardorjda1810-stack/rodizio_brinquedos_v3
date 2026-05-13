import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/risk_event.dart';

final class LocalEventRepository {
  const LocalEventRepository();

  static const _eventsKey = 'risk_events';

  Future<List<RiskEvent>> loadEvents() async {
    final preferences = await SharedPreferences.getInstance();
    final encodedEvents = preferences.getString(_eventsKey);
    if (encodedEvents == null || encodedEvents.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(encodedEvents);
    if (decoded is! List) {
      return const [];
    }

    return decoded
        .whereType<Map>()
        .map(
          (eventJson) =>
              RiskEvent.fromJson(Map<String, Object?>.from(eventJson)),
        )
        .toList();
  }

  Future<void> saveEvents(List<RiskEvent> events) async {
    final preferences = await SharedPreferences.getInstance();
    final encodedEvents = jsonEncode(
      events.map((event) => event.toJson()).toList(),
    );
    await preferences.setString(_eventsKey, encodedEvents);
  }
}

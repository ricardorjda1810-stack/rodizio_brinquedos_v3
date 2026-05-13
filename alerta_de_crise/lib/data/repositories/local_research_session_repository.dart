import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/research_session.dart';

final class LocalResearchSessionRepository {
  const LocalResearchSessionRepository();

  static const _sessionsKey = 'research_sessions';

  Future<List<ResearchSession>> loadSessions() async {
    final preferences = await SharedPreferences.getInstance();
    final encodedSessions = preferences.getString(_sessionsKey);
    if (encodedSessions == null || encodedSessions.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(encodedSessions);
    if (decoded is! List) {
      return const [];
    }

    return decoded
        .whereType<Map>()
        .map(
          (sessionJson) =>
              ResearchSession.fromJson(Map<String, Object?>.from(sessionJson)),
        )
        .toList();
  }

  Future<void> saveSessions(List<ResearchSession> sessions) async {
    final preferences = await SharedPreferences.getInstance();
    final encodedSessions = jsonEncode(
      sessions.map((session) => session.toJson()).toList(),
    );
    await preferences.setString(_sessionsKey, encodedSessions);
  }
}

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/calibration_feedback.dart';

final class LocalCalibrationRepository {
  const LocalCalibrationRepository();

  static const _feedbacksKey = 'calibration_feedbacks';

  Future<List<CalibrationFeedback>> loadFeedbacks() async {
    final preferences = await SharedPreferences.getInstance();
    final encodedFeedbacks = preferences.getString(_feedbacksKey);
    if (encodedFeedbacks == null || encodedFeedbacks.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(encodedFeedbacks);
    if (decoded is! List) {
      return const [];
    }

    return decoded
        .whereType<Map>()
        .map(
          (feedbackJson) => CalibrationFeedback.fromJson(
            Map<String, Object?>.from(feedbackJson),
          ),
        )
        .toList();
  }

  Future<void> saveFeedbacks(List<CalibrationFeedback> feedbacks) async {
    final preferences = await SharedPreferences.getInstance();
    final encodedFeedbacks = jsonEncode(
      feedbacks.map((feedback) => feedback.toJson()).toList(),
    );
    await preferences.setString(_feedbacksKey, encodedFeedbacks);
  }
}

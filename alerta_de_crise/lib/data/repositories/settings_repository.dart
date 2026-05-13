import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/sensitivity_level.dart';

final class SettingsRepository {
  const SettingsRepository();

  static const sensitivityKey = 'sensitivity';

  Future<SensitivityLevel> loadSensitivity() async {
    final preferences = await SharedPreferences.getInstance();
    final key = preferences.getString(sensitivityKey);
    if (key == null) {
      return SensitivityLevel.media;
    }

    return SensitivityLevelText.fromKey(key);
  }

  Future<void> saveSensitivity(SensitivityLevel sensitivity) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(sensitivityKey, sensitivity.key);
  }
}

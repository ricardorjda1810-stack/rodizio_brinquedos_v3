import 'package:shared_preferences/shared_preferences.dart';

final class OnboardingRepository {
  const OnboardingRepository();

  static const onboardingSeenKey = 'onboardingSeen';

  Future<bool> hasSeenOnboarding() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(onboardingSeenKey) ?? false;
  }

  Future<void> markOnboardingSeen() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(onboardingSeenKey, true);
  }

  Future<void> resetOnboarding() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(onboardingSeenKey, false);
  }
}

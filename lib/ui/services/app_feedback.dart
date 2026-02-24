import 'package:flutter/services.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';

class AppFeedback {
  final SettingsRepository settingsRepository;

  const AppFeedback(this.settingsRepository);

  Future<void> onCreateSaved({bool playSound = false}) async {
    await _haptic();
    if (playSound) {
      await _sound();
    }
  }

  Future<void> onRoundStarted() async {
    await _haptic();
    await _sound();
  }

  Future<void> onRoundEnded() async {
    await _haptic();
    await _sound();
  }

  Future<void> onDeleteConfirmed() async {
    await _haptic();
  }

  Future<void> _haptic() async {
    if (!settingsRepository.hapticEnabled) return;
    await HapticFeedback.lightImpact();
  }

  Future<void> _sound() async {
    if (!settingsRepository.soundEnabled) return;
    await SystemSound.play(SystemSoundType.click);
  }
}

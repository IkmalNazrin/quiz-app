import 'package:flutter/services.dart';
import 'package:quiz_infrastructure/quiz_infrastructure.dart';

class HapticService {
  static Future<void> light() async {
    AppLogger.d('Haptic: Light Impact');
    await HapticFeedback.lightImpact();
  }

  static Future<void> medium() async {
    AppLogger.d('Haptic: Medium Impact');
    await HapticFeedback.mediumImpact();
  }

  static Future<void> heavy() async {
    AppLogger.d('Haptic: Heavy Impact');
    await HapticFeedback.heavyImpact();
  }

  static Future<void> selection() async {
    AppLogger.d('Haptic: Selection Click');
    await HapticFeedback.selectionClick();
  }

  static Future<void> success() async {
    AppLogger.d('Haptic: Success Vibration');
    // Success is often multiple light impacts or a custom pattern
    await HapticFeedback.vibrate();
  }

  static Future<void> error() async {
    AppLogger.w('Haptic: Error Vibration');
    // Error is often multiple heavy impacts
    await HapticFeedback.vibrate();
  }
}

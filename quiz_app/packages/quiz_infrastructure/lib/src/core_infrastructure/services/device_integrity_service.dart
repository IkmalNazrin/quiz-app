import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'logger_service.dart';
import 'package:quiz_infrastructure/quiz_infrastructure.dart';

final deviceIntegrityProvider = Provider<DeviceIntegrityService>((ref) {
  return DeviceIntegrityService();
});

class DeviceIntegrityService {
  bool? _isCompromised;

  /// Returns true if the device is considered compromised (rooted, jailbroken, or emulator in release mode).
  Future<bool> isDeviceCompromised() async {
    if (_isCompromised != null) {
      return _isCompromised!;
    }

    // In debug mode, we are often running on emulators. We skip strict checks.
    if (kDebugMode) {
      AppLogger.w(
          'DeviceIntegrityService: Running in Debug Mode. Skipping strict integrity checks.');
      _isCompromised = false;
      return false;
    }

    try {
      bool jailbroken = false;
      bool developerMode = false;

      if (Platform.isAndroid || Platform.isIOS) {
        jailbroken = await FlutterJailbreakDetection.jailbroken;
        // Check if Developer mode is enabled on Android
        if (Platform.isAndroid) {
          developerMode = await FlutterJailbreakDetection.developerMode;
        }
      }

      // We consider the device compromised if it's jailbroken/rooted.
      // We log developerMode but don't strictly block it, as many Android users have it on.
      if (jailbroken) {
        AppLogger.e('SECURITY ALERT: Device is Jailbroken/Rooted.');
        _isCompromised = true;
      } else {
        if (developerMode) {
          AppLogger.w('DeviceIntegrityService: Developer Mode is enabled.');
        }

        final appCheckToken = await FirebaseAppCheck.instance.getToken();
        if (appCheckToken == null) {
          AppLogger.e('SECURITY ALERT: App Check token unavailable.');
          _isCompromised = true;
        } else {
          _isCompromised = false;
        }
      }
    } catch (e) {
      AppLogger.e('Error checking device integrity: $e');
      // ADR 026 mandates fail-closed posture for competitive integrity.
      _isCompromised = true;
    }

    return _isCompromised!;
  }
}

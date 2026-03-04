import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  /// Supabase Configuration
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// [Deprecated] Legacy Node.js Base URL.
  /// Use 10.0.2.2 for Android emulator; localhost for iOS/simulator/web/desktop.
  @Deprecated('Moving to Supabase. Use supabaseUrl instead.')
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }
}

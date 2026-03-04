import 'dart:io';

void main() async {
  final dir = Directory('packages/quiz_features/lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    String content = await file.readAsString();
    bool modified = false;

    // Fix debugPrint(\$'Some string'.toString()); -> debugPrint('Some string'.toString());
    // Wait, the actual text in the file is: debugPrint(\'Initializing GameSessionNotifier'.toString());
    // because my script had return "debugPrint(\\$args.toString());"; in a dart string, which evaluates to \$args literally.
    // Wait, it says: debugPrint(\'Initializing GameSessionNotifier'.toString());
    // Let's replace: debugPrint(\' -> debugPrint('
    if (content.contains("debugPrint(\\'")) {
      content = content.replaceAll("debugPrint(\\'", "debugPrint('");
      modified = true;
    }
    
    // Check if it's debugPrint(\$something
    if (content.contains(r"debugPrint(\$")) {
      content = content.replaceAll(r"debugPrint(\$", "debugPrint(");
      modified = true;
    }

    // Replace AppLogger.d which I missed earlier
    if (content.contains('AppLogger.d(')) {
      content = content.replaceAllMapped(RegExp(r"AppLogger\.d\((.*?)\);", dotAll: true), (m) => "debugPrint(${m.group(1)});");
      modified = true;
    }
    
    // Also there's another error I saw in the dump earlier:
    // `Undefined name 'HapticService'` for question_screen.dart:86:5. It probably didn't insert the import correctly if it matched something else.
    // Wait, fix_features_statics.dart successfully imported it.
    
    // Also there's error "Undefined name 'ref'" in game_session_provider.dart:160:24
    // Because I put `ref.read(authStateProvider)` inside a Notifier where it should be `ref.read` (which is valid for Riverpod Notifier).
    // Wait! Inside a `StateNotifier`, `ref` is accessible IF the class stores it or extends something that provides it.
    // Riverpod 2.0 `StateNotifier` DOES NOT have `ref` builtin unless passed via constructor.
    // GameSessionNotifier is a `StateNotifier`, so it doesn't have `ref`!
    // That's why `ref.read` failed!
    // To get the user ID, we need to pass it, or just use the injected authRepository!
    // I should inject the current userId, OR revert the `ref.read` replacement to something valid.

    if (modified) {
      await file.writeAsString(content);
      print('Repaired \${file.path}');
    }
  }
}

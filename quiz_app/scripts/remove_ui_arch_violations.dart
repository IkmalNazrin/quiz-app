import 'dart:io';

void main() async {
  final filesToRefactor = [
    'packages/quiz_features/lib/src/features/quiz/presentation/pages/question_screen.dart',
    'packages/quiz_features/lib/src/features/legal/presentation/pages/consent_screen.dart',
    'packages/quiz_features/lib/src/features/game/presentation/pages/lobby_screen.dart',
    'packages/quiz_features/lib/src/features/home/presentation/pages/welcome_screen.dart',
    'packages/quiz_features/lib/src/features/game/presentation/pages/join_game_screen.dart',
    'packages/quiz_features/lib/src/features/dashboard/presentation/pages/dashboard_screen.dart',
    'packages/quiz_features/lib/src/features/challenge/presentation/pages/challenge_loading_screen.dart',
    'packages/quiz_features/lib/src/features/challenge/presentation/widgets/challenge_dialog.dart',
  ];

  for (final filePath in filesToRefactor) {
    if (!File(filePath).existsSync()) continue;
    String content = await File(filePath).readAsString();

    // Remove the bad imports from UI files (they shouldn't need them)
    content = content.replaceAll("import 'package:quiz_infrastructure/quiz_infrastructure.dart';", "");
    content = content.replaceAll("import 'package:supabase_flutter/supabase_flutter.dart';", "");
    content = content.replaceAll("import 'package:supabase_flutter/supabase_flutter.dart' as supabase;", "");

    await File(filePath).writeAsString(content);
    print('Refactored UI imports in $filePath');
  }
}

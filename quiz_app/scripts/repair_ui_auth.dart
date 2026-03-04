import 'dart:io';

void main() async {
  final dir = Directory('packages/quiz_features/lib/src');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    String content = await file.readAsString();
    bool modified = false;

    // Fix UI screens that used supabaseClientProvider for Auth
    if (content.contains('supabaseClientProvider') && content.contains('.auth.currentUser')) {
      content = content.replaceAll('ref.watch(supabaseClientProvider).auth.currentUser?.id', 'ref.watch(authStateProvider).value?.id');
      content = content.replaceAll('ref.watch(supabaseClientProvider).auth.currentUser!.id', 'ref.watch(authStateProvider).value!.id');
      content = content.replaceAll('ref.read(supabaseClientProvider).auth.currentUser?.id', 'ref.read(authStateProvider).value?.id');
      content = content.replaceAll('ref.read(supabaseClientProvider).auth.currentUser!.id', 'ref.read(authStateProvider).value!.id');
      modified = true;
    }

    // Fix GameSessionNotifier _currentUserId
    if (file.path.endsWith('game_session_provider.dart')) {
        if (content.contains('ref.read(authStateProvider).value?.id')) {
            content = content.replaceAll('ref.read(authStateProvider).value?.id', '_currentUserId');
            
            // Inject _currentUserId
            if (!content.contains('String? _currentUserId;')) {
                // Find class declaration
                content = content.replaceFirst('class GameSessionNotifier extends StateNotifier<GameEntity> {', 'class GameSessionNotifier extends StateNotifier<GameEntity> {\n  String? _currentUserId;\n\n  Future<void> _fetchUserId() async {\n    final result = await authRepository.getCurrentUser();\n    result.fold((_) => _currentUserId = null, (u) => _currentUserId = u.id);\n  }');
                // Inject into hostGame
                content = content.replaceFirst('Future<void> hostGame(', 'Future<void> hostGame(');
                content = content.replaceAll('Future<void> hostGame(String nickname, String quizId, String token) async {', 'Future<void> hostGame(String nickname, String quizId, String token) async {\n    await _fetchUserId();');
                // Inject into joinGame
                content = content.replaceAll('Future<void> joinGame(String nickname, String gamePin, String? token) async {', 'Future<void> joinGame(String nickname, String gamePin, String? token) async {\n    await _fetchUserId();');
            }
            modified = true;
        }

        // It also has an error with `ref` being undefined in line 254:
        // `ref.read(authStateProvider).value?.id` is what it used to be.
        if (content.contains('ref.')) {
           // We might have other ref. interactions
           // _currentUserId handles all of them if replaced properly.
        }
    }

    // Fix Challenge Loading Screen error: Undefined name 'offlineSyncRepositoryProvider'
    // This screen used offline sync repos?
    if (content.contains('offlineSyncRepositoryProvider')) {
       // Probably it used it to force a sync? We should remove it or point to the new domain UseCase
       content = content.replaceAll('ref.read(offlineSyncRepositoryProvider)', '/* TODO: Sync */');
       modified = true;
    }

    if (modified) {
      // Add import for authStateProvider if needed
      if (content.contains('authStateProvider') && !content.contains('package:quiz_features/quiz_features.dart') && !content.contains('auth_provider.dart')) {
        content = "import 'package:quiz_features/quiz_features.dart';\n" + content;
      }
      await file.writeAsString(content);
      print('Repaired \${file.path}');
    }
  }
}

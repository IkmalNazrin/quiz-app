import 'dart:io';

void main() {
  final file = File('packages/quiz_features/lib/src/features/game/presentation/providers/game_session_provider.dart');
  var content = file.readAsStringSync();

  // Fix providers
  content = content.replaceAll('Provider<GameRealtimeService>', 'Provider<IGameRealtimeService>');
  content = content.replaceAll('Provider<ConnectivityService>', 'Provider<NetworkInfoInterface>');
  content = content.replaceAll('Provider<SyncQueueService>', 'Provider<ISyncQueueService>');

  content = content.replaceFirst(
      RegExp(r'final service = GameRealtimeService\(ref\.read\(supabaseClientProvider\)\);\s+ref\.onDispose\(\(\) => service\.dispose\(\)\);\s+return service;'),
      "throw UnimplementedError('Infrastructure injection required');"
  );
  content = content.replaceFirst(
      RegExp(r'final service = ConnectivityService\(\);\s+ref\.onDispose\(\(\) => service\.dispose\(\)\);\s+return service;'),
      "throw UnimplementedError('Infrastructure injection required');"
  );
  content = content.replaceFirst(
      RegExp(r'return SyncQueueService\(\s+ref\.read\(supabaseClientProvider\),\s+ref\.read\(connectivityServiceProvider\),\s+ref\.read\(appDatabaseProvider\),\s+\);'),
      "throw UnimplementedError('Infrastructure injection required');"
  );

  // Fix GameSessionNotifier properties
  content = content.replaceFirst(
      'final GameRealtimeService realtimeService;',
      'final IGameRealtimeService realtimeService;'
  );
  content = content.replaceFirst(
      'final ConnectivityService connectivityService;',
      'final NetworkInfoInterface connectivityService;'
  );
  content = content.replaceFirst(
      'final SyncQueueService syncQueueService;',
      'final ISyncQueueService syncQueueService;'
  );

  file.writeAsStringSync(content);
  print('Done repairing game session provider');
}

import 'dart:io';

void main() {
  // 1. SyncQueueService imports & Connectivity type
  var file = File('packages/quiz_infrastructure/lib/src/core_infrastructure/services/sync_queue_service.dart');
  var content = file.readAsStringSync();
  if (!content.contains("import 'package:quiz_domain/quiz_domain.dart';")) {
    content = "import 'package:quiz_domain/quiz_domain.dart';\n" + content;
  }
  content = content.replaceFirst(
    'final ConnectivityService _connectivityService;',
    'final NetworkInfoInterface _connectivityService;'
  );
  file.writeAsStringSync(content);

  // 2. GameRealtimeService imports
  file = File('packages/quiz_infrastructure/lib/src/core_infrastructure/services/game_realtime_service.dart');
  content = file.readAsStringSync();
  if (!content.contains("import 'package:quiz_domain/quiz_domain.dart';")) {
    content = "import 'package:quiz_domain/quiz_domain.dart';\n" + content;
  }
  file.writeAsStringSync(content);

  // 3. OnlineHostGameEngine realtime service type
  file = File('packages/quiz_infrastructure/lib/src/services/online_host_game_engine.dart');
  content = file.readAsStringSync();
  if (!content.contains("import 'package:quiz_domain/quiz_domain.dart';")) {
    content = "import 'package:quiz_domain/quiz_domain.dart';\n" + content;
  }
  content = content.replaceAll(
    'GameRealtimeService realtimeService',
    'IGameRealtimeService realtimeService'
  );
  content = content.replaceAll(
    'final GameRealtimeService _realtimeService;',
    'final IGameRealtimeService _realtimeService;'
  );
  file.writeAsStringSync(content);

  // 4. GameRepositoryImpl realtime service type
  file = File('packages/quiz_infrastructure/lib/src/features/game/data/repositories/game_repository_impl.dart');
  content = file.readAsStringSync();
  if (!content.contains("import 'package:quiz_domain/quiz_domain.dart';")) {
    content = "import 'package:quiz_domain/quiz_domain.dart';\n" + content;
  }
  content = content.replaceAll(
    'GameRealtimeService realtimeService',
    'IGameRealtimeService realtimeService'
  );
  content = content.replaceAll(
    'final GameRealtimeService _realtimeService;',
    'final IGameRealtimeService _realtimeService;'
  );
  file.writeAsStringSync(content);
}

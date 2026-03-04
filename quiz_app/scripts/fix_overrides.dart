import 'dart:io';

void main() {
  var file = File('packages/quiz_infrastructure/lib/src/services/online_host_game_engine.dart');
  var content = file.readAsStringSync();
  
  content = content.replaceAll(
    'Future<void> startGame()',
    '@override\  Future<void> startGame()'
  );
  content = content.replaceAll(
    'Future<void> pauseGame()',
    '@override\  Future<void> pauseGame()'
  );
  content = content.replaceAll(
    'Future<void> resumeGame()',
    '@override\  Future<void> resumeGame()'
  );
  content = content.replaceAll(
    'Future<void> stopGame()',
    '@override\  Future<void> stopGame()'
  );
  content = content.replaceAll(
    'Future<void> skipQuestion()',
    '@override\  Future<void> skipQuestion()'
  );
  content = content.replaceAll(
    'Future<void> nextQuestion()',
    '@override\  Future<void> nextQuestion()'
  );
  content = content.replaceAll(
    'Future<void> kickPlayer(String memberId)',
    '@override\  Future<void> kickPlayer(String memberId)'
  );
  content = content.replaceAll(
    'Future<void> setManualFlow(bool manual)',
    '@override\  Future<void> setManualFlow(bool manual)'
  );
  content = content.replaceAll(
    'void dispose()',
    '@override\  void dispose()'
  );
  
  file.writeAsStringSync(content);
}

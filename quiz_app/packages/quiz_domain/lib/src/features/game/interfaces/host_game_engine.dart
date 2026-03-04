import 'package:quiz_domain/quiz_domain.dart';

enum GameStatus { lobby, playing, paused, roundOver, finished, error }

abstract class HostGameEngine {
  GameStatus get status;
  bool get isManualFlow;
  int get currentQuestionIndex;

  void startGame();
  void pauseGame();
  void resumeGame();
  void stopGame();
  void skipQuestion();
  void nextQuestion();
  void kickPlayer(String userId);
  void setManualFlow(bool manual);
  void dispose();
}

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_infrastructure/quiz_infrastructure.dart';

class OnlineHostGameEngine implements HostGameEngine {
  final SupabaseClient supabaseClient;
  final IGameRealtimeService realtimeService;
  final QuizEntity quiz;
  final int? timerOverride;

  @override
  GameStatus status = GameStatus.lobby;
  @override
  bool isManualFlow = false;
  @override
  int currentQuestionIndex = 0;

  OnlineHostGameEngine({
    required this.supabaseClient,
    required this.realtimeService,
    required this.quiz,
    this.timerOverride,
  });

  void startGame() {
    status = GameStatus.playing;
    // Broadcast game start and first question
    _broadcastNextQuestion();
  }

  void pauseGame() {
    status = GameStatus.paused;
    realtimeService.broadcastEvent('game-status-changed', {'status': 'paused'});
  }

  void resumeGame() {
    status = GameStatus.playing;
    realtimeService
        .broadcastEvent('game-status-changed', {'status': 'playing'});
  }

  void stopGame() {
    status = GameStatus.finished;
    realtimeService
        .broadcastEvent('game-status-changed', {'status': 'finished'});
  }

  void skipQuestion() {
    if (status != GameStatus.playing) return;
    _broadcastNextQuestion();
  }

  void nextQuestion() {
    if (status != GameStatus.playing && status != GameStatus.roundOver) return;
    _broadcastNextQuestion();
  }

  void kickPlayer(String userId) {
    realtimeService
        .broadcastEvent('player-kicked', {'userId': userId, 'isBan': false});
  }

  void setManualFlow(bool manual) {
    isManualFlow = manual;
  }

  @override  void dispose() {
    // any cleanup
  }

  void _broadcastNextQuestion() {
    if (currentQuestionIndex < quiz.questions.length) {
      final q = quiz.questions[currentQuestionIndex];
      realtimeService.broadcastEvent('new-question', {
        'question': q.question,
        'options': q.options,
        'timer': timerOverride ?? q.timer,
        'questionIndex': currentQuestionIndex,
        'totalQuestions': quiz.questions.length,
      });
      currentQuestionIndex++;
    } else {
      stopGame();
      realtimeService.broadcastEvent('final-results', {'finished': true});
    }
  }
}

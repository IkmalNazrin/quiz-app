import 'dart:async';
import 'package:quiz_domain/quiz_domain.dart';

class OfflineGameEngine {
  final List<Map<String, dynamic>> questions;
  final String quizId;
  final String username;
  final IOfflineSyncRepository? offlineSyncRepository;

  final _eventController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get eventStream => _eventController.stream;

  int _currentIndex = 0;
  int _score = 0;
  int _streak = 0;
  Timer? _timer;
  DateTime? _roundEndsAt;
  bool _isAnswerLocked = false;

  OfflineGameEngine({
    required this.questions,
    required this.quizId,
    required this.username,
    required this.offlineSyncRepository,
  });

  void start() {
    _currentIndex = 0;
    _score = 0;
    _streak = 0;
    _startNextQuestion();
  }

  void _startNextQuestion() {
    if (_currentIndex >= questions.length) {
      _finishGame();
      return;
    }

    _isAnswerLocked = false;
    final currentQ = questions[_currentIndex];
    final timerSeconds = (currentQ['timer'] as num?)?.toInt() ?? 15;

    // Announce playing state
    _broadcastState('playing', {
      'currentQuestion': currentQ,
      'createdAt': DateTime.now().toIso8601String(),
    });

    // Start timer sequence
    _roundEndsAt = DateTime.now().add(Duration(seconds: timerSeconds));
    _broadcastTick();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (DateTime.now().isAfter(_roundEndsAt!)) {
        timer.cancel();
        if (!_isAnswerLocked) {
          _handleTimeUp();
        }
      } else {
        _broadcastTick();
      }
    });
  }

  void submitAnswer(int index, {bool isDoubleDown = false}) {
    if (_isAnswerLocked || _timer == null || !_timer!.isActive) return;
    _isAnswerLocked = true;

    final currentQ = questions[_currentIndex];
    final correctIndex = currentQ['correct_index'] as int?;

    _broadcastEvent('answer-locked', {
      'user_id': 'local',
      'answer_index': index,
    });

    final isCorrect = correctIndex == index;
    int pointsGained = 0;

    if (isCorrect) {
      _streak++;
      pointsGained = 100 * (isDoubleDown ? 2 : 1);
      final remainingSeconds =
          _roundEndsAt!.difference(DateTime.now()).inSeconds;
      if (remainingSeconds > 0) {
        pointsGained += (remainingSeconds * 10).toInt(); // Time bonus
      }
    } else {
      _streak = 0;
    }

    _score += pointsGained;

    // Optional delay to show answer locked state before resolving round
    Future.delayed(const Duration(seconds: 1), () {
      _timer?.cancel();
      _resolveRound(isCorrect, pointsGained, correctIndex);
    });
  }

  void _handleTimeUp() {
    _streak = 0;
    _isAnswerLocked = true;
    final correctIndex = questions[_currentIndex]['correct_index'] as int?;
    _resolveRound(false, 0, correctIndex);
  }

  void _resolveRound(bool isCorrect, int pointsGained, int? correctIndex) {
    _broadcastState('round_over', {
      'correctAnswerIndex': correctIndex,
      'players': [
        {
          'user_id': 'local',
          'username': username,
          'score': _score,
          'pointsGained': pointsGained,
          'streak': _streak,
          'isCorrect': isCorrect,
        }
      ]
    });

    // Automatically transition to next question after reviewing answer
    Future.delayed(const Duration(seconds: 4), () {
      _currentIndex++;
      _startNextQuestion();
    });
  }

  Future<void> _finishGame() async {
    final finalData = {
      'players': [
        {
          'user_id': 'local',
          'username': username,
          'score': _score,
        }
      ],
      'quizId': quizId,
    };

    _broadcastState('finished', finalData);
    _broadcastEvent('final-results', finalData);

    // Persist to Drift for syncing
    await offlineSyncRepository?.cacheMutation(
      mutationType: 'offline_game_result',
      payload: {
        'quiz_id': quizId,
        'final_score': _score,
        'completed_at': DateTime.now().toIso8601String(),
        'questions_played': questions.length,
      },
    );
  }

  void _broadcastState(String status, Map<String, dynamic> sessionData) {
    _eventController.add({
      'event': 'status',
      'data': {
        'status': status,
        'sessionData': sessionData,
      }
    });
  }

  void _broadcastTick() {
    if (_roundEndsAt == null) return;
    _eventController.add({
      'event': 'question-tick',
      'data': {
        'round_ends_at': _roundEndsAt!.toIso8601String(),
      }
    });
  }

  void _broadcastEvent(String eventType, Map<String, dynamic> data) {
    _eventController.add({
      'event': eventType,
      'data': data,
    });
  }

  void dispose() {
    _timer?.cancel();
    _eventController.close();
  }
}

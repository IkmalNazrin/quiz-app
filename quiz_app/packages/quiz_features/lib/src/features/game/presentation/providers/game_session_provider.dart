import 'package:flutter/foundation.dart';
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/quiz/presentation/providers/quiz_provider.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';


// Realtime Service Provider
import 'package:quiz_domain/quiz_domain.dart';

import 'package:quiz_ui_core/quiz_ui_core.dart';
import 'package:quiz_features/quiz_features.dart';

final gameRealtimeServiceProvider = Provider<IGameRealtimeService>((ref) {
  throw UnimplementedError('Infrastructure injection required');
});

// Connectivity Service Provider
final connectivityServiceProvider = Provider<NetworkInfoInterface>((ref) {
  throw UnimplementedError('Infrastructure injection required');
});

// Host Game Engine Factory Provider (DI for HostGameEngine)
final hostGameEngineFactoryProvider = Provider<HostGameEngine Function(QuizEntity quiz, int? timerOverride)>((ref) {
  throw UnimplementedError('Infrastructure injection required');
});

// Sync Queue Service Provider
final syncQueueServiceProvider = Provider<ISyncQueueService>((ref) {
  throw UnimplementedError('Infrastructure injection required');
});

// Repository Provider
final gameRepositoryProvider = Provider<GameRepository>((ref) {
  throw UnimplementedError('Infrastructure injection required');
});

// State Provider
final gameSessionProvider =
    StateNotifierProvider<GameSessionNotifier, GameEntity>((ref) {
  return GameSessionNotifier(
    ref.read(gameRepositoryProvider),
    ref.read(gameRealtimeServiceProvider),
    ref.read(quizRepositoryProvider),
    ref.read(authRepositoryProvider),
    ref.read(connectivityServiceProvider),
    ref.read(syncQueueServiceProvider),
    ref.read(hostGameEngineFactoryProvider),
  );
});

class GameSessionNotifier extends StateNotifier<GameEntity> {
  String? _currentUserId;

  Future<void> _fetchUserId() async {
    final result = await authRepository.getCurrentUser();
    result.fold((_) => _currentUserId = null, (u) => _currentUserId = u.id);
  }
  final GameRepository repository;
  final IGameRealtimeService realtimeService;
  final QuizRepository quizRepository;
  final AuthRepository authRepository;
  final NetworkInfoInterface connectivityService;
  final ISyncQueueService syncQueueService;
  final HostGameEngine Function(QuizEntity quiz, int? timerOverride) hostGameEngineFactory;

  HostGameEngine? _hostEngine;
  late final Throttler _lobbyThrottler;

  GameSessionNotifier(
    this.repository,
    this.realtimeService,
    this.quizRepository,
    this.authRepository,
    this.connectivityService,
    this.syncQueueService,
    this.hostGameEngineFactory,
  ) : super(const GameEntity(socketStatus: 'connected')) {
    _lobbyThrottler = Throttler(delay: const Duration(seconds: 3));
    debugPrint('Initializing GameSessionNotifier');
    _setupListeners();
    _setupSyncListeners();
  }

  void _setupSyncListeners() {
    syncQueueService.isSyncingStream.listen((isSyncing) {
      state = state.copyWith(isSyncing: isSyncing);
    });
  }

  void _setupListeners() {
    // 1. Listen for Presence updates (Players list)
    realtimeService.playersStream.listen((playerList) {
      debugPrint('Presence Update: ${playerList.length} players');
      state = state.copyWith(players: playerList);
    });

    // 2. Listen for Broadcast Events
    realtimeService.eventsStream.listen((payload) async {
      final event = payload['event'] as String?;
      final data = payload['payload'] as Map<String, dynamic>? ?? {};

      debugPrint('Broadcast received in Notifier: $event');

      switch (event) {
        case 'game-started':
          // The host started the game
          final loadout = PowerUpLoadout.fromId(state.powerUpMode);
          state = state.copyWith(
            status: 'playing',
            powerUpInventory: loadout.items,
          );
          break;

        case 'game-status-changed':
          final newStatus = data['status'] as String?;
          if (newStatus != null) {
            state = state.copyWith(status: newStatus);
          }
          break;

        case 'new-question':
          debugPrint('New Question Received: ${data['question']}');
          _handleNewQuestion(data);
          break;

        case 'timer-update':
          state = state.copyWith(timeLeft: data['timeLeft'] ?? 0);
          break;

        case 'timer-accelerated':
          debugPrint('Timer accelerated');
          // If server provided a new roundEndsAt, update it
          final newRoundEndsAt = data['roundEndsAt'] as String?;
          state = state.copyWith(
            roundEndsAt: newRoundEndsAt != null
                ? DateTime.parse(newRoundEndsAt)
                : state.roundEndsAt,
            isTimerAccelerated: true,
          );
          await HapticService.heavy();
          break;

        case 'round-over':
          debugPrint('Round over received');
          _handleRoundOver(data);
          break;

        case 'final-results':
          debugPrint('Final results received');
          await HapticService.success();
          state = state.copyWith(status: 'finished', finalResults: data);
          break;

        case 'player-kicked':
          final kickedUserId = data['userId'] as String?;
          final isBan = data['isBan'] == true;
          final myId = _currentUserId;

          if (kickedUserId != null) {
            if (kickedUserId == myId) {
              debugPrint('I have been kicked/banned from the game');
              state = state.copyWith(status: isBan ? 'banned' : 'kicked');
              await disconnect();
            } else {
              final updatedPlayers =
                  List<Map<String, dynamic>>.from(state.players)
                    ..removeWhere((p) => p['user_id'] == kickedUserId);
              state = state.copyWith(players: updatedPlayers);
              await HapticService.light();
            }
          }
          break;

        case 'game-state-update':
          final newIsTeamMode = data['isTeamMode'] ?? state.isTeamMode;
          final newTeamMemberLimit =
              data['teamMemberLimit'] ?? state.teamMemberLimit;

          List<Team> newTeams = state.teams;
          if (data['teams'] is Map) {
            newTeams = (data['teams'] as Map).entries.map((entry) {
              return Team.fromMapEntry(entry.key.toString(), entry.value);
            }).toList();
          }

          state = state.copyWith(
            isTeamMode: newIsTeamMode,
            teams: newTeams,
            teamMemberLimit: newTeamMemberLimit,
          );
          break;

        case 'host-disconnected':
          state = state.copyWith(status: 'disconnected');
          break;
      }
    });
  }

  void _handleNewQuestion(Map<String, dynamic> questionData) {
    // Defensive mapping
    final validatedData = {
      'question': questionData['question'] ?? 'Missing Question',
      'options': List<String>.from(questionData['options'] ?? []),
      'timer': questionData['timer'] ?? 15,
      'questionIndex': questionData['questionIndex'] ?? 0,
      'totalQuestions': questionData['totalQuestions'] ?? 0,
    };

    state = state.copyWith(
      status: 'playing',
      currentQuestion: validatedData,
      roundEndsAt: questionData['roundEndsAt'] != null
          ? DateTime.parse(questionData['roundEndsAt'])
          : DateTime.now()
              .add(Duration(seconds: validatedData['timer'] as int)),
      currentPointsGained: 0,
      isTimerAccelerated: false,
    );
  }

  void usePowerUp(PowerUpType type) {
    // 1. Check inventory
    final count = state.powerUpInventory[type] ?? 0;
    if (count <= 0) {
      HapticService.error();
      return;
    }

    // 2. Consume item
    final newInventory = Map<PowerUpType, int>.from(state.powerUpInventory);
    newInventory[type] = count - 1;

    // 3. Apply State Effect (if needed for logic)
    // For 50/50 and Retry, the UI handles the immediate visual.
    // For Double Down, we might want to track it for submission.
    // We can store 'activePowerUps' in a local set or expanded GameEntity state if needed.
    // For now, we'll just handle inventory decrement here.

    state = state.copyWith(powerUpInventory: newInventory);
    HapticService.selection();
  }

  void _handleRoundOver(Map<String, dynamic> data) {
    // Calculate points gained and update streak
    int pointsGained = 0;
    int newStreak = state.streak;

    try {
      final players = List<Map<String, dynamic>>.from(data['players'] ?? []);
      final myId = _currentUserId;
      final me =
          players.firstWhere((p) => p['user_id'] == myId, orElse: () => {});

      if (me.isNotEmpty) {
        final oldMe = state.players
            .firstWhere((p) => p['user_id'] == myId, orElse: () => {});
        if (oldMe.isNotEmpty) {
          pointsGained = (me['score'] ?? 0) - (oldMe['score'] ?? 0);
        }

        if (pointsGained > 0) {
          newStreak++;
          HapticService.success();
        } else {
          newStreak = 0;
          HapticService.error();
        }
      }
    } catch (e, s) {
      debugPrint('Error calculating streak/points: $e');
    }

    state = state.copyWith(
      status: 'round_over',
      finalResults: data,
      streak: newStreak,
      currentPointsGained: pointsGained,
    );
  }

  // Actions
  Future<void> connect() async {
    debugPrint('Connecting GameSession');
    await repository.connect();
  }

  Future<void> disconnect() async {
    debugPrint('Disconnecting GameSession and Resetting State');
    _hostEngine?.dispose();
    _hostEngine = null;
    await repository.disconnect();
    state = const GameEntity(
        status: 'initial', socketStatus: 'disconnected'); // Reset state
  }

  Future<void> hostGame(String nickname, String quizId, String token) async {
    await _fetchUserId();
    _lobbyThrottler.run(() async {
      state = state.copyWith(socketStatus: 'connecting');
      final gameEntity = await repository.hostGame(nickname, quizId, token);

      // Update state with returned entity (which includes valid ID, PIN, etc.)
      // We keep players empty initially as Presence will populate them
      state = gameEntity.copyWith(
        socketStatus: 'connected',
        quizId: quizId,
        players: [],
      );
    });
  }

  Future<void> joinGame(String nickname, String gamePin, String? token) async {
    await _fetchUserId();
    state = state.copyWith(socketStatus: 'connecting');

    // Check if authenticated, if not sign in anonymously
    final loggedIn = await authRepository.isLoggedIn();
    if (!loggedIn) {
      debugPrint(
          'User not logged in, signing in anonymously for guest access');
      final authResult = await authRepository.signInAnonymously();

      if (authResult.isLeft()) {
        debugPrint('Failed to sign in anonymously');
        state = state.copyWith(socketStatus: 'error');
        return;
      }
    }

    final gameEntity = await repository.joinGame(nickname, gamePin, token);

    // Update state with returned entity (loads persisted teams/settings)
    state = gameEntity.copyWith(
      socketStatus: 'connected',
    );
  }

  Future<void> startGame(String? token) async {
    // 1. Broadcast Start
    await repository.startGame(state.gamePin, token ?? '');

    // 2. If Host, Initialize Engine
    if (state.hostId == _currentUserId) {
      // Use quizId from state (set during hostGame)
      final quizId = state.quizId;

      final quizResult = await quizRepository.getQuizDetails(quizId);

      quizResult.fold(
          (failure) => debugPrint(
              'Failed to fetch quiz for engine: ${failure.message}'), (quiz) {
        _hostEngine = hostGameEngineFactory(quiz, int.tryParse(state.timerOverride.toString()));
        _hostEngine!.setManualFlow(state.isManualFlow);
        _hostEngine!.startGame();
      });
    }
  }

  // Host Controls
  void togglePause() {
    if (_hostEngine == null) return;
    if (_hostEngine!.status == GameStatus.playing) {
      _hostEngine!.pauseGame();
      state = state.copyWith(status: 'paused');
    } else if (_hostEngine!.status == GameStatus.paused) {
      _hostEngine!.resumeGame();
      state = state.copyWith(status: 'playing');
    }
  }

  void skipQuestion() {
    _hostEngine?.skipQuestion();
  }

  void nextQuestion() {
    _hostEngine?.nextQuestion();
    state = state.copyWith(status: 'playing');
  }

  void setManualFlow(bool value) {
    state = state.copyWith(isManualFlow: value);
    _hostEngine?.setManualFlow(value);
  }

  void kickPlayer(String userId) {
    if (state.hostId == _currentUserId) {
      realtimeService
          .broadcastEvent('player-kicked', {'userId': userId, 'isBan': false});

      // Log the kick (handled by repository layer)
      debugPrint('Player kicked: $userId');

      // Also tell the engine if it's running
      _hostEngine?.kickPlayer(userId);
    }
  }

  Future<void> banPlayer(String userId) async {
    if (state.hostId == _currentUserId) {
      await repository.banPlayer(state.gamePin, userId);

      // Log the ban (handled by repository layer)
      debugPrint('Player banned: $userId');

      // Also tell the engine if it's running
      _hostEngine?.kickPlayer(userId);
    }
  }

  Future<void> submitAnswer(int answerIndex,
      {bool isDoubleDown = false}) async {
    await HapticService.light();

    final userId = _currentUserId;
    final payload = {
      'userId': userId,
      'answerIndex': answerIndex,
      'isDoubleDown': isDoubleDown,
    };

    // 1. Check Connectivity First (Optimistic Offline Queue)
    final online = await connectivityService.isOnline;
    if (!online) {
      debugPrint('Device is offline. Queuing answer for sync.');
      unawaited(syncQueueService.queueAction(
        action: 'submit-answer',
        gamePin: state.gamePin,
        payload: payload,
      ));
      return;
    }

    // 2. Authoritative Submission via Repository
    try {
      await repository.submitAnswer(state.gamePin, answerIndex, 0,
          isDoubleDown: isDoubleDown);
      debugPrint('Answer submitted successfully.');
    } catch (e, s) {
      debugPrint('Failed to submit answer to server. Queuing for sync.');
      unawaited(syncQueueService.queueAction(
        action: 'submit-answer',
        gamePin: state.gamePin,
        payload: payload,
      ));
    }
  }

  // Lobby Actions
  void toggleTeamMode(bool isTeamMode) {
    // 1. Optimistic Update
    state = state.copyWith(isTeamMode: isTeamMode);

    // 2. Broadcast
    repository.toggleTeamMode(state.gamePin, isTeamMode);
  }

  void setTeamLimit(int limit) {
    // 1. Optimistic Update
    state = state.copyWith(teamMemberLimit: limit);

    // 2. Broadcast
    // We send the current state including teams, just in case, though usually limit is separate
    repository.setTeamLimit(state.gamePin, limit);
  }

  void setTimerOverride(int? seconds) {
    state = state.copyWith(timerOverride: seconds);
  }

  void addTeam() {
    final currentTeams = List<Team>.from(state.teams);
    final nextIndex = currentTeams.length + 1;
    final newTeamName = 'Team $nextIndex';

    if (!currentTeams.any((t) => t.name == newTeamName)) {
      currentTeams.add(Team(name: newTeamName, members: const []));
      _updateAndBroadcastTeams(currentTeams);
    }
  }

  void removeTeam() {
    final currentTeams = List<Team>.from(state.teams);
    if (currentTeams.isNotEmpty) {
      currentTeams.removeLast();
      _updateAndBroadcastTeams(currentTeams);
    }
  }

  void randomizeTeams() {
    final players = List<Map<String, dynamic>>.from(state.players);
    if (players.isEmpty) return;

    // Shuffle players
    players.shuffle();

    List<Team> currentTeams = List<Team>.from(state.teams);

    // If no teams, create 2 by default
    if (currentTeams.isEmpty) {
      currentTeams = [
        const Team(name: 'Team 1', members: []),
        const Team(name: 'Team 2', members: []),
      ];
    } else {
      // Clear current assignments
      currentTeams = currentTeams
          .map((t) => Team(name: t.name, members: const []))
          .toList();
    }

    int teamIndex = 0;
    for (var player in players) {
      final userId = player['user_id'] as String?;
      if (userId == null) continue;

      // Check limits
      bool assigned = false;
      if (state.teamMemberLimit > 0) {
        for (int i = 0; i < currentTeams.length; i++) {
          final index = (teamIndex + i) % currentTeams.length;
          if (currentTeams[index].members.length < state.teamMemberLimit) {
            final updatedMembers =
                List<TeamMember>.from(currentTeams[index].members)
                  ..add(TeamMember.fromId(userId));
            currentTeams[index] =
                Team(name: currentTeams[index].name, members: updatedMembers);
            assigned = true;
            break;
          }
        }
      } else {
        final index = teamIndex % currentTeams.length;
        final updatedMembers =
            List<TeamMember>.from(currentTeams[index].members)
              ..add(TeamMember.fromId(userId));
        currentTeams[index] =
            Team(name: currentTeams[index].name, members: updatedMembers);
        assigned = true;
      }

      if (assigned) teamIndex++;
    }

    _updateAndBroadcastTeams(currentTeams);
  }

  void assignTeam(String playerId, String teamName) {
    final List<Team> currentTeams = state.teams.map((t) {
      // Remove player from any team first
      final newMembers = List<TeamMember>.from(t.members)
        ..removeWhere((m) => m.userId == playerId);
      return Team(name: t.name, members: newMembers);
    }).toList();

    // Add to new team
    final teamIndex = currentTeams.indexWhere((t) => t.name == teamName);
    if (teamIndex != -1) {
      // Check limit if applicable
      if (state.teamMemberLimit > 0 &&
          currentTeams[teamIndex].members.length >= state.teamMemberLimit) {
        debugPrint('Team $teamName is full');
        return;
      }

      final updatedMembers =
          List<TeamMember>.from(currentTeams[teamIndex].members)
            ..add(TeamMember.fromId(playerId));
      currentTeams[teamIndex] = Team(name: teamName, members: updatedMembers);
    }

    _updateAndBroadcastTeams(currentTeams);
  }

  void playerAssignTeam(String teamName) {
    final myId = _currentUserId;
    if (myId != null) {
      assignTeam(myId, teamName);
    }
  }

  void renameTeam(String oldTeamName, String newTeamName) {
    final currentTeams = List<Team>.from(state.teams);
    final teamIndex = currentTeams.indexWhere((t) => t.name == oldTeamName);

    if (teamIndex != -1) {
      currentTeams[teamIndex] = Team(
        name: newTeamName,
        members: currentTeams[teamIndex].members,
      );
      _updateAndBroadcastTeams(currentTeams);
    }
  }

  void _updateAndBroadcastTeams(List<Team> newTeams) {
    // 1. Optimistic Update
    state = state.copyWith(teams: newTeams);

    // 2. Broadcast
    repository.updateGameTeams(state.gamePin, newTeams);
  }
}

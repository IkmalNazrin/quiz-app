import 'package:equatable/equatable.dart';
// Removed logger_service import
import 'team_entity.dart';
import 'power_up.dart';

class GameEntity extends Equatable {
  final String id;
  final String gamePin;
  final String quizId;
  final String status; // 'lobby', 'playing', 'paused', 'round_over', 'finished'
  final List<dynamic> players;
  final List<Team> teams;
  final bool isTeamMode;
  final int teamMemberLimit;
  final String? hostId;
  final Map<String, dynamic>? currentQuestion;
  final int timeLeft;
  final dynamic finalResults;
  final int streak;
  final int currentPointsGained;
  final String
      socketStatus; // 'disconnected', 'connecting', 'connected', 'error'
  final String powerUpMode;
  final Map<PowerUpType, int> powerUpInventory;
  final int? timerOverride;
  final bool isManualFlow;
  final bool isTimerAccelerated;
  final DateTime? roundEndsAt;
  final bool isSyncing;
  final List<dynamic> teamScores; // Real-time standings from view

  const GameEntity({
    this.id = '',
    this.gamePin = '',
    this.quizId = '',
    this.status = 'initial',
    this.players = const [],
    this.teams = const [],
    this.isTeamMode = false,
    this.teamMemberLimit = 0,
    this.hostId,
    this.currentQuestion,
    this.timeLeft = 0,
    this.finalResults,
    this.streak = 0,
    this.currentPointsGained = 0,
    this.socketStatus = 'disconnected',
    this.powerUpMode = 'balanced',
    this.powerUpInventory = const {},
    this.timerOverride,
    this.isManualFlow = false,
    this.isTimerAccelerated = false,
    this.roundEndsAt,
    this.isSyncing = false,
    this.teamScores = const [],
  });

  GameEntity copyWith({
    String? id,
    String? gamePin,
    String? quizId,
    String? status,
    List<dynamic>? players,
    List<Team>? teams,
    bool? isTeamMode,
    int? teamMemberLimit,
    String? hostId,
    Map<String, dynamic>? currentQuestion,
    int? timeLeft,
    dynamic finalResults,
    int? streak,
    int? currentPointsGained,
    String? socketStatus,
    String? powerUpMode,
    Map<PowerUpType, int>? powerUpInventory,
    int? timerOverride,
    bool? isManualFlow,
    bool? isTimerAccelerated,
    DateTime? roundEndsAt,
    bool? isSyncing,
    List<dynamic>? teamScores,
  }) {
    return GameEntity(
      id: id ?? this.id,
      gamePin: gamePin ?? this.gamePin,
      quizId: quizId ?? this.quizId,
      status: status ?? this.status,
      players: players ?? this.players,
      teams: teams ?? this.teams,
      isTeamMode: isTeamMode ?? this.isTeamMode,
      teamMemberLimit: teamMemberLimit ?? this.teamMemberLimit,
      hostId: hostId ?? this.hostId,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      timeLeft: timeLeft ?? this.timeLeft,
      finalResults: finalResults ?? this.finalResults,
      streak: streak ?? this.streak,
      currentPointsGained: currentPointsGained ?? this.currentPointsGained,
      socketStatus: socketStatus ?? this.socketStatus,
      powerUpMode: powerUpMode ?? this.powerUpMode,
      powerUpInventory: powerUpInventory ?? this.powerUpInventory,
      timerOverride: timerOverride ?? this.timerOverride,
      isManualFlow: isManualFlow ?? this.isManualFlow,
      isTimerAccelerated: isTimerAccelerated ?? this.isTimerAccelerated,
      roundEndsAt: roundEndsAt ?? this.roundEndsAt,
      isSyncing: isSyncing ?? this.isSyncing,
      teamScores: teamScores ?? this.teamScores,
    );
  }

  factory GameEntity.fromMap(Map<String, dynamic> map) {
    // ADR 009: Defensive Type Guarding for JSONB fields
    final teamsData = map['teams'];
    List<Team> parsedTeams = [];

    if (teamsData is Map) {
      parsedTeams = teamsData.entries.map((entry) {
        return Team.fromMapEntry(entry.key.toString(), entry.value);
      }).toList();
    } else if (teamsData != null) {
      print(
          'Unexpected type for teams JSONB field: ${teamsData.runtimeType}. Falling back to empty list.');
    }

    return GameEntity(
      id: map['id'] as String? ?? '',
      gamePin: map['game_pin'] as String? ?? '',
      quizId: map['quiz_id'] as String? ?? '',
      status: map['status'] as String? ?? 'lobby',
      isTeamMode: map['is_team_mode'] as bool? ?? false,
      teamMemberLimit: map['team_member_limit'] as int? ?? 0,
      teams: parsedTeams,
      hostId: map['host_id'] as String?,
      socketStatus: 'connected',
      powerUpMode: map['power_up_mode'] as String? ?? 'balanced',
      isManualFlow: map['is_manual_flow'] as bool? ?? false,
      roundEndsAt: map['round_ends_at'] != null
          ? DateTime.parse(map['round_ends_at'])
          : null,
      isSyncing: false, // Not persisted
    );
  }

  @override
  List<Object?> get props => [
        id,
        gamePin,
        quizId,
        status,
        players,
        teams,
        isTeamMode,
        teamMemberLimit,
        hostId,
        currentQuestion,
        timeLeft,
        finalResults,
        streak,
        currentPointsGained,
        socketStatus,
        powerUpMode,
        powerUpInventory,
        timerOverride,
        isManualFlow,
        isTimerAccelerated,
        roundEndsAt,
        isSyncing,
        teamScores
      ];
}

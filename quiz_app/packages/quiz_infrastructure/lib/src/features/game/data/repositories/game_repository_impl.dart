import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quiz_infrastructure/quiz_infrastructure.dart';
import 'package:quiz_infrastructure/quiz_infrastructure.dart';
import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_domain/quiz_domain.dart';

class GameRepositoryImpl implements GameRepository {
  final SupabaseClient supabase;
  final IGameRealtimeService realtimeService;

  GameRepositoryImpl(this.supabase, this.realtimeService);

  @override
  Future<void> connect() async {
    // Connection is handled on-demand during joinRoom
  }

  @override
  Future<void> disconnect() async {
    await realtimeService.leaveRoom();
  }

  @override
  Future<GameEntity> hostGame(
      String nickname, String quizId, String token) async {
    // 1. Generate a unique 6-digit PIN
    final gamePin = _generatePin();
    AppLogger.i('Hosting game with PIN: $gamePin');

    // 2. Create the game session in Supabase DB
    final sessionResponse = await supabase
        .from('game_sessions')
        .insert({
          'game_pin': gamePin,
          'quiz_id': quizId,
          'host_id': supabase.auth.currentUser?.id,
          'status': 'lobby',
        })
        .select()
        .single();

    final sessionId = sessionResponse['id'];

    // 3. Add host to participants
    await supabase.from('game_participants').insert({
      'session_id': sessionId,
      'user_id': supabase.auth.currentUser?.id,
      'nickname': nickname,
      'is_host': true,
    });

    // 4. Join the realtime room
    await realtimeService.joinRoom(
      gamePin: gamePin,
      nickname: nickname,
      isHost: true,
    );

    // Return entity constructed from response + local knowledge
    return GameEntity.fromMap(sessionResponse).copyWith(
      gamePin: gamePin, // Ensure explicit set
      hostId: supabase.auth.currentUser?.id,
    );
  }

  @override
  Future<GameEntity> joinGame(
      String nickname, String gamePin, String? token) async {
    AppLogger.i('Joining game with PIN: $gamePin');

    // 1. Verify if the session exists
    final session = await supabase
        .from('game_sessions')
        .select()
        .eq('game_pin', gamePin)
        .single();

    final sessionId = session['id'];

    // 2. Check if user is banned from this session
    final existingParticipant = await supabase
        .from('game_participants')
        .select('is_banned')
        .eq('session_id', sessionId)
        .eq('user_id', supabase.auth.currentUser!.id)
        .maybeSingle();

    if (existingParticipant != null &&
        existingParticipant['is_banned'] == true) {
      AppLogger.w('User is banned from this session.');
      throw Exception('You have been banned from this game session.');
    }

    // 3. Add participant to DB (if not already there or just update nickname)
    try {
      if (existingParticipant == null) {
        await supabase.from('game_participants').insert({
          'session_id': sessionId,
          'user_id': supabase.auth.currentUser?.id,
          'nickname': nickname,
          'is_host': false,
        });
      } else {
        await supabase
            .from('game_participants')
            .update({
              'nickname': nickname,
            })
            .eq('session_id', sessionId)
            .eq('user_id', supabase.auth.currentUser!.id);
      }
    } catch (e) {
      AppLogger.w('Participant sync error: $e');
    }

    // 4. Join the realtime room
    await realtimeService.joinRoom(
      gamePin: gamePin,
      nickname: nickname,
      isHost: false,
    );

    return GameEntity.fromMap(session);
  }

  @override
  Future<void> startGame(String gamePin, String token) async {
    AppLogger.i('Starting game: $gamePin');

    // Update session status in DB
    await supabase
        .from('game_sessions')
        .update({'status': 'playing'}).eq('game_pin', gamePin);

    // Broadcast intentional start event (clients can also listen to DB changes)
    await realtimeService.broadcastEvent('game-started', {'gamePin': gamePin});
  }

  @override
  Future<void> submitAnswer(String gamePin, int answerIndex, int timeLeft,
      {bool isDoubleDown = false}) async {
    AppLogger.d('Submitting answer for game: $gamePin');

    // Find the participant entry for this session and user
    // We update the score based on the logic (this should ideally be validated on a server,
    // but in this serverless approach, the client calculates and updates its own score per ADR 008).

    // For now, just broadcast the submission so the Host/Master can track it,
    // and let the Host update the scores in DB if needed, or each client updates their own.
    // Cleanest way: Client updates its own record in game_participants.

    await realtimeService.broadcastEvent('answer-submitted', {
      'gamePin': gamePin,
      'answerIndex': answerIndex,
      'timeLeft': timeLeft,
      'userId': supabase.auth.currentUser?.id,
      'isDoubleDown': isDoubleDown,
    });
  }

  @override
  Future<void> toggleTeamMode(String gamePin, bool isTeamMode) async {
    await supabase
        .from('game_sessions')
        .update({'is_team_mode': isTeamMode}).eq('game_pin', gamePin);

    await realtimeService.broadcastEvent('game-state-update', {
      'isTeamMode': isTeamMode,
    });
  }

  @override
  Future<void> setTeamLimit(String gamePin, int limit) async {
    await supabase
        .from('game_sessions')
        .update({'team_member_limit': limit}).eq('game_pin', gamePin);

    await realtimeService.broadcastEvent('game-state-update', {
      'teamMemberLimit': limit,
    });
  }

  @override
  Future<void> updateGameTeams(String gamePin, List<Team> teams) async {
    // ADR 010: Convert domain List<Team> back to JSONB map format {"Team Name": ["id1", "id2"]}
    final teamsMap = {
      for (var team in teams)
        team.name: team.members.map((m) => m.userId).toList(),
    };

    try {
      // 1. Persist to DB
      await supabase
          .from('game_sessions')
          .update({'teams': teamsMap}).eq('game_pin', gamePin);

      // 2. Broadcast for immediate UI update
      await realtimeService.broadcastEvent('game-state-update', {
        'teams': teamsMap,
      });
    } catch (e, s) {
      AppLogger.e('Failed to update game teams for $gamePin: $e',
          error: e, stackTrace: s);
      rethrow;
    }
  }

  @override
  Future<void> addTeam(String gamePin) async {
    // Handled by Notifier + updateGameTeams
  }

  @override
  Future<void> removeTeam(String gamePin) async {
    // Handled by Notifier + updateGameTeams
  }

  @override
  Future<void> randomizeTeams(String gamePin) async {
    // Handled by Notifier + updateGameTeams
  }

  @override
  Future<void> assignTeam(
      String gamePin, String playerId, String teamName) async {
    // Handled by Notifier + updateGameTeams
  }

  @override
  Future<void> playerAssignTeam(String gamePin, String teamName) async {
    // Handled by Notifier + updateGameTeams
  }

  @override
  Future<void> renameTeam(
      String gamePin, String oldTeamName, String newTeamName) async {
    // Handled by Notifier + updateGameTeams
  }

  @override
  Future<void> banPlayer(String gamePin, String userId) async {
    final session = await supabase
        .from('game_sessions')
        .select('id')
        .eq('game_pin', gamePin)
        .single();

    final sessionId = session['id'];

    await supabase
        .from('game_participants')
        .update({'is_banned': true})
        .eq('session_id', sessionId)
        .eq('user_id', userId);

    await realtimeService.broadcastEvent('player-kicked', {
      'userId': userId,
      'isBan': true,
    });
  }

  String _generatePin() {
    return (Random().nextInt(900000) + 100000).toString();
  }
}

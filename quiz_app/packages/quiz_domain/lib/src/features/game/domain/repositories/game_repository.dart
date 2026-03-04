import '../entities/game_entity.dart';
import '../entities/team_entity.dart';

abstract class GameRepository {
  Future<void> connect();
  Future<void> disconnect();
  Future<GameEntity> hostGame(String nickname, String quizId, String token);
  Future<GameEntity> joinGame(String nickname, String gamePin, String? token);
  Future<void> startGame(String gamePin, String token);
  Future<void> submitAnswer(String gamePin, int answerIndex, int timeLeft,
      {bool isDoubleDown = false});

  // Lobby actions
  Future<void> toggleTeamMode(String gamePin, bool isTeamMode);
  Future<void> setTeamLimit(String gamePin, int limit);
  Future<void> addTeam(String gamePin);
  Future<void> removeTeam(String gamePin);
  Future<void> randomizeTeams(String gamePin);
  Future<void> assignTeam(String gamePin, String playerId, String teamName);
  Future<void> playerAssignTeam(String gamePin, String teamName);
  Future<void> renameTeam(
      String gamePin, String oldTeamName, String newTeamName);
  Future<void> updateGameTeams(String gamePin, List<Team> teams);
  Future<void> banPlayer(String gamePin, String userId);
}

import 'dart:isolate';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quiz_infrastructure/quiz_infrastructure.dart';
import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_domain/quiz_domain.dart';
import '../models/game_history_model.dart'; // Verify path

class HistoryRepositoryImpl implements HistoryRepository {
  final SupabaseClient supabaseClient;

  HistoryRepositoryImpl(this.supabaseClient);

  @override
  Future<Either<Failure, List<GameHistoryItem>>> getUserHistory(String userId,
      {int limit = 10, int offset = 0}) async {
    try {
      // Query: game_participants
      // Join: game_sessions (on session_id) -> quizzes (on quiz_id)

      final response = await supabaseClient
          .from('game_participants')
          .select('''
            score,
            joined_at,
            session_id,
            game_sessions!inner (
              status,
              quiz_id,
              quizzes (
                title
              )
            )
          ''')
          .eq('user_id', userId)
          .eq('is_host', false) // Filter out Host entries
          .eq('game_sessions.status', 'completed') // Only show completed games
          .order('joined_at', ascending: false)
          .range(offset, offset + limit - 1);

      final List<dynamic> data = response as List<dynamic>;

      final historyItems = await Isolate.run(() => data
          .map(
              (json) => GameHistoryModel.fromJson(json as Map<String, dynamic>))
          .toList());

      return Right(historyItems);
    } catch (e) {
      // Assuming a generic ServerFailure for now.
      // In a real app, map specific Supabase errors.
      return Left(ServerFailure(e.toString()));
    }
  }
}

// Basic Failure implementation fallback if core file is missing/different
// class ServerFailure extends Failure {
//   final String message;
//   const ServerFailure(this.message);
//   @override
//   List<Object> get props => [message];
// }

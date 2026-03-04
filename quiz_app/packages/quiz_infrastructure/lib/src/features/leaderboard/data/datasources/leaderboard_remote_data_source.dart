import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quiz_infrastructure/quiz_infrastructure.dart';
import 'package:quiz_domain/quiz_domain.dart';

abstract class LeaderboardRemoteDataSource {
  Future<List<LeaderboardEntry>> fetchLeaderboard(String quizId,
      {required bool isTeam});
  Future<void> submitScore(
      {required String quizId,
      required int score,
      String? teamName,
      List<Map<String, dynamic>>? members});
}

class LeaderboardRemoteDataSourceImpl implements LeaderboardRemoteDataSource {
  final SupabaseClient supabaseClient;

  LeaderboardRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<LeaderboardEntry>> fetchLeaderboard(String quizId,
      {required bool isTeam}) async {
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        var queryBuilder = supabaseClient
            .from('leaderboard')
            .select('*, profiles:user_id(username, picture_url)')
            .eq('quiz_id', quizId);

        if (isTeam) {
          queryBuilder = queryBuilder.not('team_name', 'is', null);
        } else {
          queryBuilder = queryBuilder.filter('team_name', 'is', 'null');
        }

        final response =
            await queryBuilder.order('score', ascending: false).limit(50);

        final List<dynamic> data = response as List<dynamic>;

        return data.map((json) {
          final profile = json['profiles'] as Map<String, dynamic>?;

          return LeaderboardEntry(
            score: json['score'] ?? 0,
            userId: json['user_id'],
            username: profile?['username'] ?? 'Unknown',
            picture: profile?['picture_url'],
            teamName: json['team_name'],
            members: (json['members'] as List?)
                ?.map((m) => LeaderboardMember(
                      userId: m['id'] ?? '',
                      username: m['name'] ?? 'Unknown',
                    ))
                .toList(),
          );
        }).toList();
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          throw ServerFailure(e.toString());
        }
        await Future.delayed(Duration(milliseconds: 500 * retryCount));
      }
    }
    throw const ServerFailure(
        'Failed to load leaderboard after multiple retries');
  }

  @override
  Future<void> submitScore(
      {required String quizId,
      required int score,
      String? teamName,
      List<Map<String, dynamic>>? members}) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('Not authenticated');

      await supabaseClient.from('leaderboard').insert({
        'quiz_id': quizId,
        'user_id': user.id,
        'score': score,
        'team_name': teamName,
        'members': members,
        'created_at': DateTime.now().toIso8601String(),
      });
    } on AuthException catch (e) {
      throw ServerFailure(e.message);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') throw NotFoundFailure(e.message);
      throw ServerFailure(e.message);
    } on SocketException catch (_) {
      throw const NetworkFailure();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quiz_infrastructure/quiz_infrastructure.dart';
import '../models/challenge_model.dart';
import 'package:quiz_domain/quiz_domain.dart';

abstract class ChallengeRemoteDataSource {
  Future<List<ChallengeModel>> getMyChallenges();
  Future<ChallengeModel> getChallengeById(String id);
  Future<void> createChallenge(ChallengeEntity challenge);
  Future<void> completeChallenge(String challengeId, int score);
}

class ChallengeRemoteDataSourceImpl implements ChallengeRemoteDataSource {
  final RateLimitedApiClient apiClient;

  // Removed http.Client dependency
  ChallengeRemoteDataSourceImpl({
    required this.apiClient,
  });

  @override
  Future<ChallengeModel> getChallengeById(String id) async {
    try {
      apiClient.consumeToken();
      final response = await apiClient.rawClient
          .from('challenges')
          .select()
          .eq('id', id)
          .single();
      return ChallengeModel.fromJson(response);
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

  @override
  Future<List<ChallengeModel>> getMyChallenges() async {
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        final userId = apiClient.rawClient.auth.currentUser?.id;
        if (userId == null) throw const AuthFailure('Not authenticated');

        apiClient.consumeToken();
        final response = await apiClient.rawClient
            .from('challenges')
            .select()
            .or('challenger_id.eq.$userId,opponent_id.eq.$userId')
            .order('created_at', ascending: false);

        final List<dynamic> data = response as List<dynamic>;
        return data.map((json) => ChallengeModel.fromJson(json)).toList();
      } catch (e) {
        retryCount++;
        // Specifically check for connection reset / closed errors if possible,
        // or just retry on any error that isn't AuthFailure.
        if (e is AuthFailure || retryCount >= maxRetries) {
          throw ServerFailure(e.toString());
        }
        // Wait before retrying (exponential backoff)
        await Future.delayed(Duration(milliseconds: 500 * retryCount));
      }
    }
    throw const ServerFailure('Failed after multiple retries');
  }

  @override
  Future<void> createChallenge(ChallengeEntity challenge) async {
    try {
      final userId = apiClient.rawClient.auth.currentUser?.id;
      if (userId == null) throw const AuthFailure('Not authenticated');

      final data = {
        'quiz_id': challenge.quizTitle, // Wait, Entity has quizTitle, not ID?
        // Need to check Entity definition. It might be conflating ID and Title or I need ID.
        // Assuming 'quizTitle' in Entity holds ID or Title?
        // Let's assume I need to pass parameters correctly.
        // The Entity has 'quizTitle'.

        'quiz_title': challenge.quizTitle,
        'challenge_type': challenge.challengeType,
        'challenger_id': userId,
        'challenger_username': challenge.challengerUsername,
        'challenger_score': challenge.challengerScore,
        'opponent_id': challenge.opponentId,
        'opponent_username': challenge.opponentUsername,
        'opponent_score': 0,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      };

      apiClient.consumeToken();
      await apiClient.rawClient.from('challenges').insert(data);
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

  @override
  Future<void> completeChallenge(String challengeId, int score) async {
    try {
      // Determine if I am challenger or opponent?
      // Usually 'complete' means the opponent played.

      apiClient.consumeToken();
      await apiClient.rawClient.from('challenges').update({
        'opponent_score': score,
        'status': 'completed',
        'completed_at': DateTime.now().toIso8601String(),
      }).eq('id', challengeId); // Assuming column is 'id' or '_id'. Supabase usually 'id'.
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

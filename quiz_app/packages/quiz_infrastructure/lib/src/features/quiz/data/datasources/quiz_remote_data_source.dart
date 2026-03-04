import 'dart:io';
import 'dart:isolate';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quiz_infrastructure/quiz_infrastructure.dart';
import '../models/quiz_model.dart';
import 'package:quiz_domain/quiz_domain.dart';

abstract class QuizRemoteDataSource {
  Future<List<QuizModel>> getMyQuizzes();
  Future<List<QuizModel>> getPublicQuizzes();
  Future<QuizModel> getQuizDetails(String id);
  Future<void> createQuiz(QuizModel quiz);
  Future<void> updateQuiz(QuizModel quiz);
  Future<void> deleteQuiz(String quizId);
  Future<void> rateQuiz(String quizId, double rating);
}

class QuizRemoteDataSourceImpl implements QuizRemoteDataSource {
  final RateLimitedApiClient apiClient;

  QuizRemoteDataSourceImpl({
    required this.apiClient,
  });

  @override
  Future<List<QuizModel>> getMyQuizzes() async {
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        final userId = apiClient.rawClient.auth.currentUser?.id;
        if (userId == null) throw const AuthFailure('Not authenticated');

        final response = await apiClient.rawClient
            .from('quizzes')
            .select('*, profiles:owner_id(username), questions:questions(*)')
            .eq('owner_id', userId)
            .order('created_at', ascending: false);

        final List<dynamic> data = response as List<dynamic>;
        return Isolate.run(() => data
            .map((json) => QuizModel.fromSupabase(json as Map<String, dynamic>))
            .toList());
      } catch (e) {
        retryCount++;
        if (e is AuthFailure || retryCount >= maxRetries) {
          throw ServerFailure(e.toString());
        }
        await Future.delayed(Duration(milliseconds: 500 * retryCount));
      }
    }
    throw const ServerFailure(
        'Failed to load my quizzes after multiple retries');
  }

  @override
  Future<void> deleteQuiz(String quizId) async {
    try {
      // Questions will be deleted automatically due to 'ON DELETE CASCADE' in SQL
      await apiClient.rawClient.from('quizzes').delete().eq('id', quizId);
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
  Future<List<QuizModel>> getPublicQuizzes() async {
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        final response = await apiClient.rawClient
            .from('quizzes')
            .select('*, profiles:owner_id(username), questions:questions(*)')
            .eq('is_public', true) // assuming database column is 'is_public'
            .order('created_at', ascending: false);

        final List<dynamic> data = response as List<dynamic>;
        return Isolate.run(() => data
            .map((json) => QuizModel.fromSupabase(json as Map<String, dynamic>))
            .toList());
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          throw ServerFailure(e.toString());
        }
        await Future.delayed(Duration(milliseconds: 500 * retryCount));
      }
    }
    throw const ServerFailure(
        'Failed to load public quizzes after multiple retries');
  }

  @override
  Future<QuizModel> getQuizDetails(String id) async {
    try {
      final response = await apiClient.rawClient
          .from('quizzes')
          .select('*, profiles:owner_id(username), questions:questions(*)')
          .eq('id', id)
          .single();

      return QuizModel.fromSupabase(response);
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
  Future<void> createQuiz(QuizModel quiz) async {
    try {
      final userId = apiClient.rawClient.auth.currentUser?.id;
      if (userId == null) throw const AuthFailure('Not authenticated');

      // 1. Insert Quiz
      final quizData = {
        'title': quiz.title,
        'description': quiz.description,
        'is_public': quiz.isPublic,
        'category': quiz.category,
        'owner_id': userId,
        'created_at': DateTime.now().toIso8601String(),
      };

      final quizResponse = await apiClient.rawClient
          .from('quizzes')
          .insert(quizData)
          .select()
          .single();

      final quizId = quizResponse['id'];

      // 2. Insert Questions
      if (quiz.questions.isNotEmpty) {
        final questionsData = quiz.questions
            .map((q) => {
                  'quiz_id': quizId,
                  'content': q.question,
                  'options': q.options,
                  'correct_index': q.correctAnswerIndex,
                  'difficulty': q.difficulty,
                  'timer_seconds': q.timer,
                })
            .toList();

        await apiClient.rawClient.from('questions').insert(questionsData);
      }
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
  Future<void> updateQuiz(QuizModel quiz) async {
    try {
      // 1. Update Quiz Details
      await apiClient.rawClient.from('quizzes').update({
        'title': quiz.title,
        'description': quiz.description,
        'is_public': quiz.isPublic,
        'category': quiz.category,
      }).eq('id', quiz.id);

      // 2. Handle Questions (Full Replace strategy for simplicity)
      // Delete existing questions
      await apiClient.rawClient.from('questions').delete().eq('quiz_id', quiz.id);

      // Insert new questions
      if (quiz.questions.isNotEmpty) {
        final questionsData = quiz.questions
            .map((q) => {
                  'quiz_id': quiz.id,
                  'content': q.question,
                  'options': q.options,
                  'correct_index': q.correctAnswerIndex,
                  'difficulty': q.difficulty,
                  'timer_seconds': q.timer,
                })
            .toList();

        await apiClient.rawClient.from('questions').insert(questionsData);
      }
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
  Future<void> rateQuiz(String quizId, double rating) async {
    try {
      final user = apiClient.rawClient.auth.currentUser;
      if (user == null) throw Exception('Not authenticated');

      // Assuming a 'quiz_ratings' table exists or update 'quizzes' directly?
      // Legacy was: /api/quizzes/:id/rate
      // Let's assume 'quiz_ratings' table: id, quiz_id, user_id, rating.

      await apiClient.rawClient.from('quiz_ratings').upsert({
        'quiz_id': quizId,
        'user_id': user.id,
        'rating': rating,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'quiz_id,user_id');
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

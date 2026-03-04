import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dartz/dartz.dart';
import 'package:quiz_infrastructure/quiz_infrastructure.dart';
import 'package:quiz_domain/quiz_domain.dart';
import '../datasources/quiz_remote_data_source.dart';
import '../models/quiz_model.dart';

import 'package:drift/drift.dart';

class QuizRepositoryImpl implements QuizRepository {
  final QuizRemoteDataSource remoteDataSource;
  final AppDatabase localDatabase;

  QuizRepositoryImpl(this.remoteDataSource, this.localDatabase);

  @override
  Future<Either<Failure, List<QuizEntity>>> getMyQuizzes() async {
    try {
      final quizzes = await remoteDataSource.getMyQuizzes();
      // Cache quizzes locally
      await _cacheQuizzesLocally(quizzes);
      return Right(quizzes);
    } on Failure catch (_) {
      // Fallback to local cache
      try {
        final localData =
            await localDatabase.select(localDatabase.localQuizzes).get();
        if (localData.isNotEmpty) {
          final cachedQuizzes =
              localData.map((row) => _mapLocalToQuizEntity(row)).toList();
          return Right(cachedQuizzes);
        }
      } catch (dbError) {
        return Left(ServerFailure('Offline cache failed: $dbError'));
      }
      return Left(ServerFailure('No connection and no local cache available'));
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') return Left(NotFoundFailure(e.message));
      return Left(ServerFailure(e.message));
    } on SocketException catch (_) {
      return Left(const NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<QuizEntity>>> getPublicQuizzes() async {
    try {
      final quizzes = await remoteDataSource.getPublicQuizzes();
      // Cache quizzes locally
      await _cacheQuizzesLocally(quizzes);
      return Right(quizzes);
    } on Failure catch (_) {
      // Fallback to local cache for public quizzes (this could be refined to only return truly public ones)
      try {
        final localData =
            await (localDatabase.select(localDatabase.localQuizzes)
                  ..where((tbl) => tbl.isPublic.equals(true)))
                .get();
        if (localData.isNotEmpty) {
          final cachedQuizzes =
              localData.map((row) => _mapLocalToQuizEntity(row)).toList();
          return Right(cachedQuizzes);
        }
      } catch (dbError) {
        return Left(ServerFailure('Offline cache failed: $dbError'));
      }
      return Left(ServerFailure('No connection and no local cache available'));
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') return Left(NotFoundFailure(e.message));
      return Left(ServerFailure(e.message));
    } on SocketException catch (_) {
      return Left(const NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, QuizEntity>> getQuizDetails(String id) async {
    try {
      final quiz = await remoteDataSource.getQuizDetails(id);
      return Right(quiz);
    } on Failure catch (_) {
      try {
        final localQuizRow =
            await (localDatabase.select(localDatabase.localQuizzes)
                  ..where((tbl) => tbl.id.equals(id)))
                .getSingleOrNull();
        if (localQuizRow != null) {
          return Right(_mapLocalToQuizEntity(localQuizRow));
        }
      } catch (dbError) {
        return Left(ServerFailure('Offline cache failed: $dbError'));
      }
      return Left(ServerFailure('No connection and no local cache available'));
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') return Left(NotFoundFailure(e.message));
      return Left(ServerFailure(e.message));
    } on SocketException catch (_) {
      return Left(const NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createQuiz(QuizEntity quiz) async {
    try {
      // Convert Entity to Model
      // Note: Model needs to handle 'id' being potentially empty or generated
      final model = QuizModel(
        id: quiz.id,
        title: quiz.title,
        description: quiz.description,
        isPublic: quiz.isPublic,
        questions: quiz.questions
            .map((q) => QuestionModel(
                  question: q.question,
                  options: q.options,
                  correctAnswerIndex: q.correctAnswerIndex,
                  difficulty: q.difficulty,
                  timer: q.timer,
                ))
            .toList(),
        category: quiz.category,
      );
      await remoteDataSource.createQuiz(model);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') return Left(NotFoundFailure(e.message));
      return Left(ServerFailure(e.message));
    } on SocketException catch (_) {
      return Left(const NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateQuiz(QuizEntity quiz) async {
    try {
      final model = QuizModel(
        id: quiz.id,
        title: quiz.title,
        description: quiz.description,
        isPublic: quiz.isPublic,
        questions: quiz.questions
            .map((q) => QuestionModel(
                  question: q.question,
                  options: q.options,
                  correctAnswerIndex: q.correctAnswerIndex,
                  difficulty: q.difficulty,
                  timer: q.timer,
                ))
            .toList(),
        category: quiz.category,
      );
      await remoteDataSource.updateQuiz(model);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') return Left(NotFoundFailure(e.message));
      return Left(ServerFailure(e.message));
    } on SocketException catch (_) {
      return Left(const NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteQuiz(String quizId) =>
      safeApiCall('deleteQuiz', () => remoteDataSource.deleteQuiz(quizId));

  @override
  Future<Either<Failure, void>> rateQuiz(String quizId, double rating) =>
      safeApiCall('rateQuiz', () => remoteDataSource.rateQuiz(quizId, rating));

  // --- Helpers for Local Caching ---

  Future<void> _cacheQuizzesLocally(List<QuizModel> quizzes) async {
    try {
      await localDatabase.batch((batch) {
        for (final quiz in quizzes) {
          batch.insert(
            localDatabase.localQuizzes,
            LocalQuiz(
              id: quiz.id,
              title: quiz.title,
              description: quiz.description,
              category: quiz.category,
              isPublic: quiz.isPublic,
              ownerId:
                  '', // Cache-local field; actual ownership enforced by RLS
              creatorName: quiz.creatorName,
              createdAt: DateTime.now(), // Fallback creation time
            ),
            mode: InsertMode.replace,
          );
        }
      });
    } catch (e) {
      // Silently fail caching so as not to disrupt UX
      AppLogger.w('Warning: Failed to cache quizzes locally: $e');
    }
  }

  QuizEntity _mapLocalToQuizEntity(LocalQuiz row) {
    // Note: To fully map back we also need to cache/map Questions.
    // For MVP offline, returning questions as empty or fetching them via joins is ideal.
    return QuizEntity(
      id: row.id,
      title: row.title,
      description: row.description,
      category: row.category ?? 'General',
      isPublic: row.isPublic,
      creatorName: row.creatorName,
      questions: [], // You would inject local questions here via another query
    );
  }
}

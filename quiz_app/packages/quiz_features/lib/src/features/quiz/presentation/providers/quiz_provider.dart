import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/organization_providers.dart';

import 'category_provider.dart';

// Data Source
import 'package:quiz_domain/quiz_domain.dart';

import 'package:quiz_features/quiz_features.dart';



// Repository
final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  throw UnimplementedError('Infrastructure injection required');
});

// UseCases
final getMyQuizzesProvider = Provider<GetMyQuizzes>((ref) {
  return GetMyQuizzes(ref.read(quizRepositoryProvider));
});

final getPublicQuizzesProvider = Provider<GetPublicQuizzes>((ref) {
  return GetPublicQuizzes(ref.read(quizRepositoryProvider));
});

final getQuizDetailsProvider = Provider<GetQuizDetails>((ref) {
  return GetQuizDetails(ref.read(quizRepositoryProvider));
});

final createQuizProvider = Provider<CreateQuiz>((ref) {
  return CreateQuiz(ref.read(quizRepositoryProvider));
});

final updateQuizProvider = Provider<UpdateQuiz>((ref) {
  return UpdateQuiz(ref.read(quizRepositoryProvider));
});

final deleteQuizProvider = Provider<DeleteQuiz>((ref) {
  return DeleteQuiz(ref.read(quizRepositoryProvider));
});

// Presentation Logic (Notifier)
final myQuizzesProvider =
    AsyncNotifierProvider<MyQuizzesNotifier, List<QuizEntity>>(
        MyQuizzesNotifier.new);

final publicQuizzesProvider = FutureProvider<List<QuizEntity>>((ref) async {
  final getPublicQuizzes = ref.read(getPublicQuizzesProvider);
  final result = await getPublicQuizzes(NoParams());
  return result.fold(
    (failure) => throw Exception(failure.message),
    (quizzes) => quizzes,
  );
});

final filteredQuizzesProvider = Provider<AsyncValue<List<QuizEntity>>>((ref) {
  final quizzesAsync = ref.watch(publicQuizzesProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final activeWorkspace = ref.watch(activeWorkspaceProvider);

  return quizzesAsync.whenData((quizzes) {
    var filtered = quizzes;

    // Filter by Workspace (if active workspace is set, only show institutional or public)
    if (activeWorkspace != null) {
      filtered = filtered
          .where((q) => q.organizationId == activeWorkspace.id)
          .toList();
    } else {
      // Personal mode: Show public or ones without organizationId
      filtered = filtered.where((q) => q.organizationId == null).toList();
    }

    // Filter by Category
    if (selectedCategory == 'All') return filtered;
    return filtered.where((q) => q.category == selectedCategory).toList();
  });
});

class MyQuizzesNotifier extends AsyncNotifier<List<QuizEntity>> {
  @override
  Future<List<QuizEntity>> build() async {
    // Reflect active workspace changes
    ref.watch(activeWorkspaceProvider);
    return _fetchQuizzes();
  }

  Future<List<QuizEntity>> _fetchQuizzes() async {
    final getMyQuizzes = ref.read(getMyQuizzesProvider);
    final activeWorkspace = ref.read(activeWorkspaceProvider);

    final result = await getMyQuizzes(NoParams());
    return result.fold(
      (failure) => throw Exception(failure.message),
      (quizzes) {
        if (activeWorkspace != null) {
          return quizzes
              .where((q) => q.organizationId == activeWorkspace.id)
              .toList();
        }
        return quizzes.where((q) => q.organizationId == null).toList();
      },
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchQuizzes());
  }

  Future<void> deleteQuiz(String quizId) async {
    final deleteQuiz = ref.read(deleteQuizProvider);
    final result = await deleteQuiz(quizId);

    await result.fold(
      (failure) async => throw Exception(failure.message),
      (success) async {
        // Optimistic update or refresh
        await refresh();
      },
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_features/quiz_features.dart';

enum QuizEditorStep { identity, workshop, review }

enum QuizRank { novice, adept, master, legend }

class QuizEditorState {
  final QuizEntity quiz;
  final QuizEditorStep step;
  final bool isLoading;
  final String? errorMessage;
  final bool isDirty;
  final int currentQuestionIndex;

  QuizEditorState({
    required this.quiz,
    this.step = QuizEditorStep.identity,
    this.isLoading = false,
    this.errorMessage,
    this.isDirty = false,
    this.currentQuestionIndex = 0,
  });

  QuizEditorState copyWith({
    QuizEntity? quiz,
    QuizEditorStep? step,
    bool? isLoading,
    String? errorMessage,
    bool? isDirty,
    int? currentQuestionIndex,
  }) {
    return QuizEditorState(
      quiz: quiz ?? this.quiz,
      step: step ?? this.step,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isDirty: isDirty ?? this.isDirty,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
    );
  }

  double get strengthScore {
    if (quiz.questions.isEmpty) return 0.0;
    double score = 0;
    // Length bonus (up to 0.4)
    score += (quiz.questions.length / 10).clamp(0.0, 0.4);

    // Content check (up to 0.4)
    final int validQuestions = quiz.questions
        .where((q) =>
            q.question.isNotEmpty &&
            q.options.every((o) => o.isNotEmpty) &&
            q.options.length >= 2)
        .length;
    score += (validQuestions / quiz.questions.length) * 0.4;

    // Media bonus (up to 0.2)
    final int questionsWithImages =
        quiz.questions.where((q) => q.imageUrl != null).length;
    if (quiz.questions.isNotEmpty) {
      score += (questionsWithImages / quiz.questions.length) * 0.2;
    }

    return score.clamp(0.0, 1.0);
  }

  QuizRank get rank {
    final score = strengthScore;
    if (score >= 0.9) return QuizRank.legend;
    if (score >= 0.6) return QuizRank.master;
    if (score >= 0.3) return QuizRank.adept;
    return QuizRank.novice;
  }
}

class QuizEditorNotifier extends FamilyNotifier<QuizEditorState, String?> {
  @override
  QuizEditorState build(String? arg) {
    if (arg != null) {
      _loadQuiz(arg);
    }

    return QuizEditorState(
      quiz: QuizEntity(
        id: arg ?? '',
        title: '',
        isPublic: true,
        category: 'General',
        questions: [
          const QuestionEntity(
            question: '',
            options: ['', '', '', ''],
            correctAnswerIndex: 0,
            difficulty: 'Medium',
            timer: 15,
          )
        ],
      ),
    );
  }

  Future<void> _loadQuiz(String id) async {
    state = state.copyWith(isLoading: true);
    final getQuizDetails = ref.read(getQuizDetailsProvider);
    final result = await getQuizDetails(id);

    result.fold(
      (failure) => state =
          state.copyWith(isLoading: false, errorMessage: failure.message),
      (quiz) => state = state.copyWith(isLoading: false, quiz: quiz),
    );
  }

  void initializeWithQuestions(String title, List<QuestionEntity> questions) {
    state = state.copyWith(
      quiz: QuizEntity(
        id: '',
        title: title,
        isPublic: true,
        category: 'General',
        questions: questions,
      ),
      isDirty: true,
    );
  }

  void updateTitle(String title) {
    state = state.copyWith(
      quiz: QuizEntity(
        id: state.quiz.id,
        title: title,
        description: state.quiz.description,
        isPublic: state.quiz.isPublic,
        category: state.quiz.category,
        questions: state.quiz.questions,
        imageUrl: state.quiz.imageUrl,
        powerUpMode: state.quiz.powerUpMode,
      ),
      isDirty: true,
    );
  }

  void updateCategory(String category) {
    state = state.copyWith(
      quiz: QuizEntity(
        id: state.quiz.id,
        title: state.quiz.title,
        description: state.quiz.description,
        isPublic: state.quiz.isPublic,
        category: category,
        questions: state.quiz.questions,
        imageUrl: state.quiz.imageUrl,
        powerUpMode: state.quiz.powerUpMode,
      ),
      isDirty: true,
    );
  }

  void toggleVisibility(bool isPublic) {
    state = state.copyWith(
      quiz: QuizEntity(
        id: state.quiz.id,
        title: state.quiz.title,
        description: state.quiz.description,
        isPublic: isPublic,
        category: state.quiz.category,
        questions: state.quiz.questions,
        imageUrl: state.quiz.imageUrl,
        powerUpMode: state.quiz.powerUpMode,
      ),
      isDirty: true,
    );
  }

  void setPowerUpMode(String mode) {
    state = state.copyWith(
      quiz: QuizEntity(
        id: state.quiz.id,
        title: state.quiz.title,
        description: state.quiz.description,
        isPublic: state.quiz.isPublic,
        category: state.quiz.category,
        questions: state.quiz.questions,
        imageUrl: state.quiz.imageUrl,
        powerUpMode: mode,
      ),
      isDirty: true,
    );
  }

  void setStep(QuizEditorStep step) {
    state = state.copyWith(step: step);
  }

  void setCurrentQuestion(int index) {
    state = state.copyWith(currentQuestionIndex: index);
  }

  void addQuestion() {
    final newQuestions = List<QuestionEntity>.from(state.quiz.questions)
      ..add(const QuestionEntity(
        question: '',
        options: ['', '', '', ''],
        correctAnswerIndex: 0,
        difficulty: 'Medium',
        timer: 15,
      ));

    state = state.copyWith(
      quiz: QuizEntity(
        id: state.quiz.id,
        title: state.quiz.title,
        description: state.quiz.description,
        isPublic: state.quiz.isPublic,
        category: state.quiz.category,
        questions: newQuestions,
        imageUrl: state.quiz.imageUrl,
      ),
      currentQuestionIndex: newQuestions.length - 1,
      isDirty: true,
    );
  }

  void removeQuestion(int index) {
    if (state.quiz.questions.length <= 1) return;

    final newQuestions = List<QuestionEntity>.from(state.quiz.questions)
      ..removeAt(index);

    int newIndex = state.currentQuestionIndex;
    if (newIndex >= newQuestions.length) {
      newIndex = newQuestions.length - 1;
    }

    state = state.copyWith(
      quiz: QuizEntity(
        id: state.quiz.id,
        title: state.quiz.title,
        description: state.quiz.description,
        isPublic: state.quiz.isPublic,
        category: state.quiz.category,
        questions: newQuestions,
        imageUrl: state.quiz.imageUrl,
      ),
      currentQuestionIndex: newIndex,
      isDirty: true,
    );
  }

  void updateQuestion(int index, QuestionEntity updated) {
    final newQuestions = List<QuestionEntity>.from(state.quiz.questions);
    newQuestions[index] = updated;

    state = state.copyWith(
      quiz: QuizEntity(
        id: state.quiz.id,
        title: state.quiz.title,
        description: state.quiz.description,
        isPublic: state.quiz.isPublic,
        category: state.quiz.category,
        questions: newQuestions,
        imageUrl: state.quiz.imageUrl,
        powerUpMode: state.quiz.powerUpMode,
      ),
      isDirty: true,
    );
  }

  void reorderQuestions(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final newQuestions = List<QuestionEntity>.from(state.quiz.questions);
    final item = newQuestions.removeAt(oldIndex);
    newQuestions.insert(newIndex, item);

    state = state.copyWith(
      quiz: QuizEntity(
        id: state.quiz.id,
        title: state.quiz.title,
        description: state.quiz.description,
        isPublic: state.quiz.isPublic,
        category: state.quiz.category,
        questions: newQuestions,
        imageUrl: state.quiz.imageUrl,
      ),
      currentQuestionIndex: newIndex,
      isDirty: true,
    );
  }

  Future<bool> publish() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final quiz = state.quiz;

    final result = quiz.id.isEmpty
        ? await ref.read(createQuizProvider)(quiz)
        : await ref.read(updateQuizProvider)(quiz);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (success) async {
        state = state.copyWith(isLoading: false, isDirty: false);
        // Refresh the list
        await ref.read(myQuizzesProvider.notifier).refresh();
        return true;
      },
    );
  }
}

final quizEditorProvider =
    NotifierProvider.family<QuizEditorNotifier, QuizEditorState, String?>(
        QuizEditorNotifier.new);

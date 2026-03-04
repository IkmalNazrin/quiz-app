import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:quiz_domain/quiz_domain.dart';

class MockQuizRepository extends Mock implements QuizRepository {}

void main() {
  late MockQuizRepository mockRepository;
  late DeleteQuiz usecase;

  setUp(() {
    mockRepository = MockQuizRepository();
    usecase = DeleteQuiz(mockRepository);
  });

  const tQuizId = 'quiz-xyz';

  test('should call deleteQuiz on repository and return void successfully', () async {
    // Arrange
    when(() => mockRepository.deleteQuiz(any()))
        .thenAnswer((_) async => const Right(null));

    // Act
    final result = await usecase(tQuizId);

    // Assert
    expect(result, const Right(null));
    verify(() => mockRepository.deleteQuiz(tQuizId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return Failure when repository fails to delete', () async {
    // Arrange
    const tFailure = ServerFailure('Entry not found');
    when(() => mockRepository.deleteQuiz(any()))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await usecase(tQuizId);

    // Assert
    expect(result, const Left(tFailure));
  });
}

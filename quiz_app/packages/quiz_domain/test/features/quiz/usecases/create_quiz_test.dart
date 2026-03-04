import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:quiz_domain/quiz_domain.dart';

class MockQuizRepository extends Mock implements QuizRepository {}

void main() {
  late MockQuizRepository mockRepository;
  late CreateQuiz usecase;

  setUp(() {
    mockRepository = MockQuizRepository();
    usecase = CreateQuiz(mockRepository);
  });

  final tQuiz = QuizEntity(
    id: '123',
    title: 'Science Quiz',
    description: 'A quiz about science',
    category: 'Science',
    questions: [],
    isPublic: true,
  );

  test('should forward CreateQuiz call to the repository and return success', () async {
    // Arrange
    when(() => mockRepository.createQuiz(any()))
        .thenAnswer((_) async => const Right(null));

    // Act
    final result = await usecase(tQuiz);

    // Assert
    expect(result, const Right(null));
    verify(() => mockRepository.createQuiz(tQuiz)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return Failure when repository fails to create quiz', () async {
    // Arrange
    const tFailure = ServerFailure('Database Error');
    when(() => mockRepository.createQuiz(any()))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await usecase(tQuiz);

    // Assert
    expect(result, const Left(tFailure));
  });
}

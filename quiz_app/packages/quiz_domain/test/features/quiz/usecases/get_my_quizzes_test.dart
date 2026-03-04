import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:quiz_domain/quiz_domain.dart';

class MockQuizRepository extends Mock implements QuizRepository {}

void main() {
  late MockQuizRepository mockRepository;
  late GetMyQuizzes usecase;

  setUp(() {
    mockRepository = MockQuizRepository();
    usecase = GetMyQuizzes(mockRepository);
  });

  final tQuizzes = [
    QuizEntity(
      id: '1',
      title: 'Math 101',
      description: 'Basic math',
      category: 'Math',
      questions: [],
      isPublic: false,
    ),
    QuizEntity(
      id: '2',
      title: 'History',
      description: 'World history',
      category: 'History',
      questions: [],
      isPublic: true,
    ),
  ];

  test('should get list of quizzes from repository', () async {
    // Arrange
    when(() => mockRepository.getMyQuizzes())
        .thenAnswer((_) async => Right(tQuizzes));

    // Act
    final result = await usecase(NoParams());

    // Assert
    expect(result, Right(tQuizzes));
    verify(() => mockRepository.getMyQuizzes()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return Failure when repository fails', () async {
    // Arrange
    const tFailure = ServerFailure('Failed to load');
    when(() => mockRepository.getMyQuizzes())
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await usecase(NoParams());

    // Assert
    expect(result, const Left(tFailure));
  });
}

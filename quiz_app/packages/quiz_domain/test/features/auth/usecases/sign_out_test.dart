import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:quiz_domain/quiz_domain.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late SignOut usecase;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = SignOut(mockAuthRepository);
  });

  test('should call signOut on the repository successfully', () async {
    // Arrange
    when(() => mockAuthRepository.signOut())
        .thenAnswer((_) async => const Right(null));

    // Act
    final result = await usecase(NoParams());

    // Assert
    expect(result, const Right(null));
    verify(() => mockAuthRepository.signOut()).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('should return Failure when signOut fails', () async {
    // Arrange
    const tFailure = ServerFailure('Network issue');
    when(() => mockAuthRepository.signOut())
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await usecase(NoParams());

    // Assert
    expect(result, const Left(tFailure));
  });
}

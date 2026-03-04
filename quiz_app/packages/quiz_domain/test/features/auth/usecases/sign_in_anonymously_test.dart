import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:quiz_domain/quiz_domain.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late SignInAnonymously usecase;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = SignInAnonymously(mockAuthRepository);
  });

  final tUser = UserEntity(
    id: 'anon123',
    name: 'Guest User',
    isAnonymous: true,
  );

  test('should return UserEntity when anonymous sign in is successful', () async {
    // Arrange
    when(() => mockAuthRepository.signInAnonymously())
        .thenAnswer((_) async => Right(tUser));

    // Act
    final result = await usecase(NoParams());

    // Assert
    expect(result, Right(tUser));
    verify(() => mockAuthRepository.signInAnonymously()).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('should return ServerFailure when anonymous sign in fails', () async {
    // Arrange
    const tFailure = ServerFailure('Server fault');
    when(() => mockAuthRepository.signInAnonymously())
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await usecase(NoParams());

    // Assert
    expect(result, const Left(tFailure));
  });
}

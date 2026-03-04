import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:quiz_domain/quiz_domain.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late SignInWithGoogle usecase;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = SignInWithGoogle(mockAuthRepository);
  });

  const tIdToken = 'dummy_id_token';
  const tAccessToken = 'dummy_access_token';
  final tUser = UserEntity(
    id: 'user123',
    email: 'test@example.com',
    name: 'Test User',
  );

  test('should return UserEntity when sign in is successful', () async {
    // Arrange
    when(() => mockAuthRepository.signInWithGoogle(tIdToken, tAccessToken))
        .thenAnswer((_) async => Right(tUser));

    // Act
    final result = await usecase(
      SignInWithGoogleParams(idToken: tIdToken, accessToken: tAccessToken),
    );

    // Assert
    expect(result, Right(tUser));
    verify(() => mockAuthRepository.signInWithGoogle(tIdToken, tAccessToken)).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('should return AuthFailure when sign in fails', () async {
    // Arrange
    const tFailure = AuthFailure('Invalid token');
    when(() => mockAuthRepository.signInWithGoogle(any(), any()))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await usecase(
      SignInWithGoogleParams(idToken: tIdToken, accessToken: tAccessToken),
    );

    // Assert
    expect(result, const Left(tFailure));
    verify(() => mockAuthRepository.signInWithGoogle(tIdToken, tAccessToken)).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_infrastructure/src/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:quiz_infrastructure/src/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:quiz_infrastructure/src/features/auth/data/models/user_model.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  group('AuthRepositoryImpl', () {
    late AuthRepositoryImpl repository;
    late MockAuthRemoteDataSource mockDataSource;

    setUp(() {
      mockDataSource = MockAuthRemoteDataSource();
      repository = AuthRepositoryImpl(mockDataSource);
    });

    final tUserModel = UserModel(id: '123', email: 'test@test.com', name: 'testuser');

    test('signInAnonymously returns user on success', () async {
      when(() => mockDataSource.signInAnonymously())
          .thenAnswer((_) async => tUserModel);

      final result = await repository.signInAnonymously();

      result.fold<void>(
        (l) { fail('Expected right'); },
        (r) { expect(r, equals(tUserModel)); },
      );
      verify(() => mockDataSource.signInAnonymously()).called(1);
    });

    test('signInAnonymously returns Failure on error', () async {
      when(() => mockDataSource.signInAnonymously())
          .thenThrow(const AuthFailure('Anonymous login failed'));

      final result = await repository.signInAnonymously();
      
      result.fold<void>(
        (l) { expect(l, isA<AuthFailure>()); },
        (r) { fail('Expected left'); },
      );
    });

    test('signOut calls remote data source', () async {
      when(() => mockDataSource.signOut()).thenAnswer((_) async {});

      await repository.signOut();

      verify(() => mockDataSource.signOut()).called(1);
    });
  });
}

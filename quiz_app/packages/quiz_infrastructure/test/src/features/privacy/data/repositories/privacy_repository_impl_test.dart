import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dartz/dartz.dart';

import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_infrastructure/src/features/privacy/data/repositories/privacy_repository_impl.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockUser extends Mock implements User {}

void main() {
  late PrivacyRepositoryImpl repository;
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockAuth;
  late MockUser mockUser;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockUser = MockUser();

    when(() => mockSupabaseClient.auth).thenReturn(mockAuth);

    repository = PrivacyRepositoryImpl(mockSupabaseClient);
  });

  group('exportUserData', () {
    test('should return ServerFailure if user is not authenticated', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final result = await repository.exportUserData();

      expect(result, equals(const Left(ServerFailure('User not authenticated'))));
    });
  });

  group('anonymizeAccount', () {
    test('should return ServerFailure if user is not authenticated', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final result = await repository.anonymizeAccount();

      expect(result, equals(const Left(ServerFailure('User not authenticated'))));
    });
  });
}

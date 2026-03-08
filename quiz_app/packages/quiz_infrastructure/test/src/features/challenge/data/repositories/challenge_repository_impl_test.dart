import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_infrastructure/src/features/challenge/data/datasources/challenge_remote_data_source.dart';
import 'package:quiz_infrastructure/src/features/challenge/data/repositories/challenge_repository_impl.dart';
import 'package:quiz_infrastructure/src/features/challenge/data/models/challenge_model.dart';

class MockChallengeRemoteDataSource extends Mock implements ChallengeRemoteDataSource {}
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}

class FakeChallengeEntity extends Fake implements ChallengeEntity {}

void main() {
  late ChallengeRepositoryImpl repository;
  late MockChallengeRemoteDataSource mockRemoteDataSource;
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockAuthClient;

  final tChallenge = ChallengeModel(
    id: 'test_challenge_123',
    quizTitle: 'Test Quiz',
    status: 'pending',
    challengeType: '1v1',
    challengerId: 'challenger_uid',
    challengerUsername: 'challenger',
    challengerScore: 100,
    opponentUsername: 'opponent',
    opponentScore: 0,
    createdAt: DateTime(2023, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(tChallenge);
  });

  setUp(() {
    mockRemoteDataSource = MockChallengeRemoteDataSource();
    mockSupabaseClient = MockSupabaseClient();
    mockAuthClient = MockGoTrueClient();

    when(() => mockSupabaseClient.auth).thenReturn(mockAuthClient);
    when(() => mockAuthClient.currentUser).thenReturn(User(
        id: 'user123',
        appMetadata: {},
        userMetadata: {'username': 'testuser'},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
    ));

    repository = ChallengeRepositoryImpl(mockRemoteDataSource, mockSupabaseClient);
  });

  group('getChallengeById', () {
    test('should return remote data when the call to remote data source is successful', () async {
      when(() => mockRemoteDataSource.getChallengeById(any()))
          .thenAnswer((_) async => tChallenge);

      final result = await repository.getChallengeById('test_challenge_123');

      verify(() => mockRemoteDataSource.getChallengeById('test_challenge_123'));
      result.fold(
        (failure) => fail('Should not return failure'),
        (challenge) => expect(challenge.id, tChallenge.id),
      );
    });

    test('should return ServerFailure when an AuthException occurs', () async {
      when(() => mockRemoteDataSource.getChallengeById(any()))
          .thenThrow(const AuthException('Auth Error'));

      final result = await repository.getChallengeById('test_challenge_123');

      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (challenge) => fail('Should not return right'),
      );
    });

    test('should return NotFoundFailure when a PGRST116 PostgrestException occurs (row not found)', () async {
      when(() => mockRemoteDataSource.getChallengeById(any()))
          .thenThrow(const PostgrestException(message: 'Not found', code: 'PGRST116'));

      final result = await repository.getChallengeById('test_challenge_123');

      result.fold(
        (failure) => expect(failure, isA<NotFoundFailure>()),
        (challenge) => fail('Should not return right'),
      );
    });

    test('should return NetworkFailure when a SocketException occurs', () async {
      when(() => mockRemoteDataSource.getChallengeById(any()))
          .thenThrow(const SocketException('Failed host lookup'));

      final result = await repository.getChallengeById('test_challenge_123');

      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (challenge) => fail('Should not return right'),
      );
    });
  });

  group('getMyChallenges', () {
    test('should return remote data when successful', () async {
      when(() => mockRemoteDataSource.getMyChallenges())
          .thenAnswer((_) async => <ChallengeModel>[tChallenge]);

      final result = await repository.getMyChallenges();

      verify(() => mockRemoteDataSource.getMyChallenges());
      result.fold(
        (failure) => fail('Should not return failure'),
        (challenges) {
          expect(challenges.length, 1);
          expect(challenges.first.id, tChallenge.id);
        },
      );
    });
  });

  group('createChallenge', () {
    test('should return void when the creation is successful', () async {
      when(() => mockRemoteDataSource.createChallenge(any()))
          .thenAnswer((_) async => Future.value());

      final result = await repository.createChallenge(tChallenge);

      verify(() => mockRemoteDataSource.createChallenge(tChallenge));
      expect(result, equals(const Right(null)));
    });
  });

  group('completeChallenge', () {
    test('should return void when completion is successful', () async {
      when(() => mockRemoteDataSource.completeChallenge(any(), any()))
          .thenAnswer((_) async => Future.value());

      final result = await repository.completeChallenge('test_challenge_123', 500);

      verify(() => mockRemoteDataSource.completeChallenge('test_challenge_123', 500));
      expect(result, equals(const Right(null)));
    });
  });

  group('sendChallenge', () {
    test('should extract current user and map arguments to ChallengeEntity before passing to remote creation', () async {
      when(() => mockRemoteDataSource.createChallenge(any()))
          .thenAnswer((_) async => Future.value());

      final result = await repository.sendChallenge(
          quizId: 'Quiz 1',
          opponentUsername: 'Opponent X',
          challengerScore: 400
      );

      verify(() => mockRemoteDataSource.createChallenge(any()));
      expect(result, equals(const Right(null)));
    });

    test('should return AuthFailure when current user is null', () async {
      when(() => mockAuthClient.currentUser).thenReturn(null);

      final result = await repository.sendChallenge(
          quizId: 'Quiz 1',
          opponentUsername: 'Opponent X',
          challengerScore: 400
      );

      expect(result, equals(const Left(AuthFailure('Not authenticated'))));
    });
  });
}

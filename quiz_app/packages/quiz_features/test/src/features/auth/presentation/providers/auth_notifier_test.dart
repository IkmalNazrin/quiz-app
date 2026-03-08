import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_features/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:quiz_ui_core/quiz_ui_core.dart'; 

class MockGetCurrentUser extends Mock implements GetCurrentUser {}
class MockSignInWithGoogle extends Mock implements SignInWithGoogle {}
class MockSignInWithGoogleNative extends Mock implements SignInWithGoogleNative {}
class MockSignInAnonymously extends Mock implements SignInAnonymously {}
class MockSignOut extends Mock implements SignOut {}
class MockAuthRepository extends Mock implements AuthRepository {}
class MockSyncProfile extends Mock implements SyncProfile {}
class MockSignInWithSSO extends Mock implements SignInWithSSO {}

class FakeUserEntity extends Fake implements UserEntity {}

void main() {
  late AuthNotifier notifier;
  late MockGetCurrentUser mockGetCurrentUser;
  late MockSignInWithGoogle mockSignInWithGoogle;
  late MockSignInWithGoogleNative mockSignInWithGoogleNative;
  late MockSignInAnonymously mockSignInAnonymously;
  late MockSignOut mockSignOut;
  late MockAuthRepository mockAuthRepository;
  late MockSyncProfile mockSyncProfile;
  late MockSignInWithSSO mockSignInWithSSO;
  late StreamController<UserEntity?> authStateController;

  final tUser = const UserEntity(
    id: 'test_uid',
    email: 'test@example.com',
    name: 'tester',
    isAnonymous: false,
    role: UserRole.player,
  );

  setUpAll(() {
    registerFallbackValue(NoParams());
    registerFallbackValue(SignInWithGoogleParams(idToken: '', accessToken: ''));
    registerFallbackValue(FakeUserEntity());
  });

  setUp(() {
    mockGetCurrentUser = MockGetCurrentUser();
    mockSignInWithGoogle = MockSignInWithGoogle();
    mockSignInWithGoogleNative = MockSignInWithGoogleNative();
    mockSignInAnonymously = MockSignInAnonymously();
    mockSignOut = MockSignOut();
    mockAuthRepository = MockAuthRepository();
    mockSyncProfile = MockSyncProfile();
    mockSignInWithSSO = MockSignInWithSSO();
    authStateController = StreamController<UserEntity?>.broadcast();

    when(() => mockAuthRepository.authStateChanges)
        .thenAnswer((_) => authStateController.stream);

    when(() => mockGetCurrentUser(any()))
        .thenAnswer((_) async => const Left(ServerFailure('No session')));

    notifier = AuthNotifier(
      mockGetCurrentUser,
      mockSignInWithGoogle,
      mockSignInWithGoogleNative,
      mockSignInAnonymously,
      mockSignOut,
      mockAuthRepository,
      mockSyncProfile,
      mockSignInWithSSO,
    );
  });

  tearDown(() {
    authStateController.close();
  });

  group('initialization', () {
    test('should start in loading state and eventually transition to user on success', () async {
      when(() => mockGetCurrentUser(any())).thenAnswer((_) async => Right(tUser));
      when(() => mockSyncProfile(any())).thenAnswer((_) async => const Right(null));

      final testNotifier = AuthNotifier(
          mockGetCurrentUser, mockSignInWithGoogle, mockSignInWithGoogleNative, mockSignInAnonymously, mockSignOut, mockAuthRepository, mockSyncProfile, mockSignInWithSSO);
      
      expect(testNotifier.state.isLoading, true);
      
      await Future.delayed(Duration.zero);
      
      expect(testNotifier.state.hasValue, true);
      expect(testNotifier.state.value, tUser);
    });
  });

  group('listenToAuthState', () {
    test('should update state to null when auth state changes emit null', () async {
      await Future.delayed(Duration.zero);
      
      authStateController.add(null);
      await Future.delayed(Duration.zero);
      
      expect(notifier.state.value, isNull);
    });

    test('should refresh current user and sync profile when auth state emits user', () async {
      await Future.delayed(Duration.zero);
      
      when(() => mockGetCurrentUser(any())).thenAnswer((_) async => Right(tUser));
      when(() => mockSyncProfile(any())).thenAnswer((_) async => const Right(null));

      authStateController.add(tUser);
      await Future.delayed(const Duration(milliseconds: 100));

      verify(() => mockGetCurrentUser(any())).called(greaterThan(0));
      verify(() => mockSyncProfile(tUser)).called(1);
      expect(notifier.state.value, tUser);
    });
  });

  group('signIn', () {
    test('should update state to data on successful Google sign-in (server flow)', () async {
      when(() => mockSignInWithGoogle(any())).thenAnswer((_) async => Right(tUser));

      final future = notifier.signIn('id_token', 'access_token');
      expect(notifier.state.isLoading, true);
      
      await future;
      
      verify(() => mockSignInWithGoogle(any(that: isA<SignInWithGoogleParams>())));
      expect(notifier.state.value, tUser);
    });

    test('should update state to error on failure', () async {
      when(() => mockSignInWithGoogle(any())).thenAnswer((_) async => const Left(ServerFailure('Failed')));

      await notifier.signIn('id_token', 'access_token');
      
      expect(notifier.state.hasError, true);
    });
  });

  group('signInAnonymously', () {
    test('should update state to data on successful anonymous sign-in', () async {
      when(() => mockSignInAnonymously(any())).thenAnswer((_) async => Right(tUser));

      await notifier.signInAnonymously();
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      verify(() => mockSignInAnonymously(any()));
      expect(notifier.state.value, tUser);
    });
  });

  group('signInWithSSO', () {
    test('should call SSO sign in', () async {
      when(() => mockSignInWithSSO(any())).thenAnswer((_) async => const Right(null));

      final future = notifier.signInWithSSO('test@org.com');
      expect(notifier.state.isLoading, true);
      
      await future;
      
      verify(() => mockSignInWithSSO('test@org.com'));
      // Does not change user data state directly; depends on redirect listeners usually
    });
  });

  group('signOut', () {
    test('should call signOut usecase and set state to null', () async {
      when(() => mockSignOut(any())).thenAnswer((_) async => const Right(null));

      final future = notifier.signOut();
      expect(notifier.debugState.isLoading, true);
      
      await future;
      
      verify(() => mockSignOut(any()));
      expect(notifier.debugState.value, isNull);
    });
  });
}

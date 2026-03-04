import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import '../../../profile/presentation/providers/profile_provider.dart';

// Data Source
import 'package:quiz_domain/quiz_domain.dart';

import 'package:quiz_ui_core/quiz_ui_core.dart';
import 'package:quiz_features/quiz_features.dart';



// Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError('Infrastructure injection required');
});

// UseCases
final signInWithGoogleProvider = Provider<SignInWithGoogle>((ref) {
  return SignInWithGoogle(ref.read(authRepositoryProvider));
});

final signInWithGoogleNativeProvider = Provider<SignInWithGoogleNative>((ref) {
  return SignInWithGoogleNative(ref.read(authRepositoryProvider));
});

final signInAnonymouslyProvider = Provider<SignInAnonymously>((ref) {
  return SignInAnonymously(ref.read(authRepositoryProvider));
});

final signOutProvider = Provider<SignOut>((ref) {
  return SignOut(ref.read(authRepositoryProvider));
});

final getCurrentUserProvider = Provider<GetCurrentUser>((ref) {
  return GetCurrentUser(ref.read(authRepositoryProvider));
});

final syncProfileProvider = Provider<SyncProfile>((ref) {
  return SyncProfile(ref.read(profileRepositoryProvider));
});

final signInWithSSOProvider = Provider<SignInWithSSO>((ref) {
  return SignInWithSSO(ref.read(authRepositoryProvider));
});

// Auth State Provider (AsyncValue<UserEntity?>)
final authStateProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserEntity?>>((ref) {
  return AuthNotifier(
    ref.read(getCurrentUserProvider),
    ref.read(signInWithGoogleProvider),
    ref.read(signInWithGoogleNativeProvider),
    ref.read(signInAnonymouslyProvider),
    ref.read(signOutProvider),
    ref.read(authRepositoryProvider),
    ref.read(syncProfileProvider),
    ref.read(signInWithSSOProvider),
  );
});

class AuthNotifier extends StateNotifier<AsyncValue<UserEntity?>> {
  final GetCurrentUser _getCurrentUser;
  final SignInWithGoogle _signInWithGoogle;
  final SignInWithGoogleNative _signInWithGoogleNative;
  final SignInAnonymously _signInAnonymously;
  final SignOut _signOut;
  final AuthRepository _authRepository;
  final SyncProfile _syncProfile;
  final SignInWithSSO _signInWithSSO;
  late final Throttler _authThrottler;

  AuthNotifier(
    this._getCurrentUser,
    this._signInWithGoogle,
    this._signInWithGoogleNative,
    this._signInAnonymously,
    this._signOut,
    this._authRepository,
    this._syncProfile,
    this._signInWithSSO,
  ) : super(const AsyncValue.loading()) {
    _authThrottler = Throttler(delay: const Duration(seconds: 5));
    checkUserSession();
    _listenToAuthState();
  }

  void _listenToAuthState() {
    _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        checkUserSession(); // Refresh our state
      } else {
        state = const AsyncValue.data(null);
      }
    });
  }

  Future<void> checkUserSession() async {
    final result = await _getCurrentUser(NoParams());
    result.fold(
      (failure) => state = const AsyncValue.data(null),
      (user) async {
        state = AsyncValue.data(user);
        // Sync profile
        final syncResult = await _syncProfile(user);
        syncResult.fold(
          (failure) => AppLogger.e("Profile sync failed: ${failure.message}", category: LogCategory.system),
          (_) => AppLogger.i("Profile sync: Success for user ${user.id}", category: LogCategory.system),
        );
      },
    );
  }

  Future<void> signIn(String idToken, String accessToken) async {
    state = const AsyncValue.loading();
    final result = await _signInWithGoogle(
        SignInWithGoogleParams(idToken: idToken, accessToken: accessToken));
    result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (user) {
        state = AsyncValue.data(user);
      },
    );
  }

  Future<void> signInWithGoogle() async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS &&
            defaultTargetPlatform != TargetPlatform.macOS)) {
      state = const AsyncValue.loading();
      final result = await _signInWithGoogleNative(NoParams());
      result.fold(
        (failure) =>
            state = AsyncValue.error(failure.message, StackTrace.current),
        (_) {
          // Web/Desktop usually redirects or opens a browser, listener handles returns.
        },
      );
    } else {
      // For mobile, the old flow still applies but needs to be triggered from UI
      // We'll keep this as a reminder or implement the full wrapper here
    }
  }

  Future<void> signInAnonymously() async {
    _authThrottler.run(() async {
      state = const AsyncValue.loading();
      final result = await _signInAnonymously(NoParams());
      result.fold(
        (failure) {
          state = AsyncValue.error(failure.message, StackTrace.current);
        },
        (user) {
          state = AsyncValue.data(user);
        },
      );
    });
  }

  Future<void> signInWithSSO(String emailOrSlug) async {
    state = const AsyncValue.loading();
    final result = await _signInWithSSO(emailOrSlug);
    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (_) {
        // Redirect handled by Supabase SSO
      },
    );
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    await _signOut(NoParams());
    state = const AsyncValue.data(null);
  }
}

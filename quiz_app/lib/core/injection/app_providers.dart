import 'package:flutter_riverpod/flutter_riverpod.dart';

// ARCHITECTURE NOTE: This is the DI Composition Root. Direct vendor
// imports (e.g., supabase_flutter) are permitted HERE ONLY.
// See ARCHITECTURE.md §Architectural Boundaries.
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_infrastructure/quiz_infrastructure.dart';
import 'package:quiz_features/quiz_features.dart';

// ----------------------------------------------------------------------
// PRIVATE INFRASTRUCTURE PROVIDERS
// (Not exposed to UI feature layers)
// ----------------------------------------------------------------------

final supabaseClientProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);
final appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase());
final vaultServiceProvider = Provider<VaultService>((ref) => VaultService(ref.read(supabaseClientProvider)));

final rateLimiterProvider = Provider<RateLimiter>((ref) => RateLimiter(
  maxTokens: 30,
  refillInterval: const Duration(seconds: 1),
));

final apiClientProvider = Provider<RateLimitedApiClient>((ref) => RateLimitedApiClient(
  ref.read(supabaseClientProvider),
  ref.read(rateLimiterProvider),
));

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) => AuthRemoteDataSourceImpl(ref.read(apiClientProvider).rawClient));
final organizationRemoteDataSourceProvider = Provider<OrganizationRemoteDataSource>((ref) => OrganizationRemoteDataSourceImpl(ref.read(apiClientProvider).rawClient));
final quizRemoteDataSourceProvider = Provider<QuizRemoteDataSource>((ref) => QuizRemoteDataSourceImpl(apiClient: ref.read(apiClientProvider)));
final challengeRemoteDataSourceProvider = Provider<ChallengeRemoteDataSource>((ref) => ChallengeRemoteDataSourceImpl(apiClient: ref.read(apiClientProvider)));
final leaderboardRemoteDataSourceProvider = Provider<LeaderboardRemoteDataSource>((ref) => LeaderboardRemoteDataSourceImpl(ref.read(apiClientProvider).rawClient));
final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) => ProfileRemoteDataSourceImpl(ref.read(apiClientProvider).rawClient));

// ----------------------------------------------------------------------
// PUBLIC FEATURE PROVIDER OVERRIDES
// (These inject infrastructure implementations into the UI layer)
// ----------------------------------------------------------------------

final appProviderOverrides = <Override>[
  gameRealtimeServiceProvider.overrideWith((ref) {
    final service = GameRealtimeService(ref.read(supabaseClientProvider));
    ref.onDispose(() => service.dispose());
    return service;
  }),
  connectivityServiceProvider.overrideWith((ref) {
    final service = ConnectivityService();
    ref.onDispose(() => service.dispose());
    return service;
  }),
  syncQueueServiceProvider.overrideWith((ref) => SyncQueueService(
    ref.read(supabaseClientProvider),
    ref.read(connectivityServiceProvider),
    ref.read(appDatabaseProvider),
  )),
  authRepositoryProvider.overrideWith(
    (ref) => AuthRepositoryImpl(ref.read(authRemoteDataSourceProvider)),
  ),
  organizationRepositoryProvider.overrideWith(
    (ref) => OrganizationRepositoryImpl(ref.read(organizationRemoteDataSourceProvider)),
  ),
  quizRepositoryProvider.overrideWith(
    (ref) => QuizRepositoryImpl(
      ref.read(quizRemoteDataSourceProvider),
      ref.read(appDatabaseProvider),
    ),
  ),
  hostGameEngineFactoryProvider.overrideWith(
    (ref) => (QuizEntity quiz, int? timerOverride) {
      return OnlineHostGameEngine(
        supabaseClient: ref.read(supabaseClientProvider),
        realtimeService: ref.read(gameRealtimeServiceProvider),
        quiz: quiz,
        timerOverride: timerOverride,
      );
    },
  ),
  gameRepositoryProvider.overrideWith(
    (ref) => GameRepositoryImpl(ref.read(supabaseClientProvider), ref.read(gameRealtimeServiceProvider)),
  ),
  challengeRepositoryProvider.overrideWith(
    (ref) => ChallengeRepositoryImpl(ref.read(challengeRemoteDataSourceProvider), ref.read(supabaseClientProvider)),
  ),
  leaderboardRepositoryProvider.overrideWith(
    (ref) => LeaderboardRepositoryImpl(ref.read(leaderboardRemoteDataSourceProvider)),
  ),
  profileRepositoryProvider.overrideWith(
    (ref) => ProfileRepositoryImpl(ref.read(profileRemoteDataSourceProvider)),
  ),
  historyRepositoryProvider.overrideWith(
    (ref) => HistoryRepositoryImpl(ref.read(supabaseClientProvider)),
  ),
  privacyRepositoryProvider.overrideWith(
    (ref) => PrivacyRepositoryImpl(ref.read(supabaseClientProvider)),
  ),
  aiGatewayProvider.overrideWith(
    (ref) => GeminiAIGateway(ref.read(vaultServiceProvider)),
  ),
  analyticsRepositoryProvider.overrideWith(
    (ref) => SupabaseAnalyticsRepository(ref.read(supabaseClientProvider)),
  ),
  offlineSyncRepositoryProvider.overrideWith(
    (ref) => DriftOfflineSyncRepository(ref.read(appDatabaseProvider)),
  ),
  offlineQuizRepositoryProvider.overrideWith(
    (ref) => OfflineQuizRepository(ref.read(appDatabaseProvider)),
  ),
  storageServiceProvider.overrideWith(
    (ref) => SupabaseStorageService(ref.read(supabaseClientProvider)),
  ),
  legalRepositoryProvider.overrideWith(
    (ref) => LegalRepositoryImpl(),
  ),
];

/// Validates that all DI overrides for UnimplementedError stubs are wired.
/// Call this in main.dart after the ProviderScope is created.
/// This catches misconfiguration at app launch in debug mode instead of crashing at runtime.
void assertDIComplete(ProviderContainer container) {
  assert(() {
    final requiredProviders = [
      legalRepositoryProvider,
      offlineSyncRepositoryProvider,
      storageServiceProvider,
      gameRealtimeServiceProvider,
      connectivityServiceProvider,
      hostGameEngineFactoryProvider,
      syncQueueServiceProvider,
      gameRepositoryProvider,
      authRepositoryProvider,
      organizationRepositoryProvider,
      quizRepositoryProvider,
      profileRepositoryProvider,
      historyRepositoryProvider,
      analyticsRepositoryProvider,
      privacyRepositoryProvider,
      challengeRepositoryProvider,
      leaderboardRepositoryProvider,
      aiGatewayProvider,
      offlineQuizRepositoryProvider,
    ];

    for (final provider in requiredProviders) {
      try {
        container.read(provider);
      } catch (e) {
        if (e is UnimplementedError) {
          throw StateError('CRITICAL: Missing DI override for $provider. The app will crash if this feature is used.');
        } else {
          // Other errors during read (e.g. initialization errors) are fine for this check
        }
      }
    }
    return true;
  }());
}

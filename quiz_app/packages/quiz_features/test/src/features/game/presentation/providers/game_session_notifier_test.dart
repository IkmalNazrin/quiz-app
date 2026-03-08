import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_features/src/features/game/presentation/providers/game_session_provider.dart';
import 'package:quiz_ui_core/quiz_ui_core.dart';

class MockGameRepository extends Mock implements GameRepository {}
class MockGameRealtimeService extends Mock implements IGameRealtimeService {}
class MockQuizRepository extends Mock implements QuizRepository {}
class MockAuthRepository extends Mock implements AuthRepository {}
class MockNetworkInfo extends Mock implements NetworkInfoInterface {}
class MockSyncQueueService extends Mock implements ISyncQueueService {}
class MockHostGameEngine extends Mock implements HostGameEngine {}

void main() {
  late MockGameRepository mockRepository;
  late MockGameRealtimeService mockRealtimeService;
  late MockQuizRepository mockQuizRepository;
  late MockAuthRepository mockAuthRepository;
  late MockNetworkInfo mockNetworkInfo;
  late MockSyncQueueService mockSyncQueueService;
  late GameSessionNotifier notifier;

  final testUser = const UserEntity(
    id: 'host_123',
    email: 'host@test.com',
    role: UserRole.host,
  );

  final testGameSession = GameEntity(
    status: 'lobby',
    socketStatus: 'connected',
    gamePin: '123456',
    hostId: 'host_123',
    quizId: 'quiz_abc',
    players: [],
    powerUpMode: 'classic',
  );

  setUp(() {
    mockRepository = MockGameRepository();
    mockRealtimeService = MockGameRealtimeService();
    mockQuizRepository = MockQuizRepository();
    mockAuthRepository = MockAuthRepository();
    mockNetworkInfo = MockNetworkInfo();
    mockSyncQueueService = MockSyncQueueService();

    // Default stream behaviors
    when(() => mockRealtimeService.playersStream)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockRealtimeService.eventsStream)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockSyncQueueService.isSyncingStream)
        .thenAnswer((_) => const Stream.empty());

    // Default mock returns
    when(() => mockAuthRepository.getCurrentUser())
        .thenAnswer((_) async => Right(testUser));
    when(() => mockNetworkInfo.isOnline)
        .thenAnswer((_) async => true);

    notifier = GameSessionNotifier(
      mockRepository,
      mockRealtimeService,
      mockQuizRepository,
      mockAuthRepository,
      mockNetworkInfo,
      mockSyncQueueService,
      (quiz, timerOverride) => MockHostGameEngine(),
    );
  });

  group('GameSessionNotifier Initialization', () {
    test('starts with initial connected state and empty players', () {
      expect(notifier.state.socketStatus, 'connected');
      expect(notifier.state.players.isEmpty, isTrue);
    });
  });

  group('GameSessionNotifier Host Game', () {
    test('successfully hosts a game and updates state', () async {
      when(() => mockRepository.hostGame(any(), any(), any()))
          .thenAnswer((_) async => testGameSession);

      await notifier.hostGame('HostName', 'quiz_abc', 'token123');
      
      // Delay to let throttler execute the microtask
      await Future.delayed(const Duration(milliseconds: 100));

      expect(notifier.state.gamePin, '123456');
      expect(notifier.state.quizId, 'quiz_abc');
      expect(notifier.state.hostId, 'host_123');
      verify(() => mockRepository.hostGame('HostName', 'quiz_abc', 'token123')).called(1);
    });
  });

  group('GameSessionNotifier Join Game', () {
    test('successfully joins a game when logged in', () async {
      when(() => mockAuthRepository.isLoggedIn())
          .thenAnswer((_) async => true);
      
      final joinSession = testGameSession.copyWith(hostId: 'someone_else');
      when(() => mockRepository.joinGame(any(), any(), any()))
          .thenAnswer((_) async => joinSession);

      await notifier.joinGame('Player1', '123456', null);

      expect(notifier.state.gamePin, '123456');
      expect(notifier.state.socketStatus, 'connected');
      verify(() => mockRepository.joinGame('Player1', '123456', null)).called(1);
      verifyNever(() => mockAuthRepository.signInAnonymously());
    });

    test('signs in anonymously if not logged in before joining', () async {
      when(() => mockAuthRepository.isLoggedIn())
          .thenAnswer((_) async => false);
      when(() => mockAuthRepository.signInAnonymously())
          .thenAnswer((_) async => Right(testUser));
          
      final joinSession = testGameSession.copyWith(hostId: 'someone_else');
      when(() => mockRepository.joinGame(any(), any(), any()))
          .thenAnswer((_) async => joinSession);

      await notifier.joinGame('Player1', '123456', null);

      verify(() => mockAuthRepository.signInAnonymously()).called(1);
      verify(() => mockRepository.joinGame('Player1', '123456', null)).called(1);
    });
  });

  group('GameSessionNotifier Lifecycle', () {
    test('disconnect clears state', () async {
      when(() => mockRepository.disconnect()).thenAnswer((_) async {});
      
      await notifier.disconnect();
      
      expect(notifier.state.status, 'initial');
      expect(notifier.state.socketStatus, 'disconnected');
      verify(() => mockRepository.disconnect()).called(1);
    });
  });
}

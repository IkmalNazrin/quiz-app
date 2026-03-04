import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quiz_infrastructure/src/features/analytics/data/repositories/supabase_analytics_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  late SupabaseAnalyticsRepository repository;
  late MockSupabaseClient mockClient;

  setUp(() {
    mockClient = MockSupabaseClient();
    repository = SupabaseAnalyticsRepository(mockClient);
  });

  group('SupabaseAnalyticsRepository', () {
    test('getHostStats calls rpc get_host_analytics_summary', () async {
      when(() => mockClient.rpc(
            'get_host_analytics_summary',
            params: any(named: 'params'),
          )).thenAnswer((_) => Future.value({'total_games': 5}) as dynamic);

      final result = await repository.getHostStats('host-123');
      
      expect(result['total_games'], 5);
      verify(() => mockClient.rpc(
        'get_host_analytics_summary', 
        params: {'host_uuid': 'host-123'}
      )).called(1);
    });

    test('getQuizStats calls rpc get_quiz_analytics_detailed', () async {
      when(() => mockClient.rpc(
            'get_quiz_analytics_detailed',
            params: any(named: 'params'),
          )).thenAnswer((_) => Future.value({'average_score': 850}) as dynamic);

      final result = await repository.getQuizStats('quiz-456');
      
      expect(result['average_score'], 850);
      verify(() => mockClient.rpc(
        'get_quiz_analytics_detailed', 
        params: {'quiz_uuid': 'quiz-456'}
      )).called(1);
    });
  });
}

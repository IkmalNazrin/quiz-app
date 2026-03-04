import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quiz_infrastructure/src/core_infrastructure/services/vault_service.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class FakePostgrestFilterBuilder<T> extends Fake implements PostgrestFilterBuilder<T> {
  final Future<T> _future;
  FakePostgrestFilterBuilder(this._future);

  @override
  Future<R> then<R>(FutureOr<R> Function(T value) onValue, {Function? onError}) {
    return _future.then(onValue, onError: onError);
  }

  @override
  Future<T> catchError(Function onError, {bool Function(Object error)? test}) {
    return _future.catchError(onError, test: test);
  }

  @override
  Future<T> whenComplete(FutureOr<void> Function() action) => _future.whenComplete(action);

  @override
  Future<T> timeout(Duration timeLimit, {FutureOr<T> Function()? onTimeout}) =>
      _future.timeout(timeLimit, onTimeout: onTimeout);

  @override
  Stream<T> asStream() => _future.asStream();
}

void main() {
  setUpAll(() {
    registerFallbackValue({'p_secret_name': 'fallback'});
  });

  group('VaultService', () {
    late VaultService service;
    late MockSupabaseClient mockSupabase;

    setUp(() {
      mockSupabase = MockSupabaseClient();
      service = VaultService(mockSupabase);
    });

    test('getSecret returns decrypted string on success', () async {
      when(() => mockSupabase.rpc('fn_get_decrypted_secret', params: any(named: 'params')))
          .thenAnswer((_) => FakePostgrestFilterBuilder<dynamic>(Future.value('decrypted_value')));

      final result = await service.getSecret('TEST_KEY');
      expect(result, equals('decrypted_value'));
    });

    test('getSecret returns null and logs error on failure', () async {
      when(() => mockSupabase.rpc('fn_get_decrypted_secret', params: any(named: 'params')))
          .thenAnswer((_) => FakePostgrestFilterBuilder<dynamic>(Future.error(const PostgrestException(message: 'Not found'))));

      final result = await service.getSecret('BAD_KEY');
      expect(result, isNull);
    });

    test('getAiOrchestratorKey delegates to getSecret', () async {
      when(() => mockSupabase.rpc('fn_get_decrypted_secret', params: any(named: 'params')))
          .thenAnswer((_) => FakePostgrestFilterBuilder<dynamic>(Future.value('ai_key')));

      final result = await service.getAiOrchestratorKey();
      expect(result, equals('ai_key'));
    });
  });
}

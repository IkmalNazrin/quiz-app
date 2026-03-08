import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_infrastructure/src/core_infrastructure/services/circuit_breaker.dart';

void main() {
  late CircuitBreaker circuitBreaker;

  setUp(() {
    circuitBreaker = CircuitBreaker(
      serviceName: 'TestService',
      failureThreshold: 2,
      resetTimeout: const Duration(milliseconds: 100),
    );
  });

  test('should succeed and keep circuit closed', () async {
    final result = await circuitBreaker.execute(() async => 'success');
    
    expect(result, 'success');
    expect(circuitBreaker.state, CircuitState.closed);
  });

  test('should open circuit after failureThreshold is reached', () async {
    Future<String> failingOp() async => throw Exception('error');

    // 1st failure
    try {
      await circuitBreaker.execute(failingOp);
    } catch (_) {}
    // It should remain closed after only 1 failure when threshold is 2
    expect(circuitBreaker.state, CircuitState.closed);

    // 2nd failure - hits threshold
    try {
      await circuitBreaker.execute(failingOp);
    } catch (_) {}
    // It should now be open
    expect(circuitBreaker.state, CircuitState.open);
  });

  test('should fast-fail when circuit is open before timeout', () async {
    Future<String> failingOp() async => throw Exception('error');

    // Trip circuit
    try { await circuitBreaker.execute(failingOp); } catch (_) {}
    try { await circuitBreaker.execute(failingOp); } catch (_) {}
    expect(circuitBreaker.state, CircuitState.open);

    // Act & Assert fast-fail without calling the inner function
    bool innerFunctionCalled = false;
    
    expect(
      () => circuitBreaker.execute(() async {
        innerFunctionCalled = true;
        return 'success';
      }),
      throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('temporarily unavailable'))),
    );
    expect(innerFunctionCalled, false);
  });

  test('should recover to closed after timeout and successful execution', () async {
    Future<String> failingOp() async => throw Exception('error');

    // Trip circuit
    try { await circuitBreaker.execute(failingOp); } catch (_) {}
    try { await circuitBreaker.execute(failingOp); } catch (_) {}
    expect(circuitBreaker.state, CircuitState.open);

    // Wait for resetTimeout to expire
    await Future.delayed(const Duration(milliseconds: 150));

    // Execute success
    final result = await circuitBreaker.execute(() async => 'recovered');
    
    expect(result, 'recovered');
    // Should completely reset success state back to closed
    expect(circuitBreaker.state, CircuitState.closed);
  });

  test('should trip back to open if failure happens during half-open recovery', () async {
    Future<String> failingOp() async => throw Exception('error');

    // Trip circuit
    try { await circuitBreaker.execute(failingOp); } catch (_) {}
    try { await circuitBreaker.execute(failingOp); } catch (_) {}
    expect(circuitBreaker.state, CircuitState.open);

    // Wait for resetTimeout to expire
    await Future.delayed(const Duration(milliseconds: 150));

    // Execute failure while in half-open state testing
    try { await circuitBreaker.execute(failingOp); } catch (_) {}
    
    // Should re-trip to open because _failureCount becomes 3 which is >= 2
    expect(circuitBreaker.state, CircuitState.open);
  });
}

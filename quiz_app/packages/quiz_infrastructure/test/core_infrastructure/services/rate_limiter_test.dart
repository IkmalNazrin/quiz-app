import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_infrastructure/src/core_infrastructure/services/rate_limiter.dart';

void main() {
  group('RateLimiter', () {
    test('consumes tokens correctly', () {
      final limiter = RateLimiter(maxTokens: 3, refillInterval: const Duration(seconds: 1));
      
      expect(limiter.consume(), isTrue);
      expect(limiter.consume(), isTrue);
      expect(limiter.consume(), isTrue);
      expect(limiter.consume(), isFalse); // Empty bucket
    });

    test('refills tokens over time', () async {
      final limiter = RateLimiter(maxTokens: 2, refillInterval: const Duration(milliseconds: 100));
      
      limiter.consume();
      limiter.consume();
      expect(limiter.consume(), isFalse);

      await Future.delayed(const Duration(milliseconds: 150));
      expect(limiter.consume(), isTrue);
    });

    test('throttle prevents rapid execution', () {
      int callCount = 0;

      final action = RateLimiter.throttle<void>(
        (_) => callCount++,
        duration: const Duration(milliseconds: 50),
      );

      void throttledAction() {
        action(null);
      }

      throttledAction();
      throttledAction();
      throttledAction();

      expect(callCount, equals(1)); // Only the first call should go through immediately
    });
  });
}

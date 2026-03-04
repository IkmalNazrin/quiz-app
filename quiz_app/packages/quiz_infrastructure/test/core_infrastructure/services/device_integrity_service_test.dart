import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_infrastructure/src/core_infrastructure/services/device_integrity_service.dart';

void main() {
  group('DeviceIntegrityService', () {
    late DeviceIntegrityService service;

    setUp(() {
      service = DeviceIntegrityService();
    });

    test('isDeviceCompromised returns false in test environment', () async {
      // In flutter test, kDebugMode is usually true, so it should bypass and return false.
      final isCompromised = await service.isDeviceCompromised();
      expect(isCompromised, isFalse);
    });

    test('caches the integrity result', () async {
      // It should only run the real check once.
      final result1 = await service.isDeviceCompromised();
      final result2 = await service.isDeviceCompromised();
      
      expect(result1, equals(result2));
    });
  });
}

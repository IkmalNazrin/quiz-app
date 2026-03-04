import 'package:flutter_riverpod/flutter_riverpod.dart';


import 'package:quiz_domain/quiz_domain.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core dependencies








// Legal Repository provider

final legalRepositoryProvider = Provider<LegalRepository>((ref) {
  throw UnimplementedError('Infrastructure injection required');
});

final offlineSyncRepositoryProvider = Provider<IOfflineSyncRepository>((ref) {
  throw UnimplementedError('Infrastructure injection required');
});

final storageServiceProvider = Provider<IStorageService>((ref) {
  throw UnimplementedError('Infrastructure injection required');
});

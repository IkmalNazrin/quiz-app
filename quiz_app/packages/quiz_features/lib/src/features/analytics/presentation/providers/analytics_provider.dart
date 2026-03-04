import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quiz_domain/quiz_domain.dart';

import 'package:quiz_features/quiz_features.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  throw UnimplementedError('Infrastructure injection required');
});

final hostMetricsProvider = FutureProvider<HostMetrics>((ref) {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getHostMetrics();
});

final allSessionsAnalyticsProvider =
    FutureProvider<List<SessionAnalytics>>((ref) {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getSessionAnalytics();
});

final sessionQuestionAnalyticsProvider =
    FutureProvider.family<List<QuestionAnalytics>, String>((ref, sessionId) {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getQuestionAnalytics(sessionId);
});

final sessionReportProvider =
    FutureProvider.family<SessionAnalytics?, String>((ref, sessionId) {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getSessionReport(sessionId);
});

// Legacy / Compatibility Providers
final quizAnalyticsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, quizId) {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getQuizAnalytics(quizId);
});

final hostAnalyticsProvider =
    FutureProvider.family<HostMetrics, String>((ref, hostId) {
  return ref.watch(hostMetricsProvider.future);
});

final hostQuizzesPerformanceProvider =
    FutureProvider.family<List<dynamic>, String>((ref, hostId) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getHostQuizzesPerformance(hostId);
});

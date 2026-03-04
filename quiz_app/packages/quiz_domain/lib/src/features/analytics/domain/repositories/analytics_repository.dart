import '../entities/analytics_entities.dart';

abstract class AnalyticsRepository {
  /// Fetches aggregate metrics for the host across all sessions.
  Future<HostMetrics> getHostMetrics();

  /// Fetches high-level analytics for all sessions hosted by the current user.
  Future<List<SessionAnalytics>> getSessionAnalytics();

  /// Fetches detailed question-level performance for a specific session.
  Future<List<QuestionAnalytics>> getQuestionAnalytics(String sessionId);

  /// Fetches the materialized report for a finished session.
  Future<SessionAnalytics?> getSessionReport(String sessionId);

  /// Fetches analytics for a specific quiz.
  Future<Map<String, dynamic>> getQuizAnalytics(String quizId);

  /// Fetches legacy analytics for a specific quiz.
  Future<Map<String, dynamic>> getLegacyQuizAnalytics(String quizId);

  // V1 Methods required by specific use-cases and implementations
  Future<Map<String, dynamic>> getHostStats(String hostId);
  Future<Map<String, dynamic>> getQuizStats(String quizId);
  Future<List<Map<String, dynamic>>> getHostQuizzesPerformance(String hostId);
}

import 'package:collection/collection.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quiz_domain/quiz_domain.dart';

class SupabaseAnalyticsRepository implements AnalyticsRepository {
  final SupabaseClient _client;

  SupabaseAnalyticsRepository(this._client);

  @override
  Future<HostMetrics> getHostMetrics() async {
    final response = await _client
        .from('v_host_metrics')
        .select()
        .eq('host_id', _client.auth.currentUser!.id)
        .maybeSingle();

    if (response == null) {
      return const HostMetrics(
        sessionsHosted: 0,
        lifetimePlayers: 0,
        globalAvgScore: 0,
        peakPlayerCount: 0,
      );
    }

    return HostMetrics.fromMap(response);
  }

  @override
  Future<List<SessionAnalytics>> getSessionAnalytics() async {
    final response = await _client
        .from('v_session_analytics')
        .select()
        .eq('host_id', _client.auth.currentUser!.id)
        .order('created_at', ascending: false);

    return (response as List).map((m) => SessionAnalytics.fromMap(m)).toList();
  }

  @override
  Future<List<QuestionAnalytics>> getQuestionAnalytics(String sessionId) async {
    final response = await _client
        .from('v_question_performance')
        .select()
        .eq('session_id', sessionId)
        .order('question_index', ascending: true);

    return (response as List).map((m) => QuestionAnalytics.fromMap(m)).toList();
  }

  @override
  Future<SessionAnalytics?> getSessionReport(String sessionId) async {
    // Try to get from materialized session_reports first for finished games
    final response = await _client
        .from('session_reports')
        .select()
        .eq('session_id', sessionId)
        .maybeSingle();

    if (response != null) {
      return SessionAnalytics.fromMap(response);
    }

    // Fallback to real-time view if report doesn't exist yet
    final realTime = await _client
        .from('v_session_analytics')
        .select()
        .eq('session_id', sessionId)
        .maybeSingle();

    return realTime != null ? SessionAnalytics.fromMap(realTime) : null;
  }

  @override
  Future<Map<String, dynamic>> getQuizAnalytics(String quizId) async {
    // For now, aggregate from v_session_analytics for this quiz
    final response = await _client
        .from('v_session_analytics')
        .select()
        .eq('quiz_id', quizId);

    final sessions = response as List;
    if (sessions.isEmpty) {
      return {
        'completionRate': 0.0,
        'avgScore': 0.0,
        'playCount': 0,
      };
    }

    final playCount = sessions.length;
    final avgScore =
        sessions.map((s) => (s['accuracy_rate'] as num? ?? 0.0)).average;

    return {
      'completionRate': _calculateCompletionRate(sessions),
      'avgScore': avgScore,
      'playCount': playCount,
    };
  }

  double _calculateCompletionRate(List<dynamic> sessions) {
    if (sessions.isEmpty) return 0.0;
    final completed = sessions.where(
      (s) => (s['status'] as String?) == 'completed'
    ).length;
    return completed / sessions.length;
  }

  @override
  Future<Map<String, dynamic>> getLegacyQuizAnalytics(String quizId) async {
    return getQuizAnalytics(quizId);
  }

  // V1 Legacy Methods (RPC-based)
  @override
  Future<Map<String, dynamic>> getHostStats(String hostId) async {
    final response = await _client.rpc('get_host_analytics_summary', params: {'host_uuid': hostId});
    return Map<String, dynamic>.from(response);
  }

  @override
  Future<Map<String, dynamic>> getQuizStats(String quizId) async {
    final response = await _client.rpc('get_quiz_analytics_detailed', params: {'quiz_uuid': quizId});
    return Map<String, dynamic>.from(response);
  }

  @override
  Future<List<Map<String, dynamic>>> getHostQuizzesPerformance(String hostId) async {
    final response = await _client.rpc('get_host_quizzes_performance', params: {'host_uuid': hostId});
    if (response == null) return [];
    return (response as List).map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }
}

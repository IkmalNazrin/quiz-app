import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quiz_infrastructure/quiz_infrastructure.dart';
import 'package:quiz_domain/quiz_domain.dart';

class PrivacyRepositoryImpl implements PrivacyRepository {
  final SupabaseClient _supabase;

  PrivacyRepositoryImpl(this._supabase);

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportUserData() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null)
        return const Left(ServerFailure('User not authenticated'));

      // 1. Fetch Profile
      final profile = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      // 2. Fetch Quizzes
      final quizzes =
          await _supabase.from('quizzes').select().eq('owner_id', userId);

      // 3. Fetch Game History (Participants)
      final history = await _supabase
          .from('game_participants')
          .select('*, game_sessions(*)')
          .eq('user_id', userId);

      // Aggregated Export
      final exportData = {
        'exported_at': DateTime.now().toIso8601String(),
        'user_id': userId,
        'profile': profile,
        'quizzes': quizzes,
        'game_history': history,
        'compliance_info': {
          'data_source': 'Quiz Arena Enterprise',
          'format_version': '1.0',
          'policy_accepted':
              true, // Simplified for now since they are logged in
        }
      };

      // Log the export event
      await _supabase.rpc('fn_log_security_event', params: {
        'p_event_type': 'DATA_EXPORT_REQUESTED',
        'p_details': {'timestamp': DateTime.now().toIso8601String()}
      });

      return Right(exportData);
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') return Left(NotFoundFailure(e.message));
      return Left(ServerFailure(e.message));
    } on SocketException catch (_) {
      return Left(const NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> anonymizeAccount() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null)
        return const Left(ServerFailure('User not authenticated'));

      // Call the secure RPC to perform true account deletion and PII scrubbing
      await _supabase.rpc('delete_user_account');

      // Force sign out (client side) immediately
      await _supabase.auth.signOut();

      return const Right(null);
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') return Left(NotFoundFailure(e.message));
      return Left(ServerFailure(e.message));
    } on SocketException catch (_) {
      return Left(const NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

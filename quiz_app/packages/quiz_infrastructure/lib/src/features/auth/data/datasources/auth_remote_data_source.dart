import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quiz_infrastructure/quiz_infrastructure.dart';
import '../models/user_model.dart';
import 'package:quiz_domain/quiz_domain.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithGoogle(String idToken, String accessToken);
  Future<void> signInWithOAuth();
  Future<void> signOut();
  Future<UserModel> signInAnonymously();
  Future<UserModel> getCurrentUser();
  Future<void> signInWithSSO(String emailOrSlug);
  Future<void> deleteAccount();
  Session? get currentSession;
  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl(this.supabaseClient);

  @override
  Session? get currentSession => supabaseClient.auth.currentSession;

  @override
  Stream<UserModel?> get authStateChanges {
    return supabaseClient.auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      return user != null ? UserModel.fromSupabase(user) : null;
    });
  }

  @override
  Future<UserModel> signInWithGoogle(String idToken, String accessToken) async {
    try {
      final response = await supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user == null) {
        throw const AuthFailure('Login failed: No user returned');
      }

      return UserModel.fromSupabase(response.user!);
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<void> signInWithOAuth() async {
    try {
      await supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        authScreenLaunchMode: LaunchMode.platformDefault,
      );
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } on AuthException catch (e) {
      throw ServerFailure(e.message);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') throw NotFoundFailure(e.message);
      throw ServerFailure(e.message);
    } on SocketException catch (_) {
      throw const NetworkFailure();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<UserModel> signInAnonymously() async {
    try {
      final response = await supabaseClient.auth.signInAnonymously();

      if (response.user == null) {
        throw const AuthFailure('Anonymous login failed: No user returned');
      }

      return UserModel.fromSupabase(response.user!);
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const AuthFailure('No user logged in');
      }
      return UserModel.fromSupabase(user);
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<void> signInWithSSO(String emailOrSlug) async {
    try {
      await supabaseClient.auth.signInWithSSO(
        domain: emailOrSlug.contains('@')
            ? emailOrSlug.split('@').last
            : emailOrSlug,
      );
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await supabaseClient.rpc('delete_user_account');
      await supabaseClient.auth.signOut();
    } catch (e) {
      throw ServerFailure('Failed to delete account: $e');
    }
  }
}

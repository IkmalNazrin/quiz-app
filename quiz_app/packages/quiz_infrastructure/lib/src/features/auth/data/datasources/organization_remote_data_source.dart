import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data' as bind_interface;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quiz_infrastructure/quiz_infrastructure.dart';
import '../models/organization_model.dart';
import '../models/organization_member_model.dart';
import 'package:quiz_domain/quiz_domain.dart';

abstract class OrganizationRemoteDataSource {
  Future<List<OrganizationModel>> getUserOrganizations();
  Future<OrganizationModel> createOrganization({
    required String name,
    required String slug,
    String? description,
  });
  Future<List<OrganizationMemberModel>> getOrganizationMembers(
      String organizationId);
  Future<void> addMember(String organizationId, String email, String role);
  Future<void> removeMember(String organizationId, String userId);
  Future<List<Map<String, dynamic>>> getAuditLogs(String organizationId);
  Future<Map<String, dynamic>?> getBranding(String organizationId);
  Future<void> updateBranding(
      String organizationId, Map<String, dynamic> branding);
  Future<List<Map<String, dynamic>>> getWebhooks(String organizationId);
  Future<void> createWebhook(
      String organizationId, String url, List<String> events);
  Future<void> deleteWebhook(String webhookId);
  Future<Map<String, dynamic>?> getSSOConfig(String organizationId);
  Future<void> updateSSOConfig(
      String organizationId, Map<String, dynamic> config);
  Future<List<Map<String, dynamic>>> getWebhookLogs(String organizationId,
      {String? webhookId});
  Future<String> uploadBrandingAsset(String organizationId, String assetType,
      List<int> bytes, String fileExtension);
}

class OrganizationRemoteDataSourceImpl implements OrganizationRemoteDataSource {
  final SupabaseClient supabaseClient;

  OrganizationRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<OrganizationModel>> getUserOrganizations() async {
    try {
      final response = await supabaseClient
          .from('organization_members')
          .select('*, organizations(*)')
          .eq('user_id', supabaseClient.auth.currentUser!.id);

      final listData = response as List<dynamic>;
      return Isolate.run(() => listData
          .map((item) => OrganizationModel.fromJson(
              item['organizations'] as Map<String, dynamic>))
          .toList());
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
  Future<OrganizationModel> createOrganization({
    required String name,
    required String slug,
    String? description,
  }) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw const AuthFailure('User not logged in');

      // 1. Create Organization
      final orgResponse = await supabaseClient
          .from('organizations')
          .insert({
            'name': name,
            'slug': slug,
            'description': description,
            'owner_id': user.id,
          })
          .select()
          .single();

      final org = OrganizationModel.fromJson(orgResponse);

      // 2. Add creator as Admin member
      await supabaseClient.from('organization_members').insert({
        'organization_id': org.id,
        'user_id': user.id,
        'role': 'admin',
      });

      return org;
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
  Future<List<OrganizationMemberModel>> getOrganizationMembers(
      String organizationId) async {
    try {
      final response = await supabaseClient
          .from('organization_members')
          .select()
          .eq('organization_id', organizationId);

      final listData = response as List<dynamic>;
      return Isolate.run(() => listData
          .map((item) =>
              OrganizationMemberModel.fromJson(item as Map<String, dynamic>))
          .toList());
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
  Future<void> addMember(
      String organizationId, String email, String role) async {
    try {
      // Note: In a real app, you'd find user_id by email first via an Edge Function or RPC
      // For simplicity, we assume an RPC or lookup exists
      final userLookup = await supabaseClient
          .rpc('get_user_id_by_email', params: {'email_input': email});

      if (userLookup == null) throw const ServerFailure('User not found');

      await supabaseClient.from('organization_members').insert({
        'organization_id': organizationId,
        'user_id': userLookup,
        'role': role,
      });
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
  Future<void> removeMember(String organizationId, String userId) async {
    try {
      await supabaseClient
          .from('organization_members')
          .delete()
          .eq('organization_id', organizationId)
          .eq('user_id', userId);
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
  Future<List<Map<String, dynamic>>> getAuditLogs(String organizationId) async {
    try {
      final response = await supabaseClient
          .from('security_audit_logs')
          .select()
          .eq('organization_id', organizationId)
          .order('created_at', ascending: false)
          .limit(50);

      return List<Map<String, dynamic>>.from(response);
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
  Future<Map<String, dynamic>?> getBranding(String organizationId) async {
    try {
      final response = await supabaseClient
          .from('organization_branding')
          .select()
          .eq('organization_id', organizationId)
          .maybeSingle();

      return response;
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
  Future<void> updateBranding(
      String organizationId, Map<String, dynamic> branding) async {
    try {
      await supabaseClient.from('organization_branding').upsert({
        'organization_id': organizationId,
        ...branding,
        'updated_at': DateTime.now().toIso8601String(),
      });
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
  Future<List<Map<String, dynamic>>> getWebhooks(String organizationId) async {
    try {
      final response = await supabaseClient
          .from('webhooks')
          .select()
          .eq('organization_id', organizationId);
      return List<Map<String, dynamic>>.from(response);
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
  Future<void> createWebhook(
      String organizationId, String url, List<String> events) async {
    try {
      await supabaseClient.from('webhooks').insert({
        'organization_id': organizationId,
        'url': url,
        'events': events,
      });
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
  Future<void> deleteWebhook(String webhookId) async {
    try {
      await supabaseClient.from('webhooks').delete().eq('id', webhookId);
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
  Future<Map<String, dynamic>?> getSSOConfig(String organizationId) async {
    try {
      final response = await supabaseClient
          .from('organization_sso_configs')
          .select()
          .eq('organization_id', organizationId)
          .maybeSingle();
      return response;
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
  Future<void> updateSSOConfig(
      String organizationId, Map<String, dynamic> config) async {
    try {
      await supabaseClient.from('organization_sso_configs').upsert({
        'organization_id': organizationId,
        ...config,
        'updated_at': DateTime.now().toIso8601String(),
      });
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
  Future<List<Map<String, dynamic>>> getWebhookLogs(String organizationId,
      {String? webhookId}) async {
    try {
      var query =
          supabaseClient.from('webhook_logs').select('*, webhooks!inner(*)');

      if (webhookId != null) {
        query = query.eq('webhook_id', webhookId);
      } else {
        query = query.eq('webhooks.organization_id', organizationId);
      }

      final response =
          await query.order('created_at', ascending: false).limit(50);
      return List<Map<String, dynamic>>.from(response);
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
  Future<String> uploadBrandingAsset(String organizationId, String assetType,
      List<int> bytes, String fileExtension) async {
    try {
      final path =
          '$organizationId/$assetType.${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      await supabaseClient.storage.from('organization_assets').uploadBinary(
            path,
            bind_interface.Uint8List.fromList(bytes),
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final publicUrl =
          supabaseClient.storage.from('organization_assets').getPublicUrl(path);
      return publicUrl;
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
}

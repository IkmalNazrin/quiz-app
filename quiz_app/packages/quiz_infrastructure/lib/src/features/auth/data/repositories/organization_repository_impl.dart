import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dartz/dartz.dart';
import 'package:quiz_infrastructure/quiz_infrastructure.dart';
import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_domain/quiz_domain.dart';
import '../datasources/organization_remote_data_source.dart';

class OrganizationRepositoryImpl implements IOrganizationRepository {
  final OrganizationRemoteDataSource remoteDataSource;

  OrganizationRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<OrganizationEntity>>>
      getUserOrganizations() async {
    try {
      final orgs = await remoteDataSource.getUserOrganizations();
      return Right(orgs);
    } on Failure catch (e) {
      return Left(e);
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
  Future<Either<Failure, OrganizationEntity>> createOrganization({
    required String name,
    required String slug,
    String? description,
  }) async {
    try {
      final org = await remoteDataSource.createOrganization(
        name: name,
        slug: slug,
        description: description,
      );
      return Right(org);
    } on Failure catch (e) {
      return Left(e);
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
  Future<Either<Failure, List<OrganizationMemberEntity>>>
      getOrganizationMembers(String organizationId) async {
    try {
      final members =
          await remoteDataSource.getOrganizationMembers(organizationId);
      return Right(members);
    } on Failure catch (e) {
      return Left(e);
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
  Future<Either<Failure, Unit>> addMember(
      String organizationId, String email, OrganizationRole role) async {
    try {
      await remoteDataSource.addMember(organizationId, email, role.name);
      return const Right(unit);
    } on Failure catch (e) {
      return Left(e);
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
  Future<Either<Failure, Unit>> removeMember(
      String organizationId, String userId) async {
    try {
      await remoteDataSource.removeMember(organizationId, userId);
      return const Right(unit);
    } on Failure catch (e) {
      return Left(e);
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
  Future<Either<Failure, List<Map<String, dynamic>>>> getAuditLogs(
      String organizationId) async {
    try {
      final logs = await remoteDataSource.getAuditLogs(organizationId);
      return Right(logs);
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
  Future<Either<Failure, OrganizationBrandingEntity?>> getBranding(
      String organizationId) async {
    try {
      final json = await remoteDataSource.getBranding(organizationId);
      if (json == null) return const Right(null);
      return Right(OrganizationBrandingEntity.fromJson(json));
    } on Failure catch (e) {
      return Left(e);
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
  Future<Either<Failure, Unit>> updateBranding(
      String organizationId, Map<String, dynamic> branding) async {
    try {
      await remoteDataSource.updateBranding(organizationId, branding);
      return const Right(unit);
    } on Failure catch (e) {
      return Left(e);
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
  Future<Either<Failure, List<WebhookEntity>>> getWebhooks(
      String organizationId) async {
    try {
      final jsonList = await remoteDataSource.getWebhooks(organizationId);
      return Right(jsonList.map((j) => WebhookEntity.fromJson(j)).toList());
    } on Failure catch (e) {
      return Left(e);
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
  Future<Either<Failure, Unit>> createWebhook(
      String organizationId, String url, List<String> events) async {
    try {
      await remoteDataSource.createWebhook(organizationId, url, events);
      return const Right(unit);
    } on Failure catch (e) {
      return Left(e);
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
  Future<Either<Failure, Unit>> deleteWebhook(String webhookId) async {
    try {
      await remoteDataSource.deleteWebhook(webhookId);
      return const Right(unit);
    } on Failure catch (e) {
      return Left(e);
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
  Future<Either<Failure, OrganizationSSOConfigEntity?>> getSSOConfig(
      String organizationId) async {
    try {
      final json = await remoteDataSource.getSSOConfig(organizationId);
      if (json == null) return const Right(null);
      return Right(OrganizationSSOConfigEntity.fromJson(json));
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
  Future<Either<Failure, Unit>> updateSSOConfig(
      String organizationId, Map<String, dynamic> config) async {
    try {
      await remoteDataSource.updateSSOConfig(organizationId, config);
      return const Right(unit);
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
  Future<Either<Failure, List<WebhookLogEntity>>> getWebhookLogs(
      String organizationId,
      {String? webhookId}) async {
    try {
      final jsonList = await remoteDataSource.getWebhookLogs(organizationId,
          webhookId: webhookId);
      return Right(jsonList.map((j) => WebhookLogEntity.fromJson(j)).toList());
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
  Future<Either<Failure, String>> uploadBrandingAsset(String organizationId,
      String assetType, List<int> bytes, String fileExtension) async {
    try {
      final url = await remoteDataSource.uploadBrandingAsset(
          organizationId, assetType, bytes, fileExtension);
      return Right(url);
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

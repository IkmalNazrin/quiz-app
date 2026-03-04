import 'package:dartz/dartz.dart';
import '../../../../core_domain/error/failures.dart';
import '../entities/organization_entity.dart';
import '../entities/organization_member_entity.dart';
import '../entities/organization_sso_config_entity.dart';
import '../entities/webhook_log_entity.dart';
import '../entities/webhook_entity.dart';
import '../entities/organization_branding_entity.dart';

abstract class IOrganizationRepository {
  Future<Either<Failure, List<OrganizationEntity>>> getUserOrganizations();
  Future<Either<Failure, OrganizationEntity>> createOrganization({
    required String name,
    required String slug,
    String? description,
  });
  Future<Either<Failure, List<OrganizationMemberEntity>>>
      getOrganizationMembers(String organizationId);
  Future<Either<Failure, Unit>> addMember(
      String organizationId, String email, OrganizationRole role);
  Future<Either<Failure, Unit>> removeMember(
      String organizationId, String userId);
  Future<Either<Failure, List<Map<String, dynamic>>>> getAuditLogs(
      String organizationId);
  Future<Either<Failure, OrganizationBrandingEntity?>> getBranding(
      String organizationId);
  Future<Either<Failure, Unit>> updateBranding(
      String organizationId, Map<String, dynamic> branding);
  Future<Either<Failure, List<WebhookEntity>>> getWebhooks(
      String organizationId);
  Future<Either<Failure, Unit>> createWebhook(
      String organizationId, String url, List<String> events);
  Future<Either<Failure, Unit>> deleteWebhook(String webhookId);
  Future<Either<Failure, OrganizationSSOConfigEntity?>> getSSOConfig(
      String organizationId);
  Future<Either<Failure, Unit>> updateSSOConfig(
      String organizationId, Map<String, dynamic> config);
  Future<Either<Failure, List<WebhookLogEntity>>> getWebhookLogs(
      String organizationId,
      {String? webhookId});
  Future<Either<Failure, String>> uploadBrandingAsset(String organizationId,
      String assetType, List<int> bytes, String fileExtension);
}

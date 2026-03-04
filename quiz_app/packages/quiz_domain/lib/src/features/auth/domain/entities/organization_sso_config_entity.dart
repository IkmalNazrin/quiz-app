import 'package:equatable/equatable.dart';

class OrganizationSSOConfigEntity extends Equatable {
  final String id;
  final String organizationId;
  final bool isEnabled;
  final String providerType;
  final String? entityId;
  final String? metadataUrl;
  final String? metadataXml;
  final String? domainFilter;

  const OrganizationSSOConfigEntity({
    required this.id,
    required this.organizationId,
    required this.isEnabled,
    required this.providerType,
    this.entityId,
    this.metadataUrl,
    this.metadataXml,
    this.domainFilter,
  });

  @override
  List<Object?> get props => [
        id,
        organizationId,
        isEnabled,
        providerType,
        entityId,
        metadataUrl,
        metadataXml,
        domainFilter,
      ];

  factory OrganizationSSOConfigEntity.fromJson(Map<String, dynamic> json) {
    return OrganizationSSOConfigEntity(
      id: json['id'],
      organizationId: json['organization_id'],
      isEnabled: json['is_enabled'] ?? false,
      providerType: json['provider_type'] ?? 'saml',
      entityId: json['entity_id'],
      metadataUrl: json['metadata_url'],
      metadataXml: json['metadata_xml'],
      domainFilter: json['domain_filter'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_enabled': isEnabled,
      'provider_type': providerType,
      'entity_id': entityId,
      'metadata_url': metadataUrl,
      'metadata_xml': metadataXml,
      'domain_filter': domainFilter,
    };
  }
}

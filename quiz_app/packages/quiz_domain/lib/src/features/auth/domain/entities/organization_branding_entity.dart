import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class OrganizationBrandingEntity extends Equatable {
  final String id;
  final String organizationId;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final String? appNameOverride;
  final String? logoUrl;
  final String? bannerUrl;

  const OrganizationBrandingEntity({
    required this.id,
    required this.organizationId,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    this.appNameOverride,
    this.logoUrl,
    this.bannerUrl,
  });

  @override
  List<Object?> get props => [
        id,
        organizationId,
        primaryColor,
        secondaryColor,
        accentColor,
        appNameOverride,
        logoUrl,
        bannerUrl,
      ];

  static Color _parseColor(String hex) {
    try {
      final buffer = StringBuffer();
      if (hex.length == 6 || hex.length == 7) buffer.write('ff');
      buffer.write(hex.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return const Color(0xFF8B5CF6); // Default primary
    }
  }

  factory OrganizationBrandingEntity.fromJson(Map<String, dynamic> json) {
    return OrganizationBrandingEntity(
      id: json['id'],
      organizationId: json['organization_id'],
      primaryColor: _parseColor(json['primary_color'] ?? '#8B5CF6'),
      secondaryColor: _parseColor(json['secondary_color'] ?? '#2DD4BF'),
      accentColor: _parseColor(json['accent_color'] ?? '#F472B6'),
      appNameOverride: json['app_name_override'],
      logoUrl: json['logo_url'],
      bannerUrl: json['banner_url'],
    );
  }
}

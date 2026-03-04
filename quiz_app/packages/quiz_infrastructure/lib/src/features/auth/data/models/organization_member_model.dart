import 'package:quiz_domain/quiz_domain.dart';

class OrganizationMemberModel extends OrganizationMemberEntity {
  const OrganizationMemberModel({
    required super.id,
    required super.organizationId,
    required super.userId,
    required super.role,
    required super.joinedAt,
  });

  factory OrganizationMemberModel.fromJson(Map<String, dynamic> json) {
    return OrganizationMemberModel(
      id: json['id'],
      organizationId: json['organization_id'],
      userId: json['user_id'],
      role: _parseRole(json['role']),
      joinedAt: DateTime.parse(json['joined_at']),
    );
  }

  static OrganizationRole _parseRole(String role) {
    switch (role) {
      case 'admin':
        return OrganizationRole.admin;
      case 'moderator':
        return OrganizationRole.moderator;
      default:
        return OrganizationRole.member;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'user_id': userId,
      'role': role.name,
      'joined_at': joinedAt.toIso8601String(),
    };
  }
}

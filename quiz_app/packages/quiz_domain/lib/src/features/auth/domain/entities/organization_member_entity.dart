import 'package:equatable/equatable.dart';

enum OrganizationRole { admin, moderator, member }

class OrganizationMemberEntity extends Equatable {
  final String id;
  final String organizationId;
  final String userId;
  final OrganizationRole role;
  final DateTime joinedAt;

  const OrganizationMemberEntity({
    required this.id,
    required this.organizationId,
    required this.userId,
    required this.role,
    required this.joinedAt,
  });

  @override
  List<Object?> get props => [id, organizationId, userId, role, joinedAt];
}

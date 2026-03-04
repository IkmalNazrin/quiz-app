import 'package:quiz_domain/quiz_domain.dart';

class OrganizationModel extends OrganizationEntity {
  const OrganizationModel({
    required super.id,
    required super.name,
    required super.slug,
    super.description,
    super.avatarUrl,
    super.ownerId,
    required super.createdAt,
  });

  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    return OrganizationModel(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      avatarUrl: json['avatar_url'],
      ownerId: json['owner_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'avatar_url': avatarUrl,
      'owner_id': ownerId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

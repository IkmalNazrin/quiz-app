import 'package:equatable/equatable.dart';

class OrganizationEntity extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? avatarUrl;
  final String? ownerId;
  final DateTime createdAt;

  const OrganizationEntity({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.avatarUrl,
    this.ownerId,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, name, slug, description, avatarUrl, ownerId, createdAt];
}

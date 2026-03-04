import 'package:equatable/equatable.dart';

enum UserRole {
  dev,
  admin,
  host,
  player;

  bool get isHost =>
      this == UserRole.host || this == UserRole.admin || this == UserRole.dev;
  bool get isAdmin => this == UserRole.admin || this == UserRole.dev;
}

class UserEntity extends Equatable {
  final String id;
  final String? email;
  final String? name;
  final String? avatarUrl;
  final bool isAnonymous;
  final UserRole role;

  const UserEntity({
    required this.id,
    this.email,
    this.name,
    this.avatarUrl,
    this.isAnonymous = false,
    this.role = UserRole.player,
  });

  @override
  List<Object?> get props => [id, email, name, avatarUrl, isAnonymous, role];
}

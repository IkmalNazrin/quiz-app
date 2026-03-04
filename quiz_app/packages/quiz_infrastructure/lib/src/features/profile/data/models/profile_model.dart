import 'package:quiz_domain/quiz_domain.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.username,
    super.fullName,
    super.avatarUrl,
    super.bio,
    super.totalPoints,
    super.currentStreak,
    super.highestStreak,
    required super.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      username: json['username'] ?? 'User',
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'] ?? json['picture_url'],
      bio: json['bio'],
      totalPoints: json['total_points'] ?? 0,
      currentStreak: json['current_streak'] ?? 0,
      highestStreak: json['highest_streak'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'picture_url': avatarUrl, // Keep in sync for legacy compatibility
      'bio': bio,
      'total_points': totalPoints,
      'current_streak': currentStreak,
      'highest_streak': highestStreak,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ProfileModel.fromEntity(ProfileEntity entity) {
    return ProfileModel(
      id: entity.id,
      username: entity.username,
      fullName: entity.fullName,
      avatarUrl: entity.avatarUrl,
      bio: entity.bio,
      totalPoints: entity.totalPoints,
      currentStreak: entity.currentStreak,
      highestStreak: entity.highestStreak,
      createdAt: entity.createdAt,
    );
  }
}

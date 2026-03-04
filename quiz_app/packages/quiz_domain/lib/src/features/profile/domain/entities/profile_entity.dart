import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String username;
  final String? fullName;
  final String? avatarUrl;
  final String? bio;
  final int totalPoints;
  final int currentStreak;
  final int highestStreak;
  final DateTime createdAt;

  const ProfileEntity({
    required this.id,
    required this.username,
    this.fullName,
    this.avatarUrl,
    this.bio,
    this.totalPoints = 0,
    this.currentStreak = 0,
    this.highestStreak = 0,
    required this.createdAt,
  });

  ProfileEntity copyWith({
    String? username,
    String? fullName,
    String? avatarUrl,
    String? bio,
    int? totalPoints,
    int? currentStreak,
    int? highestStreak,
  }) {
    return ProfileEntity(
      id: id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      totalPoints: totalPoints ?? this.totalPoints,
      currentStreak: currentStreak ?? this.currentStreak,
      highestStreak: highestStreak ?? this.highestStreak,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        username,
        fullName,
        avatarUrl,
        bio,
        totalPoints,
        currentStreak,
        highestStreak,
        createdAt,
      ];
}

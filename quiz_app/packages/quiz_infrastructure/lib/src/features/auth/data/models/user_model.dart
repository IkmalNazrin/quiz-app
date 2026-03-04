import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quiz_domain/quiz_domain.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    super.email,
    super.name,
    super.avatarUrl,
    super.isAnonymous = false,
    super.role = UserRole.player,
  });

  factory UserModel.fromSupabase(User user) {
    // Prefer app_metadata for secure roles (set by admin/functions), fallback to user_metadata
    final roleStr =
        (user.appMetadata['role'] ?? user.userMetadata?['role']) as String? ??
            'player';

    final role = UserRole.values.firstWhere(
      (e) => e.name == roleStr,
      orElse: () => UserRole.player,
    );

    return UserModel(
      id: user.id,
      email: user.email,
      name: user.userMetadata?['full_name'] as String?,
      avatarUrl: user.userMetadata?['avatar_url'] as String?,
      isAnonymous: user.isAnonymous,
      role: role,
    );
  }
}

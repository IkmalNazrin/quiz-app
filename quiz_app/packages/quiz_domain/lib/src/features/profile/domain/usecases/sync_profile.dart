import 'package:dartz/dartz.dart';
import '../../../../core_domain/error/failures.dart';
import '../../../../core_domain/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/profile_repository.dart';
import '../entities/profile_entity.dart';

class SyncProfile implements UseCase<void, UserEntity> {
  final ProfileRepository repository;

  SyncProfile(this.repository);

  @override
  Future<Either<Failure, void>> call(UserEntity user) async {
    try {
      await repository.getProfile(user.id);
      return const Right(null);
    } catch (e) {
      // Profile not found or error, attempt to create
      final newProfile = ProfileEntity(
        id: user.id,
        username: user.name ??
            (user.email != null
                ? user.email!.split('@')[0]
                : "Guest_\${user.id.substring(0, 4)}"),
        fullName: user.name ?? (user.isAnonymous ? "Guest Participant" : null),
        avatarUrl: user.avatarUrl,
        createdAt: DateTime.now(),
      );
      try {
        await repository.createProfile(newProfile);
        return const Right(null);
      } catch (e2) {
        return Left(ServerFailure(e2.toString()));
      }
    }
  }
}

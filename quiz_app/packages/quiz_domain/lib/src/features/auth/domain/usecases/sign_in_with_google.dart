import 'package:dartz/dartz.dart';
import '../../../../core_domain/error/failures.dart';
import '../../../../core_domain/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInWithGoogleParams {
  final String idToken;
  final String accessToken;

  const SignInWithGoogleParams({
    required this.idToken,
    required this.accessToken,
  });
}

class SignInWithGoogle implements UseCase<UserEntity, SignInWithGoogleParams> {
  final AuthRepository repository;

  SignInWithGoogle(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(
      SignInWithGoogleParams params) async {
    return repository.signInWithGoogle(params.idToken, params.accessToken);
  }
}

import 'package:dartz/dartz.dart';
import '../../../../core_domain/error/failures.dart';
import '../../../../core_domain/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class SignInWithGoogleNative implements UseCase<void, NoParams> {
  final AuthRepository repository;

  SignInWithGoogleNative(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return repository.signInWithGoogleNative();
  }
}

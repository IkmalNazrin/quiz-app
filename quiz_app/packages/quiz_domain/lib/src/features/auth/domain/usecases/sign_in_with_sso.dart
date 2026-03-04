import 'package:dartz/dartz.dart';
import '../../../../core_domain/error/failures.dart';
import '../../../../core_domain/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class SignInWithSSO implements UseCase<void, String> {
  final AuthRepository repository;

  SignInWithSSO(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) {
    return repository.signInWithSSO(params);
  }
}

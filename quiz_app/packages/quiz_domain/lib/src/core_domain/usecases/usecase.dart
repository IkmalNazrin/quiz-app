import 'package:dartz/dartz.dart';
import '../error/failures.dart';

// T is the return type, Params is the input parameters
// ignore: one_member_abstracts
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

class NoParams {}

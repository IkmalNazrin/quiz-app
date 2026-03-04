abstract class Failure implements Exception {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class CanceledFailure extends Failure {
  const CanceledFailure([super.message = 'Operation canceled']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network connection unavailable']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

class RateLimitFailure extends Failure {
  const RateLimitFailure([super.message = 'Too many requests']);
}

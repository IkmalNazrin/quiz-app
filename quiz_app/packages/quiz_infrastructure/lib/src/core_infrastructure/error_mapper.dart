import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dartz/dartz.dart';
import 'package:quiz_domain/quiz_domain.dart';
import 'logger_impl.dart';

import 'package:flutter/foundation.dart';

/// Centralized error-to-Failure mapper for all infrastructure operations.
/// Captures stack traces and logs before converting to domain failures.
Either<Failure, T> mapExceptionToFailure<T>(
  Object error,
  StackTrace stackTrace,
  String operationName,
) {
  debugPrint('[$operationName] failed: $error');

  if (error is Failure) return Left(error);
  if (error is AuthException) return Left(AuthFailure(error.message));
  if (error is PostgrestException) {
    if (error.code == 'PGRST116') return Left(NotFoundFailure(error.message));
    return Left(ServerFailure(error.message));
  }
  if (error is SocketException) return Left(const NetworkFailure());

  return Left(ServerFailure('$operationName: ${error.toString()}'));
}

/// Convenience wrapper to execute an async operation with unified error handling.
Future<Either<Failure, T>> safeApiCall<T>(
  String operationName,
  Future<T> Function() operation,
) async {
  try {
    final result = await operation();
    return Right(result);
  } catch (e, stackTrace) {
    return mapExceptionToFailure(e, stackTrace, operationName);
  }
}

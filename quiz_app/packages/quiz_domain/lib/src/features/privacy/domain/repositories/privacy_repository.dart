import 'package:dartz/dartz.dart';
import '../../../../core_domain/error/failures.dart';

abstract class PrivacyRepository {
  /// Exports all data belonging to the current user as a JSON-serializable map.
  Future<Either<Failure, Map<String, dynamic>>> exportUserData();

  /// Triggers the GDPR "Right to be Forgotten" via server-side anonymization.
  Future<Either<Failure, void>> anonymizeAccount();
}

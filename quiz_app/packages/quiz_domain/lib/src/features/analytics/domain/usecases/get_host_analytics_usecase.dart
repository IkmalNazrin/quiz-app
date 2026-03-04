import 'package:dartz/dartz.dart';
import '../../../../core_domain/error/failures.dart';
import '../entities/host_stats.dart';
import '../repositories/analytics_repository.dart';

class GetHostAnalyticsUseCase {
  final AnalyticsRepository repository;

  GetHostAnalyticsUseCase(this.repository);

  Future<Either<Failure, HostStats>> call(String hostId) async {
    try {
      final data = await repository.getHostStats(hostId);
      return Right(HostStats.fromJson(data));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

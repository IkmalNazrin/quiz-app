import 'package:dartz/dartz.dart';
// Verify this path later, if not exists I will adjust
import '../../../../core_domain/error/failures.dart'; // Verify this path later
import '../entities/game_history_item.dart';
import '../repositories/history_repository.dart';

class GetUserHistoryUseCase {
  final HistoryRepository repository;

  GetUserHistoryUseCase(this.repository);

  Future<Either<Failure, List<GameHistoryItem>>> call(String userId,
      {int limit = 10, int offset = 0}) async {
    return repository.getUserHistory(userId, limit: limit, offset: offset);
  }
}

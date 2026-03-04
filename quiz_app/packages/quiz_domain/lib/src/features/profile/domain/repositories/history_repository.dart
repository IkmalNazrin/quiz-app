import 'package:dartz/dartz.dart';
import '../../../../core_domain/error/failures.dart';
import '../entities/game_history_item.dart';

// ignore: one_member_abstracts
abstract class HistoryRepository {
  Future<Either<Failure, List<GameHistoryItem>>> getUserHistory(String userId,
      {int limit = 10, int offset = 0});
}

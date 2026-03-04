import 'dart:convert';
import 'package:quiz_domain/quiz_domain.dart';
import 'app_database.dart';

class DriftOfflineSyncRepository implements IOfflineSyncRepository {
  final AppDatabase _db;

  DriftOfflineSyncRepository(this._db);

  @override
  Future<void> cacheMutation({
    required String mutationType,
    required Map<String, dynamic> payload,
  }) async {
    final payloadJson = jsonEncode(payload);

    await _db.into(_db.offlineMutations).insert(
          OfflineMutationsCompanion.insert(
            mutationType: mutationType,
            payloadJson: payloadJson,
          ),
        );
  }
}

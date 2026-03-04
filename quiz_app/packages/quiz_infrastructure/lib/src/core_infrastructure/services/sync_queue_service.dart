import 'package:quiz_domain/quiz_domain.dart';
import 'dart:async';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quiz_infrastructure/quiz_infrastructure.dart';
import 'connectivity_service.dart';
import 'logger_service.dart';

// Note: PendingAction class is now partially superseded by OfflineMutations table.
// We'll map the Drift table row back to a similar object to keep the signature.

class PendingAction {
  final String action;
  final Map<String, dynamic> payload;
  final DateTime timestamp;
  final String gamePin;
  int retries;

  PendingAction({
    required this.action,
    required this.payload,
    required this.gamePin,
    required this.timestamp,
    this.retries = 0,
  });

  Map<String, dynamic> toJson() => {
        'action': action,
        'payload': payload,
        'timestamp': timestamp.toIso8601String(),
        'gamePin': gamePin,
        'retries': retries,
      };

  factory PendingAction.fromJson(Map<String, dynamic> json) {
    return PendingAction(
      action: json['action'] as String,
      payload: json['payload'] as Map<String, dynamic>,
      gamePin: json['gamePin'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      retries: json['retries'] as int? ?? 0,
    );
  }
}

/// Service that queues and executes actions when the network is available.
class SyncQueueService implements ISyncQueueService {
  final SupabaseClient _supabase;
  final NetworkInfoInterface _connectivityService;
  final AppDatabase _db;

  bool _isProcessing = false;

  final _syncStatusController = StreamController<bool>.broadcast();

  SyncQueueService(this._supabase, this._connectivityService, this._db) {
    _connectivityService.onConnectivityChanged.listen((isOnline) {
      if (isOnline) {
        AppLogger.i(
            'Network restored. Attempting to flush local mutation queue...');
        // We might not have a gamePin here globally, so we will need to change signature or pass gamePin around?
        // Let's pass empty gamePin if we flush globally.
        unawaited(processQueue(''));
      }
    });
  }

  /// Stream that emits true when syncing, false otherwise.
  @override
  Stream<bool> get isSyncingStream => _syncStatusController.stream;

  /// Queues an action to be executed and persists it locally.
  Future<void> queueAction({
    required String action,
    required String gamePin,
    required Map<String, dynamic> payload,
    Duration ttl = const Duration(seconds: 30),
  }) async {
    // Append gamePin to payload for simplicity since OfflineMutations doesn't have it explicit
    final mergedPayload = Map<String, dynamic>.from(payload);
    mergedPayload['gamePin'] = gamePin;

    await _db.into(_db.offlineMutations).insert(
          OfflineMutationsCompanion.insert(
            mutationType: action,
            payloadJson: jsonEncode(mergedPayload),
          ),
        );

    AppLogger.d('Secure Action queued in SQLite: $action.');

    // Attempt immediate flush if online
    unawaited(processQueue(gamePin));
  }

  /// Attempts to execute all pending actions.
  @override
  Future<void> processQueue(String gamePin) async {
    if (_isProcessing) return;

    final online = await _connectivityService.isOnline;
    if (!online) return;

    _isProcessing = true;
    _syncStatusController.add(true);

    try {
      final pendingMutations = await _db.select(_db.offlineMutations).get();
      if (pendingMutations.isEmpty) {
        _isProcessing = false;
        _syncStatusController.add(false);
        return;
      }

      AppLogger.i(
          'Processing SQLite sync queue. ${pendingMutations.length} items pending.');
      final now = DateTime.now();

      for (final mutation in pendingMutations) {
        // Discard expired
        if (now.difference(mutation.createdAt) > const Duration(seconds: 45)) {
          AppLogger.w(
              'Discarding expired local mutation action: ${mutation.mutationType} after TTL');
          await _db.delete(_db.offlineMutations).delete(mutation);
          continue;
        }

        try {
          final decodedPayload =
              jsonDecode(mutation.payloadJson) as Map<String, dynamic>;
          final gamePin = decodedPayload['gamePin'] as String?;

          final response = await _supabase.functions.invoke(
            'game-orchestrator',
            body: {
              'action': mutation.mutationType,
              'gamePin': gamePin,
              'payload': decodedPayload,
            },
          );

          if (response.status == 200) {
            AppLogger.i(
                'Sync successful for local mutation: ${mutation.mutationType}');
            await _db.delete(_db.offlineMutations).delete(mutation);
          } else {
            // Increment retry count
            final newRetries = mutation.retryCount + 1;
            if (newRetries > 5) {
              AppLogger.e(
                  'Mutation ${mutation.mutationType} failed after max retries. Discarding.');
              await _db.delete(_db.offlineMutations).delete(mutation);
            } else {
              await _db
                  .update(_db.offlineMutations)
                  .replace(mutation.copyWith(retryCount: newRetries));
            }
          }
        } catch (e) {
          AppLogger.e('Error during sync for ${mutation.mutationType}: $e');
          // Update retry count and break loop on network failure
          await _db
              .update(_db.offlineMutations)
              .replace(mutation.copyWith(retryCount: mutation.retryCount + 1));
          break;
        }
      }
    } finally {
      _isProcessing = false;
      _syncStatusController.add(false);
    }
  }

  @override
  void dispose() {
    _syncStatusController.close();
  }
}

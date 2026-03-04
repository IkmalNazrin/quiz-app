import 'package:quiz_domain/quiz_domain.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/logger_service.dart';
import 'package:quiz_infrastructure/quiz_infrastructure.dart';

/// Service responsible for managing Supabase Realtime Channels,
/// Presence for participant tracking, and Broadcast for game events.
class GameRealtimeService implements IGameRealtimeService {
  final SupabaseClient _supabase;
  RealtimeChannel? _channel;

  // Stream Controllers for internal plumbing
  final _playersController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  final _eventsController = StreamController<Map<String, dynamic>>.broadcast();
  String? _gamePin;

  GameRealtimeService(this._supabase);

  /// Streams for the UI to consume
  Stream<List<Map<String, dynamic>>> get playersStream =>
      _playersController.stream;
  Stream<Map<String, dynamic>> get eventsStream => _eventsController.stream;
  String? get gamePin => _gamePin;

  /// Joins a game room (Supabase Channel)
  Future<void> joinRoom({
    required String gamePin,
    required String nickname,
    bool isHost = false,
  }) async {
    await leaveRoom();

    _gamePin = gamePin;
    final channelName = 'game:$gamePin';
    AppLogger.i('Joining Realtime Channel: $channelName');

    _channel = _supabase.channel(channelName);

    // 1. Setup Presence
    _channel!.onPresenceSync((payload) {
      final dynamic states = _channel!.presenceState();
      final List<Map<String, dynamic>> players = [];

      try {
        if (states is Map) {
          for (final entry in states.entries) {
            if (entry.value is List) {
              for (final item in entry.value) {
                final data = _extractPresenceData(item);
                if (data != null) players.add(data);
              }
            }
          }
        } else if (states is List) {
          for (final item in states) {
            final data = _extractPresenceData(item);
            if (data != null) players.add(data);
          }
        }
      } catch (e, s) {
        AppLogger.e('Error parsing presence sync: $e', error: e, stackTrace: s);
      }

      _playersController.add(players);
    }).onPresenceJoin((payload) {
      AppLogger.d('Player joined presence: ${payload.newPresences}');
    }).onPresenceLeave((payload) {
      AppLogger.d('Player left presence: ${payload.leftPresences}');
    });

    // 2. Setup Broadcast Listeners
    _channel!.onBroadcast(
        event: '*',
        callback: (payload) {
          AppLogger.d('Broadcast received: $payload');
          _eventsController.add(payload);
        });

    // 3. Subscribe
    _channel!.subscribe((status, [error]) async {
      if (status == RealtimeSubscribeStatus.subscribed) {
        AppLogger.i('Subscribed to channel successfully');

        // Track this player in Presence
        await _channel!.track({
          'nickname': nickname,
          'isHost': isHost,
          'user_id': _supabase.auth.currentUser?.id,
          'joined_at': DateTime.now().toIso8601String(),
        });
      } else if (error != null) {
        AppLogger.e('Realtime subscription error: $error', error: error);
      }
    });
  }

  /// Broadcasts an event to all participants in the room
  Future<void> broadcastEvent(String event, Map<String, dynamic> data) async {
    if (_channel == null) {
      AppLogger.w('Cannot broadcast: Channel is not initialized');
      return;
    }

    AppLogger.d('Broadcasting event: $event');

    try {
      // Using sendBroadcastMessage convenience method which handles hidden RealtimeListenTypes
      await _channel!.sendBroadcastMessage(
        event: event,
        payload: data,
      );
    } catch (e, s) {
      AppLogger.e('Failed to broadcast event: $event', error: e, stackTrace: s);
    }
  }

  /// Leaves the current room and cleans up resources
  Future<void> leaveRoom() async {
    if (_channel != null) {
      AppLogger.i('Leaving Realtime Channel');
      await _supabase.removeChannel(_channel!);
      _channel = null;
    }
  }

  /// Disposes of the service
  void dispose() {
    leaveRoom();
    _playersController.close();
    _eventsController.close();
  }

  Map<String, dynamic>? _extractPresenceData(dynamic item) {
    if (item == null) return null;

    // Debug log to see raw item structure
    // AppLogger.d('Raw Presence Item: $item');

    try {
      // 1. Try 'payload' getter (standard in many versions)
      try {
        if (item.payload != null) {
          return Map<String, dynamic>.from(item.payload as Map);
        }
      } catch (_) {}

      // 2. Try 'metas' (common in underlying realtime-js/dart)
      try {
        final dynamic metas = item.metas;
        if (metas != null && metas is List && metas.isNotEmpty) {
          return Map<String, dynamic>.from(metas[0] as Map);
        }
      } catch (_) {}

      // 3. Try toJson() if it exists
      try {
        final dynamic json = item.toJson();
        if (json is Map && json.containsKey('payload')) {
          return Map<String, dynamic>.from(json['payload'] as Map);
        }
        if (json is Map && json.containsKey('metas')) {
          final dynamic metas = json['metas'];
          if (metas is List && metas.isNotEmpty) {
            return Map<String, dynamic>.from(metas[0] as Map);
          }
        }
      } catch (_) {}

      // 4. If it's already a Map, maybe it's the payload itself
      if (item is Map) {
        return Map<String, dynamic>.from(item);
      }
    } catch (e, s) {
      AppLogger.e('Failed to extract presence data: $e',
          error: e, stackTrace: s);
    }

    return null;
  }
}

import 'package:equatable/equatable.dart';

class WebhookLogEntity extends Equatable {
  final String id;
  final String webhookId;
  final String eventType;
  final Map<String, dynamic> payload;
  final int? responseStatus;
  final String? responseBody;
  final String? errorMessage;
  final int? executionTimeMs;
  final DateTime createdAt;

  const WebhookLogEntity({
    required this.id,
    required this.webhookId,
    required this.eventType,
    required this.payload,
    this.responseStatus,
    this.responseBody,
    this.errorMessage,
    this.executionTimeMs,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        webhookId,
        eventType,
        payload,
        responseStatus,
        responseBody,
        errorMessage,
        executionTimeMs,
        createdAt,
      ];

  factory WebhookLogEntity.fromJson(Map<String, dynamic> json) {
    return WebhookLogEntity(
      id: json['id'],
      webhookId: json['webhook_id'],
      eventType: json['event_type'],
      payload: Map<String, dynamic>.from(json['payload'] ?? {}),
      responseStatus: json['response_status'],
      responseBody: json['response_body'],
      errorMessage: json['error_message'],
      executionTimeMs: json['execution_time_ms'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

import 'package:equatable/equatable.dart';

class WebhookEntity extends Equatable {
  final String id;
  final String organizationId;
  final String url;
  final String secret;
  final List<String> events;
  final bool isActive;
  final DateTime createdAt;

  const WebhookEntity({
    required this.id,
    required this.organizationId,
    required this.url,
    required this.secret,
    required this.events,
    required this.isActive,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, organizationId, url, secret, events, isActive, createdAt];

  factory WebhookEntity.fromJson(Map<String, dynamic> json) {
    return WebhookEntity(
      id: json['id'],
      organizationId: json['organization_id'],
      url: json['url'],
      secret: json['secret'],
      events: List<String>.from(json['events'] ?? []),
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

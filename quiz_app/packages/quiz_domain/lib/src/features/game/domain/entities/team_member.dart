import 'package:equatable/equatable.dart';

class TeamMember extends Equatable {
  final String userId;

  const TeamMember({required this.userId});

  factory TeamMember.fromId(String id) => TeamMember(userId: id);

  @override
  List<Object?> get props => [userId];
}

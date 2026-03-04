import 'package:equatable/equatable.dart';
// Removed logger_service import
import 'team_member.dart';

class Team extends Equatable {
  final String name;
  final List<TeamMember> members;
  final int score;

  const Team({
    required this.name,
    this.members = const [],
    this.score = 0,
  });

  Team copyWith({
    String? name,
    List<TeamMember>? members,
    int? score,
  }) {
    return Team(
      name: name ?? this.name,
      members: members ?? this.members,
      score: score ?? this.score,
    );
  }

  factory Team.fromMapEntry(String name, dynamic membersData, {int score = 0}) {
    if (membersData is! List) {
      print(
          'Malformed members data for team $name: expected List, got ${membersData.runtimeType}');
      return Team(name: name, members: const [], score: score);
    }

    final members = membersData
        .whereType<String>()
        .map((id) => TeamMember.fromId(id))
        .toList();

    return Team(name: name, members: members, score: score);
  }

  @override
  List<Object?> get props => [name, members, score];
}

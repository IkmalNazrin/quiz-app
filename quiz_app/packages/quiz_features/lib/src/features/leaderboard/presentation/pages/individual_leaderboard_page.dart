import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import '../widgets/leaderboard_content.dart';

import 'package:quiz_ui_core/quiz_ui_core.dart';

class IndividualLeaderboardPage extends ConsumerStatefulWidget {
  final String quizId;
  final String quizTitle;

  const IndividualLeaderboardPage({
    super.key,
    required this.quizId,
    required this.quizTitle,
  });

  @override
  ConsumerState<IndividualLeaderboardPage> createState() =>
      _IndividualLeaderboardPageState();
}

class _IndividualLeaderboardPageState
    extends ConsumerState<IndividualLeaderboardPage> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.quizTitle} - Players'),
      ),
      body: Stack(
        children: [
          LeaderboardContentView(
            quizId: widget.quizId,
            isTeam: false,
            quizTitle: widget.quizTitle,
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                AppColors.primary,
                AppColors.accent,
                AppColors.secondary,
                Colors.white,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

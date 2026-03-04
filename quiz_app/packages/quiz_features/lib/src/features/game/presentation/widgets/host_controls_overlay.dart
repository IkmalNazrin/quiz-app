import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_ui_core/quiz_ui_core.dart';
import 'package:quiz_features/quiz_features.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HostControlsOverlay extends ConsumerStatefulWidget {
  const HostControlsOverlay({super.key});

  @override
  ConsumerState<HostControlsOverlay> createState() =>
      _HostControlsOverlayState();
}

class _HostControlsOverlayState extends ConsumerState<HostControlsOverlay> {
  bool _isExpanded = false;
  int _answeredCount = 0;
  StreamSubscription? _eventSub;

  @override
  void initState() {
    super.initState();
    _eventSub =
        ref.read(gameRealtimeServiceProvider).eventsStream.listen((event) {
      if (event['event'] == 'answer-count-update') {
        if (mounted) {
          setState(() {
            _answeredCount = event['payload']['count'] ?? 0;
          });
        }
      } else if (event['event'] == 'new-question') {
        if (mounted) {
          setState(() {
            _answeredCount = 0;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() => _isExpanded = !_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameSessionProvider);
    final isPaused = gameState.status == 'paused';
    final isRoundOver = gameState.status == 'round_over';
    final isManualFlow = gameState.isManualFlow;
    final totalPlayers = gameState.players.length;

    return AnimatedPositioned(
      duration: 400.ms,
      curve: Curves.easeOutBack,
      bottom: _isExpanded ? 0 : -220,
      left: 0,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle / Tab
          GestureDetector(
            onTap: _toggleExpanded,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.9),
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
                border:
                    Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, -2))
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_up_rounded,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'HOST CONTROLS',
                    style: AppTypography.label.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  if (!isRoundOver) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        '$_answeredCount/$totalPlayers',
                        style: AppTypography.label.copyWith(
                          fontSize: 10,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Controls Body
          Container(
            padding: EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 40),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                  top: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.3))),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildControlItem(
                        icon: isPaused
                            ? Icons.play_arrow_rounded
                            : Icons.pause_rounded,
                        label: isPaused ? 'Resume' : 'Pause',
                        color: isPaused ? AppColors.success : AppColors.warning,
                        onTap: () => ref
                            .read(gameSessionProvider.notifier)
                            .togglePause(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _buildControlItem(
                        icon: Icons.skip_next_rounded,
                        label: isRoundOver ? 'Next Question' : 'Skip Round',
                        color: AppColors.primary,
                        onTap: () {
                          if (isRoundOver) {
                            ref
                                .read(gameSessionProvider.notifier)
                                .nextQuestion();
                          } else {
                            ref
                                .read(gameSessionProvider.notifier)
                                .skipQuestion();
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Manual Flow',
                            style: AppTypography.bodySmall
                                .copyWith(fontWeight: FontWeight.bold)),
                        Text(
                          'Wait for host for next round',
                          style: AppTypography.label.copyWith(
                              fontSize: 10, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    Switch(
                      value: isManualFlow,
                      onChanged: (val) => ref
                          .read(gameSessionProvider.notifier)
                          .setManualFlow(val),
                      activeThumbColor: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: AppTypography.label.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

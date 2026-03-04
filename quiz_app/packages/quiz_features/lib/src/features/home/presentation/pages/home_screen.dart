import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/game/presentation/providers/game_session_provider.dart';

import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_ui_core/quiz_ui_core.dart';
import 'package:quiz_features/quiz_features.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final String quizId;
  final String quizTitle;

  const HomeScreen({
    super.key,
    required this.quizId,
    required this.quizTitle,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _nicknameController = TextEditingController(text: "Host");
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Socket connection is now handled automatically by GameSessionNotifier constructor
  }

  void _hostGame() async {
    if (_nicknameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a nickname.')));
      return;
    }

    final token = null; // Unused in repo layer

    setState(() => _isLoading = true);
    try {
      await ref.read(gameSessionProvider.notifier).hostGame(
            _nicknameController.text.trim(),
            widget.quizId,
            token,
          );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to host game: $e')));
      }
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Widget _buildConnectionStatus(String socketStatus) {
    Color color;
    String label;
    IconData icon;

    switch (socketStatus) {
      case 'connected':
        color = AppColors.success;
        label = 'Online';
        icon = Icons.check_circle_outline;
        break;
      case 'connecting':
        color = AppColors.accent;
        label = 'Connecting...';
        icon = Icons.sync;
        break;
      case 'error':
      case 'disconnected':
      default:
        color = AppColors.error;
        label = 'Offline';
        icon = Icons.error_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.label
                .copyWith(color: color, fontWeight: FontWeight.bold),
          ),
          if (socketStatus == 'error' || socketStatus == 'disconnected') ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => ref.read(gameSessionProvider.notifier).connect(),
              child: Text(
                'RETRY',
                style: AppTypography.label.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameSessionProvider);
    final isConnected = gameState.socketStatus == 'connected';

    ref.listen(gameSessionProvider, (previous, next) {
      if (next.status == 'lobby' && (previous?.status != 'lobby')) {
        context.goNamed('lobby', pathParameters: {'pin': next.gamePin});
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Host Quiz', style: AppTypography.h2),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Glow Decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                begin: const Offset(1, 1),
                end: const Offset(1.2, 1.2),
                duration: 4.seconds,
                curve: Curves.easeInOut),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      children: [
                        _buildConnectionStatus(gameState.socketStatus)
                            .animate()
                            .fadeIn(delay: 100.ms),
                        const SizedBox(height: AppSpacing.xl),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.rocket_launch,
                                  size: 48, color: AppColors.primary)
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .moveY(
                                  begin: -5,
                                  end: 5,
                                  duration: 2.seconds,
                                  curve: Curves.easeInOut),
                        )
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .scale(curve: Curves.easeOutBack),
                        const SizedBox(height: AppSpacing.xl),
                        Text(widget.quizTitle,
                                style: AppTypography.h2,
                                textAlign: TextAlign.center)
                            .animate()
                            .fadeIn(delay: 200.ms)
                            .slideY(begin: 0.2),
                        const SizedBox(height: AppSpacing.sm),
                        Text('Prepare your arena for players',
                                style: AppTypography.bodySmall)
                            .animate()
                            .fadeIn(delay: 300.ms)
                            .slideY(begin: 0.2),
                        const SizedBox(height: AppSpacing.xxl),
                        AppTextField(
                          controller: _nicknameController,
                          label: 'Host Nickname',
                          hintText: 'e.g. Professor Quiz',
                          prefixIcon: const Icon(Icons.person_outline),
                          autofocus: _nicknameController.text.isEmpty,
                        ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1),
                        const SizedBox(height: AppSpacing.xl),
                        AppButton(
                          label: 'Launch Arena',
                          onPressed: isConnected ? _hostGame : null,
                          isLoading: _isLoading,
                          icon: const Icon(Icons.play_arrow_rounded),
                        )
                            .animate()
                            .fadeIn(delay: 500.ms)
                            .scale(curve: Curves.easeOutBack),
                        if (!isConnected) ...[
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Waiting for server connection...',
                            style: AppTypography.label
                                .copyWith(color: AppColors.error),
                          ).animate().fadeIn(),
                        ],
                      ],
                    ),
                  ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.05),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Game code will be generated in the lobby',
                    style: AppTypography.label
                        .copyWith(color: AppColors.textSecondary),
                  ).animate().fadeIn(delay: 1.seconds),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

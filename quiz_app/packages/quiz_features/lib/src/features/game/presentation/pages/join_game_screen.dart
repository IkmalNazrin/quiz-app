import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../features/game/presentation/providers/game_session_provider.dart';
import 'package:go_router/go_router.dart';


import 'package:quiz_ui_core/quiz_ui_core.dart';

class JoinGameScreen extends ConsumerStatefulWidget {
  final String gamePin;

  const JoinGameScreen({super.key, required this.gamePin});

  @override
  ConsumerState<JoinGameScreen> createState() => _JoinGameScreenState();
}

class _JoinGameScreenState extends ConsumerState<JoinGameScreen> {
  final _nicknameController = TextEditingController();

  void _joinGame() {
    final nicknameError =
        ContentModeration.validateNickname(_nicknameController.text);
    if (nicknameError != null) {
      HapticService.error();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(nicknameError,
            style: AppTypography.bodySmall.copyWith(color: Colors.white)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
      ));
      return;
    }

    ref.read(gameSessionProvider.notifier).joinGame(
          _nicknameController.text,
          widget.gamePin,
          null,
        );
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameStatus = ref.watch(gameSessionProvider).socketStatus;
    final isConnecting = gameStatus == 'connecting';

    ref.listen(gameSessionProvider, (previous, next) {
      if (next.status == 'lobby' && previous?.status != 'lobby') {
        HapticService.success();
        context.goNamed('lobby', pathParameters: {'pin': widget.gamePin});
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Dynamic Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.midnightGradient,
              ),
            ),
          ),
          _buildBackgroundParticles(),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                          border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              width: 2),
                        ),
                        child: const Icon(Icons.person_add_rounded,
                            color: AppColors.primary, size: 48),
                      )
                          .animate()
                          .scale(
                              delay: 200.ms, curve: AppAnimations.springCurve)
                          .shimmer(delay: 1.seconds, duration: 2.seconds),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'ARENA IDENTITY',
                        style: AppTypography.h2
                            .copyWith(color: Colors.white, letterSpacing: 2),
                      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'How shall the legends call you?',
                        style: AppTypography.bodySmall
                            .copyWith(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 400.ms),
                      const SizedBox(height: AppSpacing.xl),
                      AppTextField(
                        controller: _nicknameController,
                        label: 'Your Nickname',
                        hintText: 'e.g. Captain Quiz',
                        prefixIcon: const Icon(Icons.face_rounded),
                        autofocus: true,
                      ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),
                      const SizedBox(height: AppSpacing.xl),
                      AppButton(
                        label: isConnecting ? 'Entering...' : 'Join Arena',
                        onPressed: isConnecting ? null : _joinGame,
                        type: AppButtonType.premium,
                        width: double.infinity,
                        height: 60,
                        icon: isConnecting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.bolt_rounded,
                                color: Colors.white),
                      )
                          .animate()
                          .fadeIn(delay: 600.ms)
                          .scale(curve: AppAnimations.springCurve),
                      if (isConnecting)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.md),
                          child: Text(
                            'Securing your identity...',
                            style: AppTypography.label.copyWith(
                                color:
                                    AppColors.primary.withValues(alpha: 0.8)),
                          ).animate(onPlay: (c) => c.repeat()).shimmer(),
                        ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn()
                    .slideY(begin: 0.1, curve: AppAnimations.springCurve),
              ),
            ),
          ),

          // Glass Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassHeader(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white),
                onPressed: () => context.pop(),
              ),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('ARENA PIN',
                      style: AppTypography.label.copyWith(
                          color: Colors.white70,
                          letterSpacing: 2,
                          fontSize: 10)),
                  Text(widget.gamePin,
                      style: AppTypography.h3.copyWith(
                          color: Colors.white,
                          letterSpacing: 4,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundParticles() {
    return Stack(
      children: List.generate(8, (index) {
        final size = 2.0 + (index % 3) * 2;
        return Positioned(
          bottom: 150.0 * (index % 5),
          left: (index * 70.0) % 400,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .moveX(
                  begin: 0,
                  end: 50,
                  duration: (5 + (index % 3)).seconds,
                  curve: Curves.easeInOut)
              .fadeIn()
              .then(delay: 2.seconds)
              .fadeOut(),
        );
      }),
    );
  }
}

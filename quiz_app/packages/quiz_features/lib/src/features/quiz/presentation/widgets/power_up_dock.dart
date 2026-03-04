import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_ui_core/quiz_ui_core.dart';
import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_features/quiz_features.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PowerUpDock extends ConsumerWidget {
  final VoidCallback? onUse5050;
  final VoidCallback? onUseDoubleDown;
  final VoidCallback? onUseRetry;
  final bool isAnswerSubmitted;

  const PowerUpDock({
    super.key,
    this.onUse5050,
    this.onUseDoubleDown,
    this.onUseRetry,
    this.isAnswerSubmitted = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameSessionProvider);
    final inventory = gameState.powerUpInventory;

    if (gameState.powerUpMode == 'disabled') return const SizedBox.shrink();

    return ClipRRect(
      borderRadius:
          const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.6),
            border: Border(
              top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1), width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _PowerUpButton(
                  type: PowerUpType.fiftyFifty,
                  count: inventory[PowerUpType.fiftyFifty] ?? 0,
                  onTap: onUse5050,
                  isAnswerSubmitted: isAnswerSubmitted,
                ),
                _PowerUpButton(
                  type: PowerUpType.doubleDown,
                  count: inventory[PowerUpType.doubleDown] ?? 0,
                  onTap: onUseDoubleDown,
                  isAnswerSubmitted: isAnswerSubmitted,
                ),
                _PowerUpButton(
                  type: PowerUpType.secondChance,
                  count: inventory[PowerUpType.secondChance] ?? 0,
                  onTap: onUseRetry,
                  isAnswerSubmitted: isAnswerSubmitted,
                  isSpecial: true,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().slideY(begin: 1, duration: 600.ms, curve: Curves.easeOutBack);
  }
}

class _PowerUpButton extends ConsumerStatefulWidget {
  final PowerUpType type;
  final int count;
  final VoidCallback? onTap;
  final bool isAnswerSubmitted;
  final bool isSpecial;

  const _PowerUpButton({
    required this.type,
    required this.count,
    this.onTap,
    required this.isAnswerSubmitted,
    this.isSpecial = false,
  });

  @override
  ConsumerState<_PowerUpButton> createState() => _PowerUpButtonState();
}

class _PowerUpButtonState extends ConsumerState<_PowerUpButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.count > 0 && !widget.isAnswerSubmitted) {
      _controller.forward().then((_) => _controller.reverse());
      if (widget.onTap != null) {
        ref.read(gameSessionProvider.notifier).usePowerUp(widget.type);
        widget.onTap!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAvailable = widget.count > 0 && !widget.isAnswerSubmitted;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: GestureDetector(
          onTap: _handleTap,
          child: Opacity(
            opacity: isAvailable ? 1.0 : 0.4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? widget.type.color.withValues(alpha: 0.15)
                            : Colors.grey.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isAvailable
                              ? widget.type.color
                              : Colors.grey.withValues(alpha: 0.3),
                          width: 2,
                        ),
                        boxShadow: isAvailable && widget.isSpecial
                            ? [
                                BoxShadow(
                                  color:
                                      widget.type.color.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                )
                              ]
                            : null,
                      ),
                      child: Icon(
                        widget.type.icon,
                        color: isAvailable ? widget.type.color : Colors.grey,
                        size: 28,
                      ),
                    ),
                    if (widget.count > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppColors.background, width: 2),
                          ),
                          child: Text(
                            '${widget.count}',
                            style: AppTypography.label.copyWith(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                            .animate(key: ValueKey(widget.count))
                            .scale(duration: 300.ms, curve: Curves.elasticOut),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  widget.type.label.toUpperCase(),
                  style: AppTypography.label.copyWith(
                    fontSize: 10,
                    color: isAvailable
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

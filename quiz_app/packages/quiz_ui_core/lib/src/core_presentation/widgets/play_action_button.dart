import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../design_system.dart';

class PlayActionButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isActive;

  const PlayActionButton({
    super.key,
    required this.onPressed,
    this.isActive = false,
  });

  @override
  State<PlayActionButton> createState() => _PlayActionButtonState();
}

class _PlayActionButtonState extends State<PlayActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _burstController;
  bool _isAnimatingEffect = false;

  @override
  void initState() {
    super.initState();
    _burstController = AnimationController(vsync: this, duration: 800.ms);
  }

  @override
  void dispose() {
    _burstController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (_isAnimatingEffect) return;

    // Clean iOS-style Haptics
    HapticFeedback.lightImpact();

    setState(() => _isAnimatingEffect = true);

    // Smooth Squish & Pop Sequence
    _burstController.forward(from: 0).then((_) {
      if (mounted) setState(() => _isAnimatingEffect = false);
    });

    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    const size = 64.0; // Prominent YouTube-style scale

    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        width: size + 20,
        height: size + 20,
        color: Colors.transparent, // Ensure good hit area
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Soft background glow (Always breathing)
            Container(
              width: size - 4,
              height: size - 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                begin: const Offset(1, 1),
                end: const Offset(1.15, 1.15),
                duration: 2500.ms,
                curve: Curves.easeInOutSine),

            // Inner Button with Squish/Pop
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF8B5CF6), // Primary Purple
                    Color(0xFF7C3AED), // Darker Purple
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 38, // Refined icon size for 64px button
              ),
            )
                .animate(target: widget.isActive ? 1 : 0)
                .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.1, 1.1),
                    duration: 300.ms,
                    curve: Curves.easeOutBack)
                .animate(target: _isAnimatingEffect ? 1 : 0)
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(0.85, 0.85),
                  duration: 80.ms,
                  curve: Curves.easeOutCubic,
                )
                .then()
                .scale(
                  begin: const Offset(0.85, 0.85),
                  end: const Offset(1.1, 1.1),
                  duration: 200.ms,
                  curve: Curves.easeOutBack,
                )
                .then()
                .scale(
                  begin: const Offset(1.1, 1.1),
                  end: const Offset(1, 1),
                  duration: 150.ms,
                  curve: Curves.easeOutQuad,
                ),
          ],
        ),
      ),
    );
  }
}

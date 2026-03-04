import 'dart:math';
import 'package:flutter/material.dart';
import '../design_system.dart';

class StarryBackground extends StatefulWidget {
  final Widget child;
  const StarryBackground({super.key, required this.child});

  @override
  State<StarryBackground> createState() => _StarryBackgroundState();
}

class _StarryBackgroundState extends State<StarryBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Star> _stars = List.generate(100, (index) => Star());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: RepaintBoundary(child: widget.child),
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: AppColors.midnightGradient,
          ),
          child: CustomPaint(
            painter: StarryPainter(_stars, _controller.value),
            child: child,
          ),
        );
      },
    );
  }
}

class Star {
  final double x = Random().nextDouble();
  final double y = Random().nextDouble();
  final double size = Random().nextDouble() * 2 + 0.5;
  final double pulseSpeed = Random().nextDouble() * 2 + 0.5;

  Star();
}

class StarryPainter extends CustomPainter {
  final List<Star> stars;
  final double animationValue;

  StarryPainter(this.stars, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    for (var star in stars) {
      final opacity =
          (0.3 + 0.7 * sin(animationValue * 2 * pi * star.pulseSpeed))
              .clamp(0.1, 1.0);
      paint.color = Colors.white.withValues(alpha: opacity);

      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant StarryPainter oldDelegate) => true;
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../design_system.dart';
import '../app_icons.dart';

class GamifiedNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const GamifiedNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85,
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Frosted Glass Layer
          ClipPath(
            clipper: _NotchedNavBarClipper(),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                height: 64, // Standard ergonomic height (Material/iOS)
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  border: Border(
                    top: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Navigation Items
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavItem(
                  icon: AppIcons.search,
                  label: 'Browse',
                  isSelected: currentIndex == 0,
                  onTap: () => _handleTap(0),
                  index: 0,
                ),
                _NavItem(
                  icon: AppIcons.social,
                  label: 'Social',
                  isSelected: currentIndex == 1,
                  onTap: () => _handleTap(1),
                  index: 1,
                ),
                // Wide spacer for ergonomic Play button
                const SizedBox(width: 70),
                _NavItem(
                  icon: AppIcons.editor,
                  label: 'Workshop',
                  isSelected: currentIndex == 3,
                  onTap: () => _handleTap(3),
                  index: 3,
                ),
                _NavItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Profile',
                  isSelected: currentIndex == 4,
                  onTap: () => _handleTap(4),
                  index: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleTap(int index) {
    if (index != currentIndex) {
      HapticFeedback.selectionClick();
      onTap(index);
    }
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int index;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 56, // Generous width for all fingertip sizes
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (isSelected)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                  ).animate().scale(
                        begin: const Offset(0, 0),
                        end: const Offset(1, 1),
                        duration: 400.ms,
                        curve: Curves.elasticOut,
                      ),
                Icon(
                  icon,
                  color: color,
                  size: 22, // Balanced icon size
                )
                    .animate(target: isSelected ? 1 : 0)
                    .scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.1, 1.1),
                        duration: 200.ms)
                    .moveY(begin: 0, end: -1, duration: 200.ms),
              ],
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: AppTypography.label.copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 9, // readable micro-labels
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (index * 50).ms, duration: 300.ms)
        .slideY(begin: 0.1, end: 0);
  }
}

class _NotchedNavBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();

    // Geometry Constants
    const double barHeight = 64.0;
    const double buttonRadius = 32.0; // Half of 64px
    const double gap = 8.0; // Proportional gap for larger button
    const double totalNotchRadius = buttonRadius + gap; // 40.0

    final double centerX = size.width / 2;
    final double topPadding = size.height - barHeight;

    path.moveTo(0, topPadding + 20);
    path.quadraticBezierTo(0, topPadding, 20, topPadding);

    // Shoulder transition starts here
    final double shoulderWidth = 16.0;
    path.lineTo(centerX - totalNotchRadius - shoulderWidth, topPadding);

    // Smooth Inward Shoulder
    path.cubicTo(
      centerX - totalNotchRadius - 6,
      topPadding,
      centerX - totalNotchRadius,
      topPadding,
      centerX - totalNotchRadius + 4,
      topPadding + 6,
    );

    // Main Circular Notch (Approximated with accurate Bezier for smoothness)
    path.arcToPoint(
      Offset(centerX + totalNotchRadius - 4, topPadding + 6),
      radius: const Radius.circular(totalNotchRadius),
      clockwise: false,
    );

    // Smooth Outward Shoulder
    path.cubicTo(
      centerX + totalNotchRadius,
      topPadding,
      centerX + totalNotchRadius + 6,
      topPadding,
      centerX + totalNotchRadius + shoulderWidth,
      topPadding,
    );

    path.lineTo(size.width - 20, topPadding);
    path.quadraticBezierTo(size.width, topPadding, size.width, topPadding + 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

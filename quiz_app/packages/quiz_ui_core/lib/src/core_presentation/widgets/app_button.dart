import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../design_system.dart';

enum AppButtonType { primary, secondary, outline, ghost, premium }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final Widget? icon;
  final bool isLoading;
  final double? width;
  final double? height;

  final Color? color;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: _buildButton(context),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true)).shimmer(
          duration: 3.seconds,
          color: Colors.white.withValues(alpha: 0.1),
          delay: 5.seconds,
        );
  }

  void _handlePress() {
    if (onPressed != null) {
      HapticFeedback.lightImpact();
      onPressed!();
    }
  }

  Widget _buildButton(BuildContext context) {
    switch (type) {
      case AppButtonType.primary:
        return _PrimaryButton(
            label: label,
            onPressed: _handlePress,
            isLoading: isLoading,
            icon: icon,
            height: height,
            color: color);
      case AppButtonType.secondary:
        return _SecondaryButton(
            label: label,
            onPressed: _handlePress,
            isLoading: isLoading,
            icon: icon,
            height: height,
            color: color);
      case AppButtonType.outline:
        return _OutlineButton(
            label: label,
            onPressed: _handlePress,
            isLoading: isLoading,
            icon: icon,
            height: height,
            color: color);
      case AppButtonType.ghost:
        return _GhostButton(
            label: label,
            onPressed: _handlePress,
            isLoading: isLoading,
            icon: icon,
            height: height,
            color: color);
      case AppButtonType.premium:
        return _PremiumButton(
            label: label,
            onPressed: _handlePress,
            isLoading: isLoading,
            icon: icon,
            height: height);
    }
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final double? height;
  final Color? color;

  const _PrimaryButton(
      {required this.label,
      this.onPressed,
      this.isLoading = false,
      this.icon,
      this.height,
      this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: (color == null && onPressed != null)
            ? AppColors.primaryGradient
            : null,
        color: color ?? (onPressed == null ? Colors.grey[300] : null),
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: (color ?? AppColors.primary).withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: height != null
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          minimumSize: height != null ? Size.zero : null,
          tapTargetSize:
              height != null ? MaterialTapTargetSize.shrinkWrap : null,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md)),
        ),
        child: _Content(
            label: label,
            isLoading: isLoading,
            icon: icon,
            textColor: Colors.white),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final double? height;
  final Color? color;

  const _SecondaryButton(
      {required this.label,
      this.onPressed,
      this.isLoading = false,
      this.icon,
      this.height,
      this.color});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? AppColors.secondary,
        foregroundColor: Colors.white,
        padding: height != null
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        minimumSize: height != null ? Size.zero : null,
        tapTargetSize: height != null ? MaterialTapTargetSize.shrinkWrap : null,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
        elevation: 2,
      ),
      child: _Content(
          label: label,
          isLoading: isLoading,
          icon: icon,
          textColor: Colors.white),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final double? height;
  final Color? color;

  const _OutlineButton(
      {required this.label,
      this.onPressed,
      this.isLoading = false,
      this.icon,
      this.height,
      this.color});

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: effectiveColor, width: 2),
        padding: height != null
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        minimumSize: height != null ? Size.zero : null,
        tapTargetSize: height != null ? MaterialTapTargetSize.shrinkWrap : null,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      child: _Content(
          label: label,
          isLoading: isLoading,
          icon: icon,
          textColor: effectiveColor),
    );
  }
}

class _GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final double? height;
  final Color? color;

  const _GhostButton(
      {required this.label,
      this.onPressed,
      this.isLoading = false,
      this.icon,
      this.height,
      this.color});

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        padding: height != null
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        minimumSize: height != null ? Size.zero : null,
        tapTargetSize: height != null ? MaterialTapTargetSize.shrinkWrap : null,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      child: _Content(
          label: label,
          isLoading: isLoading,
          icon: icon,
          textColor: effectiveColor),
    );
  }
}

class _PremiumButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final double? height;

  const _PremiumButton(
      {required this.label,
      this.onPressed,
      this.isLoading = false,
      this.icon,
      this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: onPressed != null ? AppColors.premiumGold : null,
        color: onPressed == null ? Colors.grey[300] : null,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: const Color(0xFFFFA500).withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: height != null
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          minimumSize: height != null ? Size.zero : null,
          tapTargetSize:
              height != null ? MaterialTapTargetSize.shrinkWrap : null,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md)),
        ),
        child: _Content(
            label: label,
            isLoading: isLoading,
            icon: icon,
            textColor: Colors.white),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(duration: 2.seconds, color: Colors.white24);
  }
}

class _Content extends StatelessWidget {
  final String label;
  final bool isLoading;
  final Widget? icon;
  final Color textColor;

  const _Content(
      {required this.label,
      this.isLoading = false,
      this.icon,
      required this.textColor});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: textColor),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          icon!,
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../design_system.dart';

enum StatusBadgeType {
  standard,
  success,
  warning,
  error,
  secondary,
}

class StatusBadge extends StatelessWidget {
  final String label;
  final StatusBadgeType type;
  final bool isSmall;

  const StatusBadge({
    super.key,
    required this.label,
    this.type = StatusBadgeType.standard,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (type) {
      case StatusBadgeType.success:
        color = AppColors.success;
        break;
      case StatusBadgeType.warning:
        color = AppColors.warning;
        break;
      case StatusBadgeType.error:
        color = AppColors.error;
        break;
      case StatusBadgeType.secondary:
        color = AppColors.secondary;
        break;
      case StatusBadgeType.standard:
        color = AppColors.primary;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 6 : 8, vertical: isSmall ? 2 : 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: isSmall ? 10 : 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

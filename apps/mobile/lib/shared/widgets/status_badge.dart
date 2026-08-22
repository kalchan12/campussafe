import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool isActive;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? color.withValues(alpha: 0.1) : AppColors.inactive.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? color : AppColors.inactive,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? color : AppColors.inactive,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? color : AppColors.inactive,
            ),
          ),
        ],
      ),
    );
  }
}

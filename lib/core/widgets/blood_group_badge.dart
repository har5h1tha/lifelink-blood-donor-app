import 'package:flutter/material.dart';
import '../colors.dart';

class BloodGroupBadge extends StatelessWidget {
  final String group;
  final double size;

  const BloodGroupBadge({super.key, required this.group, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: Text(
        group,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.36,
        ),
      ),
    );
  }
}

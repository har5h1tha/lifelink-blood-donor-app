import 'package:flutter/material.dart';
import '../colors.dart';

class UrgencyChip extends StatelessWidget {
  final String urgency; // 'Critical', 'High' or 'Normal'

  const UrgencyChip({super.key, required this.urgency});

  Color get _color {
    switch (urgency) {
      case 'Critical':
        return AppColors.urgentCritical;
      case 'High':
        return AppColors.urgentHigh;
      default:
        return AppColors.urgentNormal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: Text(
        urgency,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

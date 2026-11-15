import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/widgets/blood_group_badge.dart';
import '../../models/user_model.dart';

/// One donor row in the list. Tap -> [onTap] (opens the details sheet).
class DonorCard extends StatelessWidget {
  final UserModel donor;
  final VoidCallback onTap;

  const DonorCard({super.key, required this.donor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppSizes.gap / 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.padding),
          child: Row(
            children: [
              BloodGroupBadge(group: donor.bloodGroup),
              const SizedBox(width: AppSizes.padding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(donor.name,
                        style: textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 16, color: Theme.of(context).hintColor),
                        const SizedBox(width: 4),
                        Text(donor.city, style: textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
              // Green "Available" dot
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('Available',
                      style: textTheme.bodySmall
                          ?.copyWith(color: AppColors.success)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

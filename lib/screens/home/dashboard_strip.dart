import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/colors.dart';
import '../../viewmodels/donor_viewmodel.dart';
import '../../viewmodels/request_viewmodel.dart';

class DashboardStrip extends StatelessWidget {
  const DashboardStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final donorCount = context.watch<DonorViewModel>().totalAvailable;

    final requestCount = context.watch<RequestViewModel>().openCount;

    return Row(
      children: [
        Expanded(
          child: _DashboardCard(
            title: 'Available Donors',
            count: donorCount.toString(),
            icon: Icons.people_outline,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _DashboardCard(
            title: 'Open Requests',
            count: requestCount.toString(),
            icon: Icons.assignment_outlined,
          ),
        ),
      ],
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;

  const _DashboardCard({
    required this.title,
    required this.count,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppSizes.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 30),
            const SizedBox(height: 8),
            Text(
              count,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

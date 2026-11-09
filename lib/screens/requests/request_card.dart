import 'package:flutter/material.dart';
 
import '../../core/colors.dart';
import '../../core/constants.dart';
import '../../core/routes.dart';
import '../../core/widgets/blood_group_badge.dart';
import '../../core/widgets/urgency_chip.dart';
import '../../models/request_model.dart';
 
/// Turns a date into text like "2 hours ago".
String timeAgo(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) {
    return '${diff.inHours} ${diff.inHours == 1 ? 'hour' : 'hours'} ago';
  }
  return '${diff.inDays} ${diff.inDays == 1 ? 'day' : 'days'} ago';
}
 
/// Green "Fulfilled" chip (also used on the details screen).
class FulfilledChip extends StatelessWidget {
  const FulfilledChip({super.key});
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.gap, vertical: AppSizes.gap / 2),
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: const Text(
        'Fulfilled',
        style: TextStyle(
            color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
 
/// One request in the list. Tap opens the details screen.
class RequestCard extends StatelessWidget {
  final RequestModel request;
 
  const RequestCard({super.key, required this.request});
 
  @override
  Widget build(BuildContext context) {
    final fulfilled = request.status == statusFulfilled;
    final textTheme = Theme.of(context).textTheme;
    // Fulfilled requests look faded (greyed out)
    final fade = fulfilled ? 0.5 : 1.0;
 
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.gap),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.requestDetails,
          arguments: request, // /request-details receives a RequestModel
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.padding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side: badge + patient info
              Expanded(
                child: Opacity(
                  opacity: fade,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BloodGroupBadge(group: request.bloodGroup),
                      const SizedBox(width: AppSizes.padding),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              request.patientName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: AppSizes.gap / 2),
                            _InfoRow(
                                icon: Icons.local_hospital_outlined,
                                text: request.hospital),
                            _InfoRow(
                                icon: Icons.location_on_outlined,
                                text:
                                    '${request.city}  •  ${timeAgo(request.createdAt)}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.gap),
              // Right side: urgency chip (+ Fulfilled chip when done)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Opacity(
                      opacity: fade,
                      child: UrgencyChip(urgency: request.urgency)),
                  if (fulfilled) ...[
                    const SizedBox(height: AppSizes.gap),
                    const FulfilledChip(),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
 
/// Small icon + text line used inside the card.
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
 
  const _InfoRow({required this.icon, required this.text});
 
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.gap / 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: AppSizes.gap / 2),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
 
import '../../core/colors.dart';
import '../../core/constants.dart';
import '../../core/widgets/blood_group_badge.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/urgency_chip.dart';
import '../../models/request_model.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/request_viewmodel.dart';
import 'request_card.dart';
 
class RequestDetailsScreen extends StatelessWidget {
  const RequestDetailsScreen({super.key});
 
  // Opens the phone dialer with the requester's number
  Future<void> _call(BuildContext context, String phone) async {
    var opened = false;
    try {
      opened = await launchUrl(Uri(scheme: 'tel', path: phone));
    } catch (_) {
      opened = false;
    }
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the dialer')));
    }
  }
 
  // Asks "Are you sure?" before deleting
  Future<void> _confirmDelete(
      BuildContext context, RequestViewModel vm, RequestModel r) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete request?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete',
                  style: TextStyle(color: AppColors.urgentCritical))),
        ],
      ),
    );
    if (confirmed != true) return;
    await vm.deleteRequest(r.id);
    if (!context.mounted) return;
    Navigator.pop(context); // leave the details screen
  }
 
  @override
  Widget build(BuildContext context) {
    // The card passes a RequestModel as the route argument
    final args = ModalRoute.of(context)!.settings.arguments as RequestModel;
    final vm = context.watch<RequestViewModel>();
    final currentUser = context.watch<AuthViewModel>().currentUser;
 
    // Use the latest copy so the screen updates after "Mark as fulfilled"
    final request = vm.findById(args.id) ?? args;
    final fulfilled = request.status == statusFulfilled;
    final isOwner = currentUser != null && request.createdBy == currentUser.uid;
 
    return Scaffold(
      appBar: AppBar(title: const Text('Request Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        BloodGroupBadge(group: request.bloodGroup, size: 64),
                        const SizedBox(width: AppSizes.padding),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                request.patientName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: AppSizes.gap),
                              Row(
                                children: [
                                  UrgencyChip(urgency: request.urgency),
                                  if (fulfilled) ...[
                                    const SizedBox(width: AppSizes.gap),
                                    const FulfilledChip(),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: AppSizes.padding * 2),
                    _DetailRow(
                        icon: Icons.bloodtype,
                        label: 'Blood group',
                        value: request.bloodGroup),
                    _DetailRow(
                        icon: Icons.local_hospital_outlined,
                        label: 'Hospital',
                        value: request.hospital),
                    _DetailRow(
                        icon: Icons.location_on_outlined,
                        label: 'City',
                        value: request.city),
                    _DetailRow(
                        icon: Icons.phone_outlined,
                        label: 'Contact phone',
                        value: request.contactPhone),
                    _DetailRow(
                        icon: Icons.access_time,
                        label: 'Posted',
                        value:
                            '${DateFormat('dd MMM yyyy, hh:mm a').format(request.createdAt)} (${timeAgo(request.createdAt)})'),
                    _DetailRow(
                        icon: Icons.info_outline,
                        label: 'Status',
                        value: fulfilled ? 'Fulfilled' : 'Open'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.padding),
            // Disabled when the request is already fulfilled
            PrimaryButton(
              label: 'I can donate: call requester',
              icon: Icons.call,
              onPressed:
                  fulfilled ? null : () => _call(context, request.contactPhone),
            ),
            // Owner-only actions
            if (isOwner) ...[
              const SizedBox(height: AppSizes.gap),
              if (!fulfilled)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
                    foregroundColor: AppColors.success,
                    side: const BorderSide(color: AppColors.success),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radius)),
                  ),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Mark as fulfilled'),
                  onPressed: () => vm.markFulfilled(request.id),
                ),
              if (!fulfilled) const SizedBox(height: AppSizes.gap),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
                  foregroundColor: AppColors.urgentCritical,
                  side: const BorderSide(color: AppColors.urgentCritical),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radius)),
                ),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete'),
                onPressed: () => _confirmDelete(context, vm, request),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
 
/// One "icon  Label  value" line in the details card.
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
 
  const _DetailRow(
      {required this.icon, required this.label, required this.value});
 
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.gap),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: AppSizes.padding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: textTheme.bodySmall
                        ?.copyWith(color: AppColors.textSecondary)),
                Text(value, style: textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
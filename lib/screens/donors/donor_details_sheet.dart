import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/colors.dart';
import '../../core/widgets/blood_group_badge.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/user_model.dart';

/// Bottom sheet with donor details and Call / SMS buttons.
void showDonorDetailsSheet(BuildContext context, UserModel donor) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radius)),
    ),
    builder: (sheetContext) => _DonorDetailsContent(donor: donor),
  );
}

class _DonorDetailsContent extends StatelessWidget {
  final UserModel donor;
  const _DonorDetailsContent({required this.donor});

  // Open the phone dialer or messaging app.
  Future<void> _launch(BuildContext context, String scheme) async {
    final uri = Uri(scheme: scheme, path: donor.phone);
    final ok = await launchUrl(uri);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the app on this device')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final lastDonatedText = donor.lastDonated == null
        ? 'Never donated'
        : DateFormat('dd MMM yyyy').format(donor.lastDonated!);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSizes.padding, 0, AppSizes.padding, AppSizes.padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                BloodGroupBadge(group: donor.bloodGroup, size: 56),
                const SizedBox(width: AppSizes.padding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(donor.name,
                          style: textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(donor.city, style: textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.padding),
            _infoRow(context, Icons.bloodtype, 'Blood group', donor.bloodGroup),
            _infoRow(context, Icons.location_city, 'City', donor.city),
            _infoRow(context, Icons.event, 'Last donated', lastDonatedText),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: 'Call',
                    icon: Icons.call,
                    onPressed: () => _launch(context, 'tel'),
                  ),
                ),
                const SizedBox(width: AppSizes.gap),
                Expanded(
                  child: PrimaryButton(
                    label: 'SMS',
                    icon: Icons.sms,
                    onPressed: () => _launch(context, 'sms'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).hintColor),
          const SizedBox(width: AppSizes.gap),
          Text('$label: ', style: textTheme.bodySmall),
          Expanded(
            child: Text(value,
                style: textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

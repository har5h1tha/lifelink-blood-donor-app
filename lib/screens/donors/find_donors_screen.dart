import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/colors.dart';
import '../../core/constants.dart';
import '../../core/widgets/app_dropdown.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/donor_viewmodel.dart';
import 'donor_card.dart';
import 'donor_details_sheet.dart';

class FindDonorsScreen extends StatelessWidget {
  const FindDonorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DonorViewModel>();
    final currentUser = context.watch<AuthViewModel>().currentUser;

    // Tell the ViewModel who is logged in so they are hidden from the list.
    // (Done after the frame so we don't notify listeners during build.)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.read<DonorViewModel>().setCurrentUserId(currentUser?.uid);
      }
    });

    final donors = vm.donors;

    return Scaffold(
      appBar: AppBar(title: const Text('Find Donors')),
      body: Column(
        children: [
          // ---- Filter section ----
          Padding(
            padding: const EdgeInsets.all(AppSizes.padding),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppDropdown(
                        label: 'Blood group',
                        value: vm.selectedBloodGroup,
                        items: bloodGroups,
                        allowAll: true,
                        onChanged: vm.setBloodGroup,
                      ),
                    ),
                    const SizedBox(width: AppSizes.gap),
                    Expanded(
                      child: AppDropdown(
                        label: 'City',
                        value: vm.selectedCity,
                        items: cities,
                        allowAll: true,
                        onChanged: vm.setCity,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.gap),
                Row(
                  children: [
                    Expanded(
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: const Text('Include compatible groups'),
                        value: vm.includeCompatible,
                        onChanged: vm.setIncludeCompatible,
                      ),
                    ),
                    TextButton(
                      onPressed: vm.clearFilters,
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ---- Count ----
          if (!vm.isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${donors.length} donor${donors.length == 1 ? '' : 's'} found',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),

          // ---- List ----
          Expanded(
            child: vm.isLoading
                ? const LoadingIndicator()
                : donors.isEmpty
                    ? const EmptyState(
                        icon: Icons.search_off,
                        message: 'No donors match your filters',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSizes.padding),
                        itemCount: donors.length,
                        itemBuilder: (context, i) => DonorCard(
                          donor: donors[i],
                          onTap: () => showDonorDetailsSheet(context, donors[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}


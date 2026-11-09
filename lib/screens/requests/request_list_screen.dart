import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
 
import '../../core/colors.dart';
import '../../core/constants.dart';
import '../../core/routes.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../models/request_model.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/request_viewmodel.dart';
import 'request_card.dart';
 
class RequestListScreen extends StatelessWidget {
  const RequestListScreen({super.key});
 
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RequestViewModel>();
    // Tell the ViewModel who is logged in so "My Requests" works
    vm.attachUser(context.watch<AuthViewModel>().currentUser?.uid);
 
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Blood Requests'),
          // The AppBar is red, so the tab text must be white
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'All Requests'),
              Tab(text: 'My Requests'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.postRequest),
          icon: const Icon(Icons.add),
          label: const Text('Post Request'),
        ),
        body: Column(
          children: [
            _FilterChips(
              selected: vm.filterBloodGroup,
              onSelected: vm.setFilter,
            ),
            Expanded(
              child: vm.isLoading
                  ? const LoadingIndicator()
                  : (vm.errorMessage != null && vm.requests.isEmpty)
                      ? EmptyState(
                          icon: Icons.error_outline,
                          message: vm.errorMessage!,
                        )
                      : TabBarView(
                          children: [
                            _RequestList(
                              items: vm.requests,
                              emptyMessage: 'No blood requests found',
                            ),
                            _RequestList(
                              items: vm.myRequests,
                              emptyMessage:
                                  "You haven't posted any requests yet",
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
 
/// Row of blood group chips: All + 8 groups.
class _FilterChips extends StatelessWidget {
  final String? selected; // null means "All"
  final ValueChanged<String?> onSelected;
 
  const _FilterChips({required this.selected, required this.onSelected});
 
  @override
  Widget build(BuildContext context) {
    final options = ['All', ...bloodGroups];
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.padding, vertical: AppSizes.gap),
        children: [
          for (final g in options)
            Padding(
              padding: const EdgeInsets.only(right: AppSizes.gap),
              child: ChoiceChip(
                label: Text(g),
                showCheckmark: false,
                selected: g == 'All' ? selected == null : selected == g,
                selectedColor: AppColors.primaryLight,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: (g == 'All' ? selected == null : selected == g)
                      ? AppColors.primary
                      : null,
                ),
                onSelected: (_) => onSelected(g == 'All' ? null : g),
              ),
            ),
        ],
      ),
    );
  }
}
 
/// Scrollable list of cards, or an EmptyState when there is nothing.
class _RequestList extends StatelessWidget {
  final List<RequestModel> items;
  final String emptyMessage;
 
  const _RequestList({required this.items, required this.emptyMessage});
 
  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return EmptyState(icon: Icons.bloodtype, message: emptyMessage);
    }
    return ListView.builder(
      // Extra space at the bottom so the floating button never hides a card
      padding: EdgeInsets.fromLTRB(
        AppSizes.padding,
        AppSizes.gap,
        AppSizes.padding,
        AppSizes.buttonHeight + AppSizes.padding * 2,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) => RequestCard(request: items[i]),
    );
  }
}
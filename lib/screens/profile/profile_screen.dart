import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../core/routes.dart';
import '../../core/widgets/blood_group_badge.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/user_model.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final theme = context.watch<ThemeViewModel>();
    final user = auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: EmptyState(icon: Icons.person_off_outlined, message: 'You are not logged in'),
      );
    }

    final titleStyle =
        Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.padding),
        children: [
          // ---- Header: avatar, name, blood group, eligibility ----
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.primaryLight,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.padding),
          Text(user.name, textAlign: TextAlign.center, style: titleStyle),
          const SizedBox(height: AppSizes.gap),
          Center(child: BloodGroupBadge(group: user.bloodGroup, size: 52)),
          const SizedBox(height: AppSizes.gap),
          _EligibilityText(user: user),
          const SizedBox(height: 24),

          // ---- Details ----
          Card(
            elevation: AppSizes.cardElevation,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radius),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Email'),
                  subtitle: Text(user.email),
                ),
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: const Text('Phone'),
                  subtitle: Text(user.phone),
                ),
                ListTile(
                  leading: const Icon(Icons.location_city_outlined),
                  title: const Text('City'),
                  subtitle: Text(user.city),
                ),
                ListTile(
                  leading: const Icon(Icons.event_outlined),
                  title: const Text('Last donated'),
                  subtitle: Text(
                    user.lastDonated == null
                        ? 'Not set'
                        : DateFormat('dd MMM yyyy').format(user.lastDonated!),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.padding),

          // ---- Switches ----
          Card(
            elevation: AppSizes.cardElevation,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radius),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.volunteer_activism_outlined),
                  title: const Text('Available to donate'),
                  subtitle: const Text('Show me in the donor search'),
                  value: user.isAvailable,
                  onChanged: (v) => auth.setAvailability(v),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Dark mode'),
                  value: theme.isDarkMode,
                  onChanged: (v) => theme.toggleTheme(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ---- Actions ----
          PrimaryButton(
            label: 'Edit Profile',
            icon: Icons.edit_outlined,
            onPressed: () => Navigator.pushNamed(context, AppRoutes.editProfile),
          ),
          const SizedBox(height: AppSizes.gap),
          SizedBox(
            height: AppSizes.buttonHeight,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.info_outline),
              label: const Text('About LifeLink'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radius),
                ),
              ),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.about),
            ),
          ),
          const SizedBox(height: AppSizes.gap),
          SizedBox(
            height: AppSizes.buttonHeight,
            child: TextButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              onPressed: () async {
                await context.read<AuthViewModel>().logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows 'Eligible to donate' or the date after which the user can donate again.
class _EligibilityText extends StatelessWidget {
  final UserModel user;
  const _EligibilityText({required this.user});

  @override
  Widget build(BuildContext context) {
    final can = user.canDonate;
    final text = can
        ? 'Eligible to donate'
        : 'Can donate again after ${DateFormat('dd MMM yyyy').format(user.lastDonated!.add(const Duration(days: 90)))}';
    final color = can ? AppColors.success : AppColors.urgentHigh;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(can ? Icons.check_circle_outline : Icons.schedule, size: 18, color: color),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

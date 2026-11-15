import 'package:flutter/material.dart';

import '../../core/colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About LifeLink'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.volunteer_activism,
                    size: 65,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'LifeLink',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Every drop counts. Every donor matters.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            _sectionTitle(context, 'Problem Statement'),
            const Text(
              'Finding compatible blood donors during emergencies can be '
              'difficult and time-consuming. Lack of quick communication '
              'between donors and people in need can delay access to '
              'life-saving blood.',
            ),

            const SizedBox(height: 22),

            _sectionTitle(context, 'How LifeLink Helps'),
            const Text(
              'LifeLink is a blood donor application designed to connect '
              'blood donors with people who need blood. It helps users '
              'find available donors, post blood requests, and access '
              'important information through a simple interface.',
            ),

            const SizedBox(height: 22),

            _sectionTitle(context, 'SDG 3 - Good Health and Well-being'),
            const Text(
              'LifeLink supports the United Nations Sustainable Development '
              'Goal 3 by promoting good health and well-being for everyone.',
            ),
            const SizedBox(height: 12),

            _infoCard(
              Icons.favorite_outline,
              'Promotes blood donation',
              'Encourages people to become voluntary blood donors.',
            ),
            _infoCard(
              Icons.people_outline,
              'Connects people',
              'Helps connect donors with people who need blood.',
            ),
            _infoCard(
              Icons.health_and_safety_outlined,
              'Supports healthcare',
              'Contributes to timely access to blood during emergencies.',
            ),

            const SizedBox(height: 22),

            _sectionTitle(context, 'Project Team'),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Member 1: [Member 1 Name]'),
                    SizedBox(height: 8),
                    Text('Member 2: [Member 2 Name]'),
                    SizedBox(height: 8),
                    Text('Member 3: [Member 3 Name]'),
                    SizedBox(height: 8),
                    Text('Member 4: [Member 4 Name]'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            Center(
              child: Text(
                'LifeLink - Every drop counts.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge
            ?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
      ),
    );
  }

  Widget _infoCard(IconData icon, String title, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        subtitle: Text(description),
      ),
    );
  }
}

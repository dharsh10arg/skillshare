import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/session_provider.dart';
import '../widgets/app_scaffold.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<SessionProvider>().user;
    return AppScaffold(
      title: 'Home',
      actions: [
        IconButton(
            onPressed: context.read<SessionProvider>().logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout')
      ],
      children: [
        Text('Welcome, ${user?.name ?? 'member'}',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        Wrap(spacing: 12, runSpacing: 12, children: [
          SizedBox(
              width: 260,
              child: MetricCard(
                  label: 'Reputation',
                  value: '${user?.reputationScore ?? 0}',
                  icon: Icons.trending_up)),
          SizedBox(
              width: 260,
              child: MetricCard(
                  label: 'Reliability',
                  value: '${user?.reliabilityScore ?? 0}',
                  icon: Icons.verified_outlined)),
          SizedBox(
              width: 260,
              child: MetricCard(
                  label: 'Community',
                  value: '${user?.communityScore ?? 0}',
                  icon: Icons.groups_outlined)),
        ]),
        const SizedBox(height: 20),
        _ActionPanel(),
      ],
    );
  }
}

class _ActionPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Today', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            const ListTile(
                leading: Icon(Icons.flash_on_outlined),
                title: Text('Instant help request'),
                subtitle:
                    Text('Fix a bug, review a resume, explain a concept')),
            const ListTile(
                leading: Icon(Icons.event_available_outlined),
                title: Text('Upcoming session'),
                subtitle: Text('Laravel API mentoring, 60 min')),
            const ListTile(
                leading: Icon(Icons.emoji_events_outlined),
                title: Text('Weekly reward'),
                subtitle: Text('Keep your login streak active')),
          ],
        ),
      ),
    );
  }
}

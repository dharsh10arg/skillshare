import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/session_provider.dart';
import '../widgets/app_scaffold.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<SessionProvider>().user;
    return AppScaffold(
      title: 'Portfolio',
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    (user?.name ?? 'S').substring(0, 1).toUpperCase(),
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ),
                const SizedBox(height: 16),
                Text(user?.name ?? 'Member',
                    style: Theme.of(context).textTheme.headlineSmall),
                Text('@${user?.username ?? 'member'}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    )),
                const SizedBox(height: 16),
                Chip(
                  label: Text(user?.role ?? 'member'),
                  avatar: const Icon(Icons.verified, size: 14),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('Statistics', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Sessions taught',
                value: '${user?.completedSessions ?? 0}',
                icon: Icons.school,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Projects completed',
                value: '${user?.completedProjects ?? 0}',
                icon: Icons.workspaces,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text('Achievements', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        const _AchievementItem(
          label: 'First Teacher',
          description: 'Completed your first teaching session',
          icon: Icons.workspace_premium_outlined,
          color: Colors.orange,
        ),
        const SizedBox(height: 8),
        const _AchievementItem(
          label: 'Helpful Mentor',
          description: 'Received 5+ positive reviews',
          icon: Icons.thumb_up_outlined,
          color: Colors.blue,
        ),
        const SizedBox(height: 8),
        const _AchievementItem(
          label: 'Community Contributor',
          description: 'Contributed 10+ answers to community',
          icon: Icons.forum_outlined,
          color: Colors.green,
        ),
        const SizedBox(height: 20),
        Text('Public profile', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.ios_share),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Shareable portfolio link',
                              style: Theme.of(context).textTheme.titleSmall),
                          Text('/portfolio/${user?.username ?? 'member'}',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              )),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      tooltip: 'Copy link',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Link copied to clipboard'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _AchievementItem extends StatelessWidget {
  const _AchievementItem({
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String label;
  final String description;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(label),
        subtitle: Text(description),
        trailing: const Icon(Icons.check_circle, color: Colors.green),
      ),
    );
  }
}

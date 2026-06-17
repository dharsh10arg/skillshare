import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../models/admin_stats.dart';
import '../widgets/app_scaffold.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late Future<AdminStats> _stats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    _stats = _load();
  }

  Future<AdminStats> _load() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final api = context.read<ApiClient>();
      final response = await api.get('/admin/analytics');
      return AdminStats.fromJson(response);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error loading analytics: $e'), backgroundColor: Colors.red),
      );
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Admin',
      children: [
        FutureBuilder<AdminStats>(
          future: _stats,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final stats = snapshot.data!;
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        label: 'Total users',
                        value: '${stats.totalUsers}',
                        icon: Icons.people,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MetricCard(
                        label: 'Active users',
                        value: '${stats.activeUsers}',
                        icon: Icons.person_add,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        label: 'Sessions completed',
                        value: '${stats.sessionsCompleted}',
                        icon: Icons.done_all,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MetricCard(
                        label: 'Credits circulated',
                        value: '${stats.creditsCirculated}',
                        icon: Icons.toll,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (stats.popularSkills.isNotEmpty) ...[
                  Text('Popular skills', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: stats.popularSkills
                            .take(5)
                            .map((skill) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(skill.title, style: Theme.of(context).textTheme.titleSmall),
                                  Chip(
                                    label: Text('${skill.count} times'),
                                    avatar: const Icon(Icons.trending_up, size: 14),
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                            ))
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.shield_outlined),
                    title: const Text('Moderation queue'),
                    subtitle: const Text('Reports, bans, content review'),
                    onTap: () => _showModerationDialog(),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.account_balance_outlined),
                    title: const Text('Treasury'),
                    subtitle: const Text('Mint credits for rewards, events, achievements'),
                    onTap: () => _showTreasuryDialog(),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _showModerationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Moderation Queue'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.warning_outlined, color: Colors.orange),
              title: Text('User report - Inappropriate content'),
              subtitle: Text('Reported 2 hours ago'),
            ),
            SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.block, color: Colors.red),
              title: Text('Ban request - Spam'),
              subtitle: Text('Reported 5 hours ago'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTreasuryDialog() {
    final userIdCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mint credits from treasury'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: userIdCtrl,
              decoration: const InputDecoration(labelText: 'User ID'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              decoration: const InputDecoration(labelText: 'Credits to mint'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(labelText: 'Reason'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (!mounted) return;
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);
              try {
                final api = context.read<ApiClient>();
                await api.post('/admin/mint-treasury', {
                  'user_id': int.parse(userIdCtrl.text),
                  'amount': int.parse(amountCtrl.text),
                  'reason': reasonCtrl.text,
                });
                if (!mounted) return;
                navigator.pop();
                setState(_loadStats);
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Credits minted successfully!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Mint'),
          ),
        ],
      ),
    );
  }
}

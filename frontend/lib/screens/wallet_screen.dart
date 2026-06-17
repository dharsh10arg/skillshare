import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../providers/session_provider.dart';
import '../widgets/app_scaffold.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late Future<List<dynamic>> _transactions;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    _transactions = _load();
  }

  Future<List<dynamic>> _load() async {
    try {
      final api = context.read<ApiClient>();
      final response = await api.get('/wallet/transactions');
      return response['data'] as List<dynamic>? ?? [];
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<SessionProvider>().user;
    return AppScaffold(
      title: 'Wallet',
      children: [
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Available credits',
                    style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 8),
                Text('${user?.walletBalance ?? 0}',
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('Transaction history', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        FutureBuilder<List<dynamic>>(
          future: _transactions,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final transactions = snapshot.data ?? [];
            if (transactions.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      const Icon(Icons.history, size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('No transactions yet', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              );
            }
            return Column(
              children: transactions
                  .map((tx) => _TransactionCard(tx as Map<String, dynamic>))
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 20),
        Text('How to earn credits', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        const _EarningItem(
          label: 'Teaching reward',
          description: '+10 credits for a 60 minute session',
          icon: Icons.school,
          color: Colors.blue,
        ),
        const SizedBox(height: 8),
        const _EarningItem(
          label: 'Community contributions',
          description: '+1-5 credits for helpful answers and tutorials',
          icon: Icons.forum,
          color: Colors.green,
        ),
        const SizedBox(height: 8),
        const _EarningItem(
          label: 'Project completion',
          description: '+5-20 credits for completing projects',
          icon: Icons.workspaces,
          color: Colors.orange,
        ),
      ],
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard(this.transaction);
  final Map<String, dynamic> transaction;

  Color _getTypeColor(String type) {
    switch (type) {
      case 'earned':
      case 'mint':
        return Colors.green;
      case 'spent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'earned':
        return Icons.trending_up;
      case 'mint':
        return Icons.card_giftcard;
      case 'spent':
        return Icons.trending_down;
      default:
        return Icons.history;
    }
  }

  @override
  Widget build(BuildContext context) {
    final amount = transaction['amount'] as int? ?? 0;
    final type = transaction['type'] as String? ?? 'unknown';
    final description = transaction['description'] as String? ?? 'Transaction';
    final color = _getTypeColor(type);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(_getTypeIcon(type), color: color),
        ),
        title: Text(description),
        subtitle: Text(
          DateTime.now().toString().split(' ')[0],
          style: Theme.of(context).textTheme.labelSmall,
        ),
        trailing: Text(
          '${type == 'spent' ? '-' : '+'}$amount',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _EarningItem extends StatelessWidget {
  const _EarningItem({
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
        subtitle: Text(description, maxLines: 2),
      ),
    );
  }
}

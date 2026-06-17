import 'package:flutter/material.dart';

import '../widgets/app_scaffold.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Admin',
      children: const [
        MetricCard(
            label: 'Total users', value: 'API', icon: Icons.people_outline),
        SizedBox(height: 12),
        MetricCard(
            label: 'Sessions completed', value: 'API', icon: Icons.done_all),
        SizedBox(height: 12),
        Card(
            child: ListTile(
                leading: Icon(Icons.shield_outlined),
                title: Text('Moderation queue'),
                subtitle: Text('Reports, bans, content review'))),
        Card(
            child: ListTile(
                leading: Icon(Icons.account_balance_outlined),
                title: Text('Treasury'),
                subtitle:
                    Text('Mint credits for rewards, events, achievements'))),
      ],
    );
  }
}

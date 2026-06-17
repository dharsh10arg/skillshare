import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/session_provider.dart';
import '../widgets/app_scaffold.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<SessionProvider>().user;
    return AppScaffold(
      title: 'Wallet',
      children: [
        MetricCard(
            label: 'Available credits',
            value: '${user?.walletBalance ?? 0}',
            icon: Icons.toll),
        const SizedBox(height: 16),
        const Card(
            child: ListTile(
                leading: Icon(Icons.add_circle_outline),
                title: Text('Starter credits'),
                subtitle: Text('+10 minted from treasury'))),
        const Card(
            child: ListTile(
                leading: Icon(Icons.school_outlined),
                title: Text('Teaching reward'),
                subtitle: Text('+10 for a 60 minute session'))),
        const Card(
            child: ListTile(
                leading: Icon(Icons.local_library_outlined),
                title: Text('Learning cost'),
                subtitle: Text('-8 for a 60 minute session'))),
      ],
    );
  }
}

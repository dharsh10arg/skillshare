import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/session_provider.dart';
import '../widgets/app_scaffold.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<SessionProvider>().user;
    return AppScaffold(
      title: 'Portfolio',
      children: [
        CircleAvatar(
            radius: 40, child: Text((user?.name ?? 'S').substring(0, 1))),
        const SizedBox(height: 12),
        Text('@${user?.username ?? 'member'}',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        const Card(
            child: ListTile(
                leading: Icon(Icons.workspace_premium_outlined),
                title: Text('Achievements'),
                subtitle: Text('First Teacher, Helpful Mentor'))),
        const Card(
            child: ListTile(
                leading: Icon(Icons.history_edu_outlined),
                title: Text('Session history'),
                subtitle: Text('Teaching and learning sessions appear here'))),
        const Card(
            child: ListTile(
                leading: Icon(Icons.ios_share),
                title: Text('Shareable portfolio'),
                subtitle:
                    Text('Public profile endpoint: /portfolio/{username}'))),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../widgets/app_scaffold.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Community',
      children: const [
        Card(
            child: ListTile(
                leading: Icon(Icons.help_outline),
                title: Text('How do I structure a Laravel wallet ledger?'),
                subtitle: Text('Helpful answers earn +1 credit'))),
        SizedBox(height: 12),
        Card(
            child: ListTile(
                leading: Icon(Icons.menu_book_outlined),
                title: Text('Tutorial: Provider session state'),
                subtitle: Text('Tutorial uploads earn +5 credits'))),
        SizedBox(height: 12),
        Card(
            child: ListTile(
                leading: Icon(Icons.bolt_outlined),
                title: Text('Micro Help Hub'),
                subtitle: Text(
                    'Bug fixes, resume reviews, concept explainers, UI feedback'))),
      ],
    );
  }
}

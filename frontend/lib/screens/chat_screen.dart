import 'package:flutter/material.dart';

import '../widgets/app_scaffold.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Chat',
      children: const [
        Card(
            child: ListTile(
                leading: Icon(Icons.circle, size: 12, color: Colors.green),
                title: Text('Project team'),
                subtitle:
                    Text('Typing indicators, read receipts, online status'))),
        SizedBox(height: 12),
        Card(
            child: ListTile(
                leading: Icon(Icons.timer_outlined),
                title: Text('Session chat'),
                subtitle: Text('Messages stay attached to bookings'))),
        SizedBox(height: 12),
        Card(
            child: ListTile(
                leading: Icon(Icons.person_outline),
                title: Text('Direct messages'),
                subtitle: Text('Bearer-authenticated message API'))),
      ],
    );
  }
}

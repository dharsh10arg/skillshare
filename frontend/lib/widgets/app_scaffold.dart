import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/session_provider.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold(
      {super.key,
      required this.title,
      required this.children,
      this.actions,
      this.onRefresh});

  final String title;
  final List<Widget> children;
  final List<Widget>? actions;
  final Future<void> Function()? onRefresh;

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int _notificationCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    // Simulate loading notifications
    // In production, this would call an API endpoint
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() => _notificationCount = 3); // Example: 3 notifications
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<SessionProvider>().user;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 2,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: _showNotifications,
                icon: const Icon(Icons.notifications_outlined),
                tooltip: 'Notifications',
              ),
              if (_notificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$_notificationCount',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ),
                ),
            ],
          ),
          if (widget.actions != null) ...widget.actions!,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: Chip(
                avatar: const Icon(Icons.toll, size: 18),
                label: Text('${user?.walletBalance ?? 0}'),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: widget.onRefresh ?? () async {
          await context.read<SessionProvider>().refreshProfile();
          await _loadNotifications();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: widget.children,
        ),
      ),
    );
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notifications', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            if (_notificationCount == 0)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('No new notifications'),
              )
            else ...[
              const ListTile(
                leading: Icon(Icons.event_available, color: Colors.blue),
                title: Text('Booking accepted'),
                subtitle: Text('Your Laravel session booking was accepted'),
              ),
              const ListTile(
                leading: Icon(Icons.comment, color: Colors.green),
                title: Text('New message'),
                subtitle: Text('You have a new message from a community member'),
              ),
              const ListTile(
                leading: Icon(Icons.card_giftcard, color: Colors.orange),
                title: Text('Credits earned'),
                subtitle: Text('You earned 5 credits for completing a session'),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard(
      {super.key,
      required this.label,
      required this.value,
      required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
              ],
            ),
            const SizedBox(height: 12),
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

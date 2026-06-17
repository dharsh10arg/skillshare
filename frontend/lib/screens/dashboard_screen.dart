import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../models/booking.dart';
import '../providers/session_provider.dart';
import '../screens/bookings_screen.dart';
import '../screens/community_screen.dart';
import '../screens/marketplace_screen.dart';
import '../screens/wallet_screen.dart';
import '../widgets/app_scaffold.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<Booking>> _upcomingBookings;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() {
    _upcomingBookings = _load();
  }

  Future<List<Booking>> _load() async {
    try {
      final api = context.read<ApiClient>();
      final response = await api.get('/bookings');
      final bookingList = response['data'] as List<dynamic>? ?? [];
      return bookingList
          .map((item) => Booking.fromJson(item as Map<String, dynamic>))
          .where((b) => b.status != 'completed' && b.status != 'cancelled')
          .take(3)
          .toList();
    } catch (e) {
      return [];
    }
  }

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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    (user?.name ?? 'S').substring(0, 1).toUpperCase(),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome back, ${user?.name ?? 'member'}!',
                          style: Theme.of(context).textTheme.headlineSmall),
                      Text('@${user?.username ?? 'member'}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          )),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Your scores', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    label: 'Reputation',
                    value: '${user?.reputationScore ?? 0}',
                    icon: Icons.trending_up,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricCard(
                    label: 'Reliability',
                    value: '${user?.reliabilityScore ?? 0}',
                    icon: Icons.verified_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    label: 'Community',
                    value: '${user?.communityScore ?? 0}',
                    icon: Icons.groups_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(Icons.school, 
                                  size: 18,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text('Sessions',
                                    style: Theme.of(context).textTheme.labelSmall),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('${(user?.completedSessions ?? 0) + (user?.completedProjects ?? 0)}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Upcoming bookings', style: Theme.of(context).textTheme.titleLarge),
                        TextButton(
                          onPressed: _navigateToBookings,
                          child: const Text('View all'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<List<Booking>>(
                      future: _upcomingBookings,
                      builder: (context, snapshot) {
                        final bookings = snapshot.data ?? [];
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (bookings.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text('No upcoming bookings',
                                style: Theme.of(context).textTheme.bodySmall),
                          );
                        }
                        return Column(
                          children: bookings
                              .map((booking) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      child: Text((booking.teacherName ?? 'T')
                                          .substring(0, 1)),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(booking.skillTitle ?? 'Skill session',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall),
                                          Text(
                                              'with ${booking.teacherName ?? 'teacher'}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelSmall),
                                        ],
                                      ),
                                    ),
                                    Chip(
                                      label: Text(booking.status),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ],
                                ),
                              ))
                              .toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _ActionPanel(
              onBrowseSkills: _navigateToMarketplace,
              onViewBookings: _navigateToBookings,
              onJoinCommunity: _navigateToCommunity,
              onCheckWallet: _navigateToWallet,
            ),
          ],
        ),
      ],
    );
  }

  void _navigateToBookings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BookingsScreen()),
    ).then((_) {
      if (!mounted) return;
      setState(_loadBookings);
    });
  }

  void _navigateToMarketplace() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MarketplaceScreen()),
    );
  }

  void _navigateToCommunity() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CommunityScreen()),
    );
  }

  void _navigateToWallet() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WalletScreen()),
    );
  }
}

class _ActionPanel extends StatelessWidget {
  const _ActionPanel({
    required this.onBrowseSkills,
    required this.onViewBookings,
    required this.onJoinCommunity,
    required this.onCheckWallet,
  });

  final VoidCallback onBrowseSkills;
  final VoidCallback onViewBookings;
  final VoidCallback onJoinCommunity;
  final VoidCallback onCheckWallet;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick actions', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            GridView(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _ActionButton(
                  label: 'Browse skills',
                  icon: Icons.school,
                  onPressed: onBrowseSkills,
                ),
                _ActionButton(
                  label: 'View bookings',
                  icon: Icons.event_available,
                  onPressed: onViewBookings,
                ),
                _ActionButton(
                  label: 'Join community',
                  icon: Icons.forum,
                  onPressed: onJoinCommunity,
                ),
                _ActionButton(
                  label: 'Check wallet',
                  icon: Icons.wallet_giftcard,
                  onPressed: onCheckWallet,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

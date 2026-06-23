import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/demo_data.dart';
import '../models/booking.dart';
import '../widgets/app_scaffold.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  late Future<List<Booking>> _bookings;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() {
    _bookings = _fetchBookings();
  }

  Future<List<Booking>> _fetchBookings() async {
    try {
      final api = context.read<ApiClient>();
      final response = await api.get('/bookings');
      final bookingList = response['data'] as List<dynamic>? ?? [];
      final bookings = bookingList
          .map((item) => Booking.fromJson(item as Map<String, dynamic>))
          .toList();
      if (bookings.isEmpty) {
        return DemoData.bookings;
      }
      return bookings;
    } catch (e) {
      if (!mounted) return DemoData.bookings;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to load bookings: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return DemoData.bookings;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Bookings',
      onRefresh: () async {
        setState(_loadBookings);
        await _bookings;
      },
      children: [
        FutureBuilder<List<Booking>>(
          future: _bookings,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final bookings = snapshot.data ?? [];
            if (bookings.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Icon(Icons.event_available_outlined,
                          size: 48, color: Colors.grey[500]),
                      const SizedBox(height: 16),
                      const Text('No bookings available', style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 12),
                      Semantics(
                        label: 'bookingsReturnButton',
                        button: true,
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Return to dashboard'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: bookings
                  .map((booking) => _BookingCard(
                        booking: booking,
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final scheduled = booking.scheduledAt;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showBookingDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      (booking.teacherName ?? 'T').substring(0, 1).toUpperCase(),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.skillTitle ?? 'Skill session',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'with ${booking.teacherName ?? 'teacher'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(booking.status),
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (scheduled != null)
                Text(
                  'Scheduled ${_formatDateTime(scheduled)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              const SizedBox(height: 6),
              Text(
                '${booking.durationMinutes} minutes',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showBookingDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(booking.skillTitle ?? 'Booking details',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Teacher: ${booking.teacherName ?? 'Unknown'}'),
            const SizedBox(height: 6),
            Text('Duration: ${booking.durationMinutes} minutes'),
            const SizedBox(height: 6),
            Text('Status: ${booking.status}'),
            if (booking.scheduledAt != null) ...[
              const SizedBox(height: 6),
              Text('Scheduled at: ${_formatDateTime(booking.scheduledAt!)}'),
            ],
            if (booking.notes != null && booking.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Notes:'),
              Text(booking.notes!),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../models/skill_listing.dart';
import '../providers/session_provider.dart';
import '../widgets/app_scaffold.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  late Future<List<SkillListing>> _listings;
  String _searchQuery = '';
  String _selectedDuration = '';
  String _selectedLevel = '';

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  void _loadListings() {
    _listings = _load();
  }

  Future<List<SkillListing>> _load() async {
    try {
      final api = context.read<ApiClient>();
      String path = '/skill-listings';
      if (_searchQuery.isNotEmpty || _selectedDuration.isNotEmpty || _selectedLevel.isNotEmpty) {
        path = '/skill-listings/search?q=$_searchQuery${_selectedDuration.isNotEmpty ? '&duration=$_selectedDuration' : ''}${_selectedLevel.isNotEmpty ? '&level=$_selectedLevel' : ''}';
      }
      final response = await api.get(path);
      final dataList = response['data'] as List<dynamic>? ?? [];
      return dataList.map((item) => SkillListing.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      if (!mounted) return [];
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(content: Text('Error loading skills: $e'), backgroundColor: Colors.red),
      );
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Skill Marketplace',
      children: [
        SearchBar(
            leading: const Icon(Icons.search),
            hintText: 'Search skills, teachers...',
            onChanged: (value) {
              setState(() => _searchQuery = value);
              _loadListings();
            }),
        const SizedBox(height: 12),
        Wrap(spacing: 8, children: [
          FilterChip(
            label: const Text('30 min'),
            selected: _selectedDuration == '30',
            onSelected: (selected) {
              setState(() => _selectedDuration = selected ? '30' : '');
              _loadListings();
            },
          ),
          FilterChip(
            label: const Text('60 min'),
            selected: _selectedDuration == '60',
            onSelected: (selected) {
              setState(() => _selectedDuration = selected ? '60' : '');
              _loadListings();
            },
          ),
          FilterChip(
            label: const Text('Advanced'),
            selected: _selectedLevel == 'advanced',
            onSelected: (selected) {
              setState(() => _selectedLevel = selected ? 'advanced' : '');
              _loadListings();
            },
          )
        ]),
        const SizedBox(height: 16),
        FutureBuilder<List<SkillListing>>(
          future: _listings,
          builder: (context, snapshot) {
            final listings = snapshot.data ?? const [];
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (listings.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Icon(Icons.school_outlined, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No listings found', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              );
            }
            return Column(
              children: listings
                  .map((item) => _ListingCard(item, () {
                        if (mounted) {
                          setState(_loadListings);
                        }
                      }))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _ListingCard extends StatefulWidget {
  const _ListingCard(this.item, this.onRefresh);
  final SkillListing item;
  final VoidCallback onRefresh;

  @override
  State<_ListingCard> createState() => _ListingCardState();
}

class _ListingCardState extends State<_ListingCard> {
  bool _isBooking = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.item.expertiseLevel == 'advanced'
        ? Colors.orange
        : widget.item.expertiseLevel == 'intermediate'
            ? Colors.blue
            : Colors.green;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.2),
                  child: Icon(Icons.school, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.item.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      Text('@${widget.item.userUsername ?? 'Anonymous'}',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                Chip(
                  label: Text('${widget.item.durationMinutes} min'),
                  avatar: const Icon(Icons.timer, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (widget.item.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  widget.item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(widget.item.expertiseLevel),
                  backgroundColor: color.withValues(alpha: 0.2),
                  labelStyle: TextStyle(color: color),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _isBooking ? null : _bookSkill,
                  icon: _isBooking
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.event_available),
                  label: const Text('Book'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _bookSkill() async {
    setState(() => _isBooking = true);
    if (!mounted) return;
    final api = context.read<ApiClient>();
    final session = context.read<SessionProvider>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      await api.post('/bookings', {
        'teacher_id': widget.item.userId,
        'skill_listing_id': widget.item.id,
        'duration_minutes': widget.item.durationMinutes,
      });
      await session.refreshProfile();
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Booking request sent! Check your bookings section.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      widget.onRefresh();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Booking failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isBooking = false);
      }
    }
  }
}

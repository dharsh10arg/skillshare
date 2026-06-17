import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../widgets/app_scaffold.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  late Future<List<dynamic>> _listings;

  @override
  void initState() {
    super.initState();
    _listings = _load();
  }

  Future<List<dynamic>> _load() async {
    final response = await context.read<ApiClient>().get('/skill-listings');
    return response['data'] as List<dynamic>? ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Skill Marketplace',
      children: [
        SearchBar(
            leading: const Icon(Icons.search),
            hintText: 'Search skills, teachers, expertise'),
        const SizedBox(height: 12),
        Wrap(spacing: 8, children: const [
          FilterChip(label: Text('30 min'), onSelected: null),
          FilterChip(label: Text('60 min'), onSelected: null),
          FilterChip(label: Text('Advanced'), onSelected: null)
        ]),
        const SizedBox(height: 16),
        FutureBuilder<List<dynamic>>(
          future: _listings,
          builder: (context, snapshot) {
            final listings = snapshot.data ?? const [];
            if (snapshot.connectionState == ConnectionState.waiting)
              return const Center(child: CircularProgressIndicator());
            if (listings.isEmpty)
              return const Text(
                  'No listings yet. Create the first teaching offer.');
            return Column(
                children: listings
                    .map((item) => _ListingCard(item as Map<String, dynamic>))
                    .toList());
          },
        ),
      ],
    );
  }
}

class _ListingCard extends StatelessWidget {
  const _ListingCard(this.item);
  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.school)),
        title: Text(item['title']?.toString() ?? 'Skill session'),
        subtitle: Text(
            '${item['expertise_level'] ?? 'intermediate'} • ${item['duration_minutes'] ?? 60} min'),
        trailing: FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.event_available),
            label: const Text('Book')),
      ),
    );
  }
}

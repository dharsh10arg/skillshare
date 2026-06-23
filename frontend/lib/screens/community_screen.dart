import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../models/community_post.dart';
import '../widgets/app_scaffold.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  late Future<List<CommunityPost>> _posts;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  void _loadPosts() {
    _posts = _load();
  }

  Future<List<CommunityPost>> _load() async {
    try {
      final api = context.read<ApiClient>();
      final response = await api.get('/community');
      final questionList = response['questions'] as List<dynamic>? ?? [];
      final tutorialList = response['tutorials'] as List<dynamic>? ?? [];
      final fallbackList = response['data'] as List<dynamic>? ??
          response['posts'] as List<dynamic>? ??
          response['community'] as List<dynamic>? ??
          [];
      final posts = <CommunityPost>[];

      posts.addAll(questionList.map((item) => CommunityPost.fromJson(
            item as Map<String, dynamic>,
            defaultPostType: 'question',
          )));
      posts.addAll(tutorialList.map((item) => CommunityPost.fromJson(
            item as Map<String, dynamic>,
            defaultPostType: 'tutorial',
          )));

      if (posts.isEmpty) {
        posts.addAll(fallbackList.map((item) => CommunityPost.fromJson(item as Map<String, dynamic>)));
      }

      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return posts;
    } catch (e) {
      if (!mounted) return [];
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(content: Text('Error loading community: $e'), backgroundColor: Colors.red),
      );
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Community',
      onRefresh: () async {
        setState(_loadPosts);
        await _posts;
      },
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Semantics(
            label: 'communityCreatePostButton',
            button: true,
            child: FilledButton.icon(
              onPressed: () => _showNewPostDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Create post'),
            ),
          ),
        ),
        FutureBuilder<List<CommunityPost>>(
          future: _posts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final posts = snapshot.data ?? [];
            if (posts.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Icon(Icons.forum_outlined, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No posts yet', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              );
            }
            return Column(
              children: posts
                  .map((post) => _PostCard(post))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  void _showNewPostDialog() {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    String postType = 'question';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create post'),
        content: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  value: postType,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'question', child: Text('Question')),
                    DropdownMenuItem(value: 'tutorial', child: Text('Tutorial')),
                    DropdownMenuItem(value: 'help', child: Text('Help')),
                  ],
                  onChanged: (value) => setState(() => postType = value ?? 'question'),
                ),
                const SizedBox(height: 12),
                Semantics(
                  label: 'communityTitleField',
                  textField: true,
                  child: TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                ),
                const SizedBox(height: 12),
                Semantics(
                  label: 'communityDescriptionField',
                  textField: true,
                  child: TextField(
                    controller: contentCtrl,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Semantics(
            label: 'communityPostSubmitButton',
            button: true,
            child: FilledButton(
              onPressed: () async {
                if (!mounted) return;
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);
                
                // Validate inputs
                final title = titleCtrl.text.trim();
                final content = contentCtrl.text.trim();
                
                if (title.isEmpty) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Post title cannot be empty.'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }
                
                if (content.isEmpty) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Post content cannot be empty.'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }
                
                try {
                  final api = context.read<ApiClient>();
                  await api.post('/community', {
                    'title': title,
                    'content': content,
                    'post_type': postType,
                  });
                  if (!mounted) return;
                  navigator.pop();
                  setState(_loadPosts);
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Post created successfully!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('Post'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard(this.post);
  final CommunityPost post;

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'question':
        return Icons.help_outline;
      case 'tutorial':
        return Icons.menu_book_outlined;
      case 'help':
        return Icons.lightbulb_outline;
      default:
        return Icons.forum_outlined;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'question':
        return Colors.blue;
      case 'tutorial':
        return Colors.purple;
      case 'help':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getTypeColor(post.postType);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showPostDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.2),
                    radius: 20,
                    child: Icon(_getTypeIcon(post.postType), color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '@${post.userUsername ?? 'member'} • ${_formatDate(post.createdAt)}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                post.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${post.answerCount} answers', style: Theme.of(context).textTheme.labelSmall),
                    ],
                  ),
                  Chip(
                    label: Text(post.postType),
                    backgroundColor: color.withValues(alpha: 0.2),
                    labelStyle: TextStyle(color: color),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }

  void _showPostDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(post.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text('@${post.userUsername ?? 'member'} • ${_formatDate(post.createdAt)}',
                style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 12),
            Text(post.content),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.reply),
              label: const Text('Reply'),
            ),
          ],
        ),
      ),
    );
  }
}

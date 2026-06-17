import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../models/project.dart';
import '../widgets/app_scaffold.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  late Future<List<Project>> _projects;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  void _loadProjects() {
    _projects = _load();
  }

  Future<List<Project>> _load() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final api = context.read<ApiClient>();
      final response = await api.get('/projects');
      final projectList = response['data'] as List<dynamic>? ?? [];
      return projectList.map((item) => Project.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error loading projects: $e'), backgroundColor: Colors.red),
      );
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Projects',
      children: [
        FutureBuilder<List<Project>>(
          future: _projects,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final projects = snapshot.data ?? [];
            if (projects.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Icon(Icons.workspaces_outline, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No projects available', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              );
            }
            return Column(
              children: projects
                  .map((project) => _ProjectCard(project))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard(this.project);
  final Project project;

  Color _getStatusColor(String status) {
    switch (status) {
      case 'open':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showProjectDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.workspaces, color: _getStatusColor(project.status)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      project.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                      Chip(
                        label: Text(project.status),
                        backgroundColor: _getStatusColor(project.status).withValues(alpha: 0.2),
                        labelStyle: TextStyle(color: _getStatusColor(project.status)),
                        padding: EdgeInsets.zero,
                      ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                project.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: [
                  if (project.skillsNeeded.isNotEmpty)
                    Text('Skills: ${project.skillsNeeded.take(2).join(", ")}',
                        style: Theme.of(context).textTheme.labelSmall),
                  if (project.rewardCredits > 0)
                    Chip(
                      label: Text('${project.rewardCredits} credits'),
                      avatar: const Icon(Icons.toll, size: 14),
                      padding: EdgeInsets.zero,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Created ${_formatDate(project.createdAt)}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey),
                  ),
                  if (project.status == 'open')
                    FilledButton.icon(
                      onPressed: () => _showJoinDialog(context),
                      icon: const Icon(Icons.check),
                      label: const Text('Join'),
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

  void _showProjectDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(project.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(project.description),
            const SizedBox(height: 16),
            if (project.skillsNeeded.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Skills needed', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: project.skillsNeeded
                        .map((skill) => Chip(label: Text(skill)))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            if (project.status == 'open')
              FilledButton.icon(
                onPressed: () => _showJoinDialog(context),
                icon: const Icon(Icons.check),
                label: const Text('Join this project'),
              ),
          ],
        ),
      ),
    );
  }

  void _showJoinDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join Project'),
        content: const Text('Add a brief message about why you want to join this project.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Join request sent!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }
}

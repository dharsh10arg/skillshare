import 'package:flutter/material.dart';

import '../widgets/app_scaffold.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Projects',
      children: const [
        Card(
            child: ListTile(
                leading: Icon(Icons.web),
                title: Text('Skill portfolio builder'),
                subtitle: Text('Needs frontend, backend, testing'),
                trailing: Icon(Icons.chevron_right))),
        SizedBox(height: 12),
        Card(
            child: ListTile(
                leading: Icon(Icons.design_services),
                title: Text('Open source design kit'),
                subtitle: Text('Design and documentation rewards'),
                trailing: Icon(Icons.chevron_right))),
      ],
    );
  }
}

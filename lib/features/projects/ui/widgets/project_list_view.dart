import 'package:flutter/material.dart';
import 'package:pulsehub/features/projects/data/models/get_projects_response.dart';

import 'project_card.dart';

class ProjectsList extends StatelessWidget {
  final List<Project> projects;

  const ProjectsList({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ProjectCard(project: projects[index]),
        );
      },
    );
  }
}

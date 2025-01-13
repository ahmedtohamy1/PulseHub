import 'package:flutter/material.dart';
import 'package:pulsehub/features/projects/data/models/project_response.dart';

import 'info_row.dart';

class ProjectSettings extends StatelessWidget {
  final Project project;

  const ProjectSettings({required this.project, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InfoRow(label: 'Timezone:', value: project.timeZone ?? 'N/A'),
        InfoRow(
            label: 'Coordinate System:',
            value: project.coordinateSystem ?? 'N/A'),
        InfoRow(label: 'Date Format:', value: project.dateFormat ?? 'N/A'),
      ],
    );
  }
}

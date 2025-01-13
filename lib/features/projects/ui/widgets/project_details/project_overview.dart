import 'package:flutter/material.dart';
import 'package:pulsehub/features/projects/data/models/project_response.dart';

import 'info_row.dart';

class ProjectOverview extends StatelessWidget {
  final Project project;

  const ProjectOverview({required this.project, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InfoRow(label: 'Project Title:', value: project.title ?? 'N/A'),
        InfoRow(label: 'Project Acronym:', value: project.acronym ?? 'N/A'),
        InfoRow(label: 'Start Date:', value: project.startDate ?? 'N/A'),
        InfoRow(label: 'Duration:', value: project.duration ?? 'N/A'),
        InfoRow(label: 'Time Zone:', value: project.timeZone ?? 'N/A'),
        InfoRow(label: 'Budget:', value: project.budget ?? 'N/A'),
        InfoRow(label: 'Consultant:', value: project.consultant ?? 'N/A'),
        InfoRow(label: 'Contractor:', value: project.contractor ?? 'N/A'),
        InfoRow(
            label: 'Contraction Date:',
            value: project.constructionDate ?? 'N/A'),
        InfoRow(
            label: 'Age of building:', value: project.ageOfBuilding ?? 'N/A'),
        InfoRow(
            label: 'Type of building:', value: project.typeOfBuilding ?? 'N/A'),
        InfoRow(label: 'Size of building:', value: project.size ?? 'N/A'),
        InfoRow(label: 'Structure:', value: project.structure ?? 'N/A'),
        InfoRow(
            label: 'Building History:',
            value: project.buildingHistory ?? 'N/A'),
        InfoRow(
            label: 'Consturtion Characteristics:',
            value: project.constructionCharacteristics ?? 'N/A'),
        InfoRow(
            label: 'Plans and files:', value: project.plansAndFiles ?? 'N/A'),
        InfoRow(label: 'Description:', value: project.description ?? 'N/A'),
      ],
    );
  }
}

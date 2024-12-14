import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pulsehub/features/projects/data/models/get_projects_response.dart';

class ProjectCard extends StatelessWidget {
  final Project project;

  const ProjectCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final formattedDate = project.startDate != null
        ? DateFormat('MMMM dd, yyyy').format(DateTime.parse(project.startDate!))
        : 'N/A';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: Image.network(
              project.pictureUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 50),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project Title
                Text(
                  project.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),

                // Start Date
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                    const SizedBox(width: 5),
                    Text(
                      formattedDate,
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),

                // Warning Count
                if (project.warnings > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, size: 12, color: Colors.red),
                        const SizedBox(width: 5),
                        Text(
                          '${project.warnings} Warnings',
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),

                // Pin Flag
                if (project.isFlag)
                  const Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Icon(Icons.push_pin, color: Colors.blue, size: 16),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

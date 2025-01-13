import 'package:flutter/material.dart';
import 'package:pulsehub/features/projects/data/models/project_response.dart';

import 'project_overview.dart';
import 'project_settings.dart';
import 'section_title.dart';

class ProjectDetailsContent extends StatelessWidget {
  final Project project;

  const ProjectDetailsContent({required this.project, super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SectionTitle(title: 'Project Details'),
          const SizedBox(height: 8),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 300,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      project.pictureUrl ?? '',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.white.withOpacity(0.99),
                        ),
                        child: project.owner?.logoUrl != null
                            ? Image.network(
                                project.owner!.logoUrl!,
                                fit: BoxFit.contain,
                              )
                            : const Icon(Icons.broken_image,
                                color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              project.title ?? 'Untitled Project',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              project.owner?.name ?? 'Unknown',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SectionTitle(title: 'Overview'),
          const SizedBox(height: 8),
          ProjectOverview(project: project),
          const SizedBox(height: 24),
          const SectionTitle(title: 'Project Settings'),
          const SizedBox(height: 8),
          ProjectSettings(project: project),
        ],
      ),
    );
  }
}

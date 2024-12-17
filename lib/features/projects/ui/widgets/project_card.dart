import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pulsehub/core/di/service_locator.dart';

import 'package:pulsehub/core/routing/routes.dart';
import 'package:pulsehub/core/utils/user_manager.dart';
import 'package:pulsehub/features/projects/cubit/cubit/projects_cubit.dart';
import 'package:pulsehub/features/projects/data/models/get_projects_response.dart';

class ProjectCard extends StatefulWidget {
  final Project project;

  const ProjectCard({super.key, required this.project});

  @override
  ProjectCardState createState() => ProjectCardState();
}

class ProjectCardState extends State<ProjectCard> {
  late bool isPinned;

  @override
  void initState() {
    super.initState();
    isPinned = widget
        .project.isFlag; // Initialize with the project's current pinned state
  }

  void togglePin(BuildContext context) async {
    final userId = UserManager().user!.userId; // Get the user ID
    final cubit = sl<ProjectsCubit>();

    // Optimistic UI update
    setState(() {
      isPinned = !isPinned;
    });

    try {
      cubit.flagOrUnflagProject(
        userId: userId,
        projectId: widget.project.projectId,
        isFlag: isPinned,
      );
    } catch (error) {
      // Revert the UI state in case of an error
      setState(() {
        isPinned = !isPinned;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to ${isPinned ? 'pin' : 'unpin'} the project.'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
    context.read<ProjectsCubit>().getProjects();
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = widget.project.startDate != null
        ? DateFormat('MMMM dd, yyyy')
            .format(DateTime.parse(widget.project.startDate!))
        : 'N/A';

    return GestureDetector(
      onTap: () {
        sl<ProjectsCubit>().getProject(widget.project.projectId);
        context.push(
          Routes.projectDetailsPage,
          extra: widget.project.projectId.toString(),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            // Card Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project Image
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(8)),
                  child: Image.network(
                    widget.project.pictureUrl,
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
                        widget.project.title,
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
                          const Icon(Icons.calendar_today,
                              size: 12, color: Colors.grey),
                          const SizedBox(width: 5),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),

                      // Warning Count
                      if (widget.project.warnings > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Row(
                            children: [
                              const Icon(Icons.warning,
                                  size: 12, color: Colors.red),
                              const SizedBox(width: 5),
                              Text(
                                '${widget.project.warnings} Warnings',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            // Floating Pin/Unpin Button
            Positioned(
              top: 8,
              left: 8,
              child: GestureDetector(
                onTap: () => togglePin(context),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isPinned ? Colors.blue : Colors.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isPinned ? 'Unpin' : 'Pin',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

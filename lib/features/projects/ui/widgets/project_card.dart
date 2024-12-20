import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
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
    isPinned = widget.project.isFlag; // Initialize pinned state
  }

  void togglePin(BuildContext context) async {
    final userId = UserManager().user!.userId;
    final cubit = sl<ProjectsCubit>();

    setState(() {
      isPinned = !isPinned; // Optimistic update
    });

    try {
      cubit.flagOrUnflagProject(
        userId: userId,
        projectId: widget.project.projectId,
        isFlag: isPinned,
      );
    } catch (error) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
              child: Image.network(
                widget.project.pictureUrl,
                height: 200, // Increased image height
                width: double.infinity,
                fit: BoxFit.cover, // Properly fills the area
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 50),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with Pin Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.project.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => togglePin(context),
                        child: Icon(
                          isPinned ? MdiIcons.pin : MdiIcons.pinOff,
                          color: isPinned ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Start Date
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 14, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'Start Date: $formattedDate',
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      if (widget.project.warnings > 0) const Spacer(),
                      if (widget.project.warnings > 0)
                        Row(
                          children: [
                            const Icon(Icons.warning,
                                color: Colors.red, size: 14),
                            const SizedBox(width: 8),
                            Text(
                              '${widget.project.warnings}',
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),

                  // Warning Badge
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

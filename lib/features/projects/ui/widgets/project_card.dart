import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pulsehub/core/di/service_locator.dart';
import 'package:pulsehub/core/routing/routes.dart';
import 'package:pulsehub/core/utils/user_manager.dart';
import 'package:pulsehub/features/projects/cubit/projects_cubit.dart';
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
    isPinned = widget.project.isFlag;
  }

  void togglePin(BuildContext context) async {
    final userId = UserManager().user!.userId;
    final cubit = sl<ProjectsCubit>();

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
    setState(() {});
    context.read<ProjectsCubit>().getProjects();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project Image Section
              AspectRatio(
                aspectRatio: 4 / 3, // Bigger banner
                child: Stack(
                  children: [
                    // Project Image
                    Hero(
                      tag: 'project_image_${widget.project.projectId}',
                      child: SizedBox.expand(
                        child: widget.project.pictureUrl.isNotEmpty
                            ? Image.network(
                                widget.project.pictureUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: colorScheme.primary
                                      .withValues(alpha: 0.1),
                                  child: Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 64,
                                      color: colorScheme.primary
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                color:
                                    colorScheme.primary.withValues(alpha: 0.1),
                                child: Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 64,
                                    color: colorScheme.primary
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    // Gradient Overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.9),
                              Colors.black.withValues(alpha: 0.5),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Pin Button
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () => togglePin(context),
                          icon: Icon(
                            isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                            color: isPinned
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    // Warning Badge
                    if (widget.project.warnings > 0)
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.error.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: colorScheme.onError,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.project.warnings}',
                                style: TextStyle(
                                  color: colorScheme.onError,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Project Info
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.project.title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Project Details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: widget.project.warnings > 0
                          ? colorScheme.error
                          : colorScheme.primary,
                      width: 4,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoRow(
                            'Project ID',
                            '#${widget.project.projectId}',
                            Icons.tag,
                            context: context,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInfoRow(
                            'Start Date',
                            formattedDate,
                            Icons.calendar_today,
                            context: context,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoRow(
                            'Warnings',
                            '${widget.project.warnings}',
                            Icons.warning_amber_rounded,
                            context: context,
                            iconColor: widget.project.warnings > 0
                                ? colorScheme.error
                                : colorScheme.outline,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInfoRow(
                            'Owner',
                            widget.project.owner.name,
                            Icons.business,
                            context: context,
                            iconColor: colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    required BuildContext context,
    String? imageUrl,
    int? maxLines,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (imageUrl != null && imageUrl.isNotEmpty)
          Container(
            width: 32,
            height: 32,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  icon,
                  size: 16,
                  color: iconColor ?? colorScheme.primary,
                ),
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (iconColor ?? colorScheme.primary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: iconColor ?? colorScheme.primary,
            ),
          ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
                maxLines: maxLines,
                overflow: maxLines != null ? TextOverflow.ellipsis : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

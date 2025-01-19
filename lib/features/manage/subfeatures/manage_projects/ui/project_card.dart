import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pulsehub/core/di/service_locator.dart';
import 'package:pulsehub/core/routing/routes.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_projects/cubit/manage_projects_cubit.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_projects/data/models/get_all_projects_response_model.dart';
import 'package:pulsehub/features/projects/cubit/projects_cubit.dart';

class ProjectCard extends StatelessWidget {
  final Project project;

  const ProjectCard({
    super.key,
    required this.project,
  });

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    final TextEditingController controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final cubit = context.read<ManageProjectsCubit>();

    return showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: BlocConsumer<ManageProjectsCubit, ManageProjectsState>(
          listenWhen: (previous, current) =>
              current is DeleteProjectSuccess ||
              (current is DeleteProjectFailure &&
                  previous is DeleteProjectLoading &&
                  (previous).projectId == project.projectId),
          listener: (context, state) {
            if (state is DeleteProjectSuccess) {
              Navigator.of(context).pop();
            }
          },
          buildWhen: (previous, current) =>
              current is DeleteProjectLoading &&
                  current.projectId == project.projectId ||
              current is DeleteProjectSuccess ||
              current is DeleteProjectFailure,
          builder: (context, state) {
            return AlertDialog(
              title: const Text('Delete Project'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state is DeleteProjectFailure)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          state.error,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    const Text(
                      'This action cannot be undone. Please type the project name to confirm deletion:',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      project.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'Type project name here',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value != project.title) {
                          return 'Project name does not match';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: state is DeleteProjectLoading
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: state is DeleteProjectLoading
                      ? null
                      : () {
                          if (formKey.currentState?.validate() ?? false) {
                            context
                                .read<ManageProjectsCubit>()
                                .deleteProject(project.projectId);
                          }
                        },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: state is DeleteProjectLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Delete'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocConsumer<ManageProjectsCubit, ManageProjectsState>(
      listenWhen: (previous, current) =>
          current is DeleteProjectSuccess &&
          previous is DeleteProjectLoading &&
          (previous).projectId == project.projectId,
      listener: (context, state) {
        if (state is DeleteProjectSuccess) {
          // The card will be removed by the parent widget when the projects list is refreshed
        }
      },
      buildWhen: (previous, current) =>
          (current is DeleteProjectLoading &&
              current.projectId == project.projectId) ||
          (current is DeleteProjectSuccess &&
              previous is DeleteProjectLoading &&
              (previous).projectId == project.projectId),
      builder: (context, state) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              sl<ProjectsCubit>().getProject(project.projectId);
              context.push(
                Routes.projectDetailsPage,
                extra: project.projectId.toString(),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    // Project Image
                    SizedBox(
                      width: double.infinity,
                      height: 300,
                      child: project.pictureUrl.isNotEmpty
                          ? Image.network(
                              project.pictureUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: colorScheme.primary.withOpacity(0.1),
                                child: Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 64,
                                    color: colorScheme.primary.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              color: colorScheme.primary.withOpacity(0.1),
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 64,
                                  color: colorScheme.primary.withOpacity(0.5),
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
                              Colors.black.withOpacity(0.8),
                              Colors.black.withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Delete Icon Button
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: state is DeleteProjectLoading
                                ? null
                                : () => _showDeleteConfirmationDialog(context),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: state is DeleteProjectLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.delete_outline,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Project Title and Warning
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      project.title,
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      project.acronym ?? '',
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        color: Colors.white.withOpacity(0.9),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (project.warnings > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.error,
                                    borderRadius: BorderRadius.circular(12),
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
                                        '${project.warnings}',
                                        style: TextStyle(
                                          color: colorScheme.onError,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Owner Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: project.warnings > 0
                            ? colorScheme.error
                            : colorScheme.primary,
                        width: 4,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (project.owner.logoUrl.isNotEmpty)
                        Container(
                          width: 80,
                          height: 80,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              project.owner.logoUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                Icons.business,
                                size: 40,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.business,
                            size: 40,
                            color: colorScheme.primary,
                          ),
                        ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Project Owner',
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              project.owner.name,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Project Details
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 600;
                          final itemWidth = isWide
                              ? constraints.maxWidth / 2 - 12
                              : constraints.maxWidth;

                          return Wrap(
                            spacing: 24,
                            runSpacing: 16,
                            children: [
                              // Start Date - Always half width
                              SizedBox(
                                width: itemWidth,
                                child: _buildInfoRow(
                                  'Start Date',
                                  project.startDate != null
                                      ? DateFormat('MMM dd, yyyy')
                                          .format(project.startDate!)
                                      : 'N/A',
                                  Icons.calendar_today,
                                  context: context,
                                ),
                              ),
                              // Duration - Half width
                              SizedBox(
                                width: itemWidth,
                                child: _buildInfoRow(
                                  'Duration',
                                  project.duration?.isNotEmpty == true
                                      ? project.duration!
                                      : 'N/A',
                                  Icons.timer,
                                  context: context,
                                ),
                              ),
                              // Budget - Full width if long, else half
                              SizedBox(
                                width: _shouldBeFullWidth(project.budget)
                                    ? constraints.maxWidth
                                    : itemWidth,
                                child: _buildInfoRow(
                                  'Budget',
                                  project.budget?.isNotEmpty == true
                                      ? project.budget!
                                      : 'N/A',
                                  Icons.attach_money,
                                  context: context,
                                ),
                              ),
                              // Consultant - Full width if long, else half
                              SizedBox(
                                width: _shouldBeFullWidth(project.consultant)
                                    ? constraints.maxWidth
                                    : itemWidth,
                                child: _buildInfoRow(
                                  'Consultant',
                                  project.consultant?.isNotEmpty == true
                                      ? project.consultant!
                                      : 'N/A',
                                  Icons.person,
                                  context: context,
                                ),
                              ),
                              // Contractor - Full width if long, else half
                              SizedBox(
                                width: _shouldBeFullWidth(project.contractor)
                                    ? constraints.maxWidth
                                    : itemWidth,
                                child: _buildInfoRow(
                                  'Contractor',
                                  project.contractor?.isNotEmpty == true
                                      ? project.contractor!
                                      : 'N/A',
                                  Icons.business_center,
                                  context: context,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      if (project.description?.isNotEmpty == true ||
                          project.description == null) ...[
                        const Divider(height: 32),
                        _buildInfoRow(
                          'Description',
                          project.description?.isNotEmpty == true
                              ? project.description!
                              : 'N/A',
                          Icons.description_outlined,
                          context: context,
                          isDescription: true,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _shouldBeFullWidth(String? value) {
    if (value == null || value.isEmpty) return false;
    return value.length > 30; // Adjust this threshold as needed
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    required BuildContext context,
    String? imageUrl,
    bool isDescription = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment:
          isDescription ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        if (imageUrl != null && imageUrl.isNotEmpty)
          Container(
            width: 32,
            height: 32,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  icon,
                  size: 16,
                  color: colorScheme.primary,
                ),
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: colorScheme.primary,
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
                  height: isDescription ? 1.5 : null,
                ),
                overflow: isDescription
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

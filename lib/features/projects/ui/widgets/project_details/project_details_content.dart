import 'package:flutter/material.dart';
import 'package:pulsehub/features/projects/data/models/project_response.dart';

class ProjectDetailsContent extends StatelessWidget {
  final Project project;

  const ProjectDetailsContent({required this.project, super.key});

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
    Color? accentColor,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cardColor = accentColor ?? colorScheme.primary;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor.withValues(alpha: 0.1),
              border: Border(
                left: BorderSide(
                  color: cardColor,
                  width: 4,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cardColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: cardColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    BuildContext context, {
    bool isHighlighted = false,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isHighlighted
                    ? colorScheme.primary.withValues(alpha: 0.1)
                    : colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isHighlighted
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
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
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      color: isHighlighted
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                      fontWeight: isHighlighted ? FontWeight.w500 : null,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Banner Card
          _buildInfoCard(
            context,
            title: 'Project Overview',
            icon: Icons.apartment_rounded,
            accentColor: colorScheme.primary,
            trailing: _buildStatusBadge('Active', colorScheme.primary, context),
            children: [
              if (project.pictureUrl != null && project.pictureUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      project.pictureUrl!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              if (project.pictureUrl != null && project.pictureUrl!.isNotEmpty)
                const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    if (project.owner?.logoUrl != null) ...[
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            project.owner!.logoUrl!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.title ?? 'Untitled Project',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          if (project.owner?.name != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              project.owner!.name!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Basic Information Card
          _buildInfoCard(
            context,
            title: 'Basic Information',
            icon: Icons.info_outline_rounded,
            accentColor: colorScheme.secondary,
            children: [
              _buildInfoRow(
                'Project Title',
                project.title ?? 'N/A',
                Icons.title_rounded,
                context,
                isHighlighted: true,
              ),
              _buildInfoRow(
                'Project Acronym',
                project.acronym ?? 'N/A',
                Icons.short_text_rounded,
                context,
              ),
              _buildInfoRow(
                'Description',
                project.description ?? 'N/A',
                Icons.description_rounded,
                context,
              ),
            ],
          ),

          // Timeline Card
          _buildInfoCard(
            context,
            title: 'Timeline',
            icon: Icons.event_note_rounded,
            accentColor: colorScheme.tertiary,
            children: [
              _buildInfoRow(
                'Start Date',
                project.startDate ?? 'N/A',
                Icons.calendar_today_rounded,
                context,
                isHighlighted: true,
              ),
              _buildInfoRow(
                'Duration',
                project.duration ?? 'N/A',
                Icons.timer_rounded,
                context,
              ),
              _buildInfoRow(
                'Construction Date',
                project.constructionDate ?? 'N/A',
                Icons.construction_rounded,
                context,
              ),
            ],
          ),

          // Financial Information Card
          _buildInfoCard(
            context,
            title: 'Financial Information',
            icon: Icons.attach_money_rounded,
            accentColor: Colors.green,
            children: [
              _buildInfoRow(
                'Budget',
                project.budget ?? 'N/A',
                Icons.account_balance_rounded,
                context,
                isHighlighted: true,
              ),
            ],
          ),

          // Building Details Card
          _buildInfoCard(
            context,
            title: 'Building Details',
            icon: Icons.domain_rounded,
            accentColor: colorScheme.secondary,
            children: [
              _buildInfoRow(
                'Type of Building',
                project.typeOfBuilding ?? 'N/A',
                Icons.category_rounded,
                context,
                isHighlighted: true,
              ),
              _buildInfoRow(
                'Size',
                project.size ?? 'N/A',
                Icons.square_foot_rounded,
                context,
              ),
              _buildInfoRow(
                'Age of Building',
                project.ageOfBuilding ?? 'N/A',
                Icons.update_rounded,
                context,
              ),
              _buildInfoRow(
                'Structure',
                project.structure ?? 'N/A',
                Icons.architecture_rounded,
                context,
              ),
              _buildInfoRow(
                'Building History',
                project.buildingHistory ?? 'N/A',
                Icons.history_rounded,
                context,
              ),
            ],
          ),

          // Environment & Risk Card
          _buildInfoCard(
            context,
            title: 'Environment & Risk',
            icon: Icons.eco_rounded,
            accentColor: Colors.teal,
            children: [
              _buildInfoRow(
                'Construction Characteristics',
                project.constructionCharacteristics ?? 'N/A',
                Icons.engineering_rounded,
                context,
                isHighlighted: true,
              ),
            ],
          ),

          // Project Settings Card
          _buildInfoCard(
            context,
            title: 'Project Settings',
            icon: Icons.settings_rounded,
            accentColor: colorScheme.tertiary,
            children: [
              _buildInfoRow(
                'Time Zone',
                project.timeZone ?? 'N/A',
                Icons.schedule_rounded,
                context,
                isHighlighted: true,
              ),
              _buildInfoRow(
                'Coordinate System',
                project.coordinateSystem ?? 'N/A',
                Icons.gps_fixed_rounded,
                context,
              ),
              _buildInfoRow(
                'Date Format',
                project.dateFormat ?? 'N/A',
                Icons.date_range_rounded,
                context,
              ),
            ],
          ),

          // Team Card
          _buildInfoCard(
            context,
            title: 'Team',
            icon: Icons.groups_2_rounded,
            accentColor: Colors.indigo,
            children: [
              _buildInfoRow(
                'Consultant',
                project.consultant ?? 'N/A',
                Icons.person_rounded,
                context,
                isHighlighted: true,
              ),
              _buildInfoRow(
                'Contractor',
                project.contractor ?? 'N/A',
                Icons.engineering_rounded,
                context,
              ),
            ],
          ),

          // Documents Card
          _buildInfoCard(
            context,
            title: 'Documents',
            icon: Icons.description_rounded,
            accentColor: Colors.blue,
            children: [
              _buildInfoRow(
                'Plans and Files',
                project.plansAndFiles ?? 'N/A',
                Icons.folder_rounded,
                context,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

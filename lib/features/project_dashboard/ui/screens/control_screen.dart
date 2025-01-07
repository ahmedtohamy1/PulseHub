import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/collaborators_tab.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/customisation_tab.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/media_library_tab.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/overview_tab.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/projects/data/models/project_response.dart';

class ControlScreen extends StatefulWidget {
  final Project project;
  const ControlScreen({super.key, required this.project});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_tabController.index == 1) {
      // Customisation tab
      context.read<ProjectDashboardCubit>().getUsedSensors();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 8.0),
              width: 5,
              height: 30,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8.0),
                    topLeft: Radius.circular(8.0)),
              ),
            ),
            Text(
              'Project Control Panel',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TabBar(
          labelPadding: const EdgeInsets.symmetric(horizontal: 1),
          padding: const EdgeInsets.symmetric(horizontal: 1),
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Customisation'),
            Tab(text: 'Media Library'),
            Tab(text: 'Collaborators'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              OverviewTab(
                project: widget.project,
                isEditing: _isEditing,
                onEdit: () => setState(() => _isEditing = true),
                onCancel: () => setState(() => _isEditing = false),
                onSave: () {
                  setState(() => _isEditing = false);
                },
              ),
              CustomisationTab(project: widget.project),
              MediaLibraryTab(projectId: widget.project.projectId!),
              CollaboratorsTab(projectId: widget.project.projectId!),
            ],
          ),
        ),
      ],
    );
  }
}

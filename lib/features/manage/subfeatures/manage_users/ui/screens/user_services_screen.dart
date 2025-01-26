import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/core/di/service_locator.dart';
import 'package:pulsehub/features/dics/data/models/dic_services_model.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_users/cubit/manage_users_cubit.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_users/models/update_dic_request_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/get_all_users_response_model.dart';

class UserServicesScreen extends StatefulWidget {
  final User user;

  const UserServicesScreen({
    super.key,
    required this.user,
  });

  @override
  State<UserServicesScreen> createState() => _UserServicesScreenState();
}

class _UserServicesScreenState extends State<UserServicesScreen> {
  // Mutable state to track service changes
  bool cloudmate = false;
  bool collaboration = false;
  bool projectPreparation = false;
  bool activeProjects = false;
  bool financial = false;
  bool administration = false;
  bool duratrans = false;
  bool codeHub = false;
  bool businessHub = false;
  bool businessIntelligence = false;
  bool salesHub = false;

  // Backup values for canceling changes
  bool _cloudmate = false;
  bool _collaboration = false;
  bool _projectPreparation = false;
  bool _activeProjects = false;
  bool _financial = false;
  bool _administration = false;
  bool _duratrans = false;
  bool _codeHub = false;
  bool _businessHub = false;
  bool _businessIntelligence = false;
  bool _salesHub = false;

  bool _initialized = false;
  bool _isEditing = false;

  void _initializeServices(DicService services) {
    setState(() {
      // Initialize current values
      cloudmate = services.cloudmate;
      collaboration = services.collaboration;
      projectPreparation = services.projectPreparation;
      activeProjects = services.activeProjects;
      financial = services.financial;
      administration = services.administration;
      duratrans = services.duratrans;
      codeHub = services.codeHub;
      businessHub = services.businessHub;
      businessIntelligence = services.businessIntelligence;
      salesHub = services.salesHub;

      // Initialize backup values
      _cloudmate = services.cloudmate;
      _collaboration = services.collaboration;
      _projectPreparation = services.projectPreparation;
      _activeProjects = services.activeProjects;
      _financial = services.financial;
      _administration = services.administration;
      _duratrans = services.duratrans;
      _codeHub = services.codeHub;
      _businessHub = services.businessHub;
      _businessIntelligence = services.businessIntelligence;
      _salesHub = services.salesHub;

      _initialized = true;
    });
  }

  void _cancelChanges() {
    setState(() {
      // Restore values from backup
      cloudmate = _cloudmate;
      collaboration = _collaboration;
      projectPreparation = _projectPreparation;
      activeProjects = _activeProjects;
      financial = _financial;
      administration = _administration;
      duratrans = _duratrans;
      codeHub = _codeHub;
      businessHub = _businessHub;
      businessIntelligence = _businessIntelligence;
      salesHub = _salesHub;

      _isEditing = false;
    });
  }

  void _saveCurrentValuesAsBackup() {
    setState(() {
      _cloudmate = cloudmate;
      _collaboration = collaboration;
      _projectPreparation = projectPreparation;
      _activeProjects = activeProjects;
      _financial = financial;
      _administration = administration;
      _duratrans = duratrans;
      _codeHub = codeHub;
      _businessHub = businessHub;
      _businessIntelligence = businessIntelligence;
      _salesHub = salesHub;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.user.firstName}\'s Services'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing) {
                  _cancelChanges();
                }
              });
            },
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
          ),
        ],
      ),
      body: BlocConsumer<ManageUsersCubit, ManageUsersState>(
        listener: (context, state) {
          if (state is ManageUsersGetDicsSuccess && !_initialized) {
            final services = state.response.dicServicesList.isNotEmpty
                ? state.response.dicServicesList.first
                : null;
            if (services != null) {
              _initializeServices(services);
            }
          } else if (state is ManageUsersUpdateDicsSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Services updated successfully')),
            );
            // Save current values as backup before exiting edit mode
            _saveCurrentValuesAsBackup();
            setState(() => _isEditing = false);
          } else if (state is ManageUsersUpdateDicsFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ManageUsersGetDicsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ManageUsersGetDicsFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.error,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      sl<ManageUsersCubit>()
                          .getDics(widget.user.userId.toString());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Show services for all other states once initialized
          if (_initialized) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Manage DIC Services',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          elevation: 0,
                          color: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _buildServiceSwitch(
                                  'Cloudmate',
                                  'Our Innovation for Safer Infrastructure',
                                  cloudmate,
                                  (value) => _isEditing
                                      ? setState(() => cloudmate = value)
                                      : null,
                                  Icons.cloud,
                                ),
                                _buildServiceSwitch(
                                  'BusinessHub',
                                  'Tools for Business Management',
                                  businessHub,
                                  (value) => _isEditing
                                      ? setState(() => businessHub = value)
                                      : null,
                                  Icons.business,
                                ),
                                _buildServiceSwitch(
                                  'DURATRANS',
                                  'Materials Innovations',
                                  duratrans,
                                  (value) => _isEditing
                                      ? setState(() => duratrans = value)
                                      : null,
                                  Icons.local_shipping,
                                ),
                                _buildServiceSwitch(
                                  'PulseFin',
                                  'Track ongoing projects expenses',
                                  financial,
                                  (value) => _isEditing
                                      ? setState(() => financial = value)
                                      : null,
                                  Icons.attach_money,
                                ),
                                _buildServiceSwitch(
                                  'CodeHub',
                                  'Share code and collaborate',
                                  codeHub,
                                  (value) => _isEditing
                                      ? setState(() => codeHub = value)
                                      : null,
                                  Icons.code,
                                ),
                                _buildServiceSwitch(
                                  'SalesHub',
                                  'Customer Relationship Management',
                                  salesHub,
                                  (value) => _isEditing
                                      ? setState(() => salesHub = value)
                                      : null,
                                  Icons.point_of_sale,
                                ),
                                _buildServiceSwitch(
                                  'Business Intelligence',
                                  'Intelligent Business Analytics',
                                  businessIntelligence,
                                  (value) => _isEditing
                                      ? setState(
                                          () => businessIntelligence = value)
                                      : null,
                                  Icons.analytics,
                                ),
                                _buildServiceSwitch(
                                  'Collaboration',
                                  'Work together seamlessly',
                                  collaboration,
                                  (value) => _isEditing
                                      ? setState(() => collaboration = value)
                                      : null,
                                  Icons.group_work,
                                ),
                                _buildServiceSwitch(
                                  'Project Preparation',
                                  'Plan and organize your projects',
                                  projectPreparation,
                                  (value) => _isEditing
                                      ? setState(
                                          () => projectPreparation = value)
                                      : null,
                                  Icons.assignment,
                                ),
                                _buildServiceSwitch(
                                  'Active Projects',
                                  'Track and manage ongoing projects',
                                  activeProjects,
                                  (value) => _isEditing
                                      ? setState(() => activeProjects = value)
                                      : null,
                                  Icons.rocket_launch,
                                ),
                                _buildServiceSwitch(
                                  'Administration',
                                  'Manage team and resources',
                                  administration,
                                  (value) => _isEditing
                                      ? setState(() => administration = value)
                                      : null,
                                  Icons.admin_panel_settings,
                                  isLast: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isEditing)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: state is ManageUsersUpdateDicsLoading
                            ? null
                            : () {
                                final updateDicRequest = UpdateDicRequestModel(
                                  user: widget.user.userId!,
                                  cloudmate: cloudmate,
                                  collaboration: collaboration,
                                  projectPreparation: projectPreparation,
                                  activeProjects: activeProjects,
                                  financial: financial,
                                  administration: administration,
                                  duratrans: duratrans,
                                  codeHub: codeHub,
                                  businessHub: businessHub,
                                  businessIntelligence: businessIntelligence,
                                  salesHub: salesHub,
                                );

                                context
                                    .read<ManageUsersCubit>()
                                    .updateDics(updateDicRequest);
                              },
                        child: state is ManageUsersUpdateDicsLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Save Changes'),
                      ),
                    ),
                  ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildServiceSwitch(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool>? onChanged,
    IconData icon, {
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: colorScheme.primary,
            ),
          ),
          title: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.secondary,
            ),
          ),
          trailing: Switch(
            value: value,
            onChanged: onChanged,
          ),
        ),
        if (!isLast) const Divider(),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsehub/core/di/service_locator.dart';
import 'package:pulsehub/core/routing/routes.dart';
import 'package:pulsehub/core/utils/user_manager.dart';
import 'package:pulsehub/features/dics/cubit/dic_cubit.dart';
import 'package:pulsehub/features/projects/cubit/projects_cubit.dart';
import 'package:pulsehub/features/projects/ui/widgets/projects_view.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showDicServicesSheet(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (context) {
        return [
          WoltModalSheetPage(
            hasSabGradient: false,
            topBarTitle: Text(
              'PulseHub Services',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            isTopBarLayerAlwaysVisible: true,
            child: BlocProvider(
              create: (context) => sl<DicCubit>()..getDic(),
              child: BlocListener<DicCubit, DicState>(
                listener: (context, state) {
                  if (state is DicError) {
                    UserManager().clearUser();
                    context.go(Routes.loginScreen);
                  }
                },
                child: BlocBuilder<DicCubit, DicState>(
                  builder: (context, state) {
                    if (state is DicLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is DicSuccess) {
                      final service = state.dic.dicServicesList.first;
                      final List<Map<String, dynamic>> services = [
                        {
                          'name': 'CloudMATE',
                          'enabled': service.cloudmate,
                          'icon': Icons.cloud,
                          'onTap': () {
                            context.go(Routes.homePage);
                          },
                          'description': 'Manage your projects efficiently.'
                        },
                        {
                          'name': 'Collaboration',
                          'enabled': service.collaboration,
                          'icon': Icons.group,
                          'onTap': () {},
                          'description': 'Work together seamlessly.'
                        },
                        {
                          'name': 'Project Preparation',
                          'enabled': service.projectPreparation,
                          'icon': Icons.task,
                          'onTap': () {},
                          'description': 'Plan and organize your projects.'
                        },
                        {
                          'name': 'Active Projects',
                          'enabled': service.activeProjects,
                          'icon': Icons.list,
                          'onTap': () {},
                          'description': 'Track and manage ongoing projects.'
                        },
                        {
                          'name': 'Financial',
                          'enabled': service.financial,
                          'icon': Icons.attach_money,
                          'onTap': () {},
                          'description': 'Keep track of your finances.'
                        },
                        {
                          'name': 'Administration',
                          'enabled': service.administration,
                          'icon': Icons.admin_panel_settings,
                          'onTap': () {},
                          'description': 'Manage team and resources.'
                        },
                      ];

                      // Filter services that are enabled
                      final filteredServices =
                          services.where((s) => s['enabled'] == true).toList();

                      return Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome to PulseHub - Your Gate to DIC's Innovations",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Select an Option Below to Get Started',
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ...filteredServices.map((service) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: RadioListTile(
                                    value: service['name'],
                                    groupValue: 'CloudMATE',
                                    onChanged: (value) {
                                      service['onTap']();
                                      Navigator.pop(context);
                                    },
                                    title: Text(
                                      service['name'],
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      service['description'],
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    secondary: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        service['icon'],
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      );
                    }
                    return const Center(child: Text('Unexpected state.'));
                  },
                ),
              ),
            ),
          ),
        ];
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Header
        Container(
          height: kToolbarHeight,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Text(
                'All Projects',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton.filled(
                onPressed: () => context.read<ProjectsCubit>().getProjects(),
                icon: const Icon(Icons.refresh),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.primary.withOpacity(0.1),
                  foregroundColor: colorScheme.primary,
                ),
              ),
              IconButton.filled(
                onPressed: () => _showDicServicesSheet(context),
                icon: const Icon(Icons.apps),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.primary.withOpacity(0.1),
                  foregroundColor: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: BlocBuilder<ProjectsCubit, ProjectsState>(
            builder: (context, state) {
              if (state is ProjectsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ProjectsLoaded) {
                return ProjectsView(projects: state.projects.projects);
              } else if (state is ProjectsError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () =>
                            context.read<ProjectsCubit>().getProjects(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                      ),
                    ],
                  ),
                );
              }
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.folder_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Welcome to Projects',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pulsehub/core/di/service_locator.dart';
import 'package:pulsehub/core/theming/app_styles.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/ui/screens/graph_dashboard_sensors.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/dashboard_card.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/section_title.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class AnalyseScreen extends StatelessWidget {
  const AnalyseScreen({super.key});
  _onAdd(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    WoltModalSheet.show(
      modalDecorator: (child) {
        return BlocProvider(
          create: (context) => sl<ProjectDashboardCubit>(),
          child: child,
        );
      },
      context: context,
      pageListBuilder: (modalSheetContext) => [
        WoltModalSheetPage(
          useSafeArea: true,
          pageTitle: const Center(
              child: Text("Create New Analyse Dashboard",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Divider(
                  color: Colors.grey[400],
                  thickness: 1,
                  endIndent: 60,
                  indent: 60,
                ),
                TextField(
                  controller: titleController,
                  decoration: customInputDecoration(
                      "Dashboard Title", LucideIcons.caseSensitive, true),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: customInputDecoration(
                      "Dashboard Description", LucideIcons.text, true),
                ),
                const SizedBox(height: 16),
                BlocConsumer<ProjectDashboardCubit, ProjectDashboardState>(
                  listener: (context, state) {},
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text(
                          "Create",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectDashboardCubit, ProjectDashboardState>(
      builder: (context, state) {
        if (state is ProjectDashboardFetchLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProjectDashboardFetchSuccess) {
          final dashboards = state.projectDashboards.dashboards
              .where((dashboard) =>
                  dashboard.groups.trim().toLowerCase() == 'analyse')
              .toList();

          if (dashboards.isEmpty) {
            return const Center(
              child: Text('No dashboards available for group "analyse".'),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                SectionTitle(
                    onAdd: () {
                      _onAdd(context);
                    },
                    title: 'Analyse Dashboards'),
                const SizedBox(height: 16),
                ...dashboards.map((dashboard) => DashboardCard(
                      dashboard: dashboard,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BlocProvider(
                                      create: (context) =>
                                          sl<ProjectDashboardCubit>(),
                                      child: GraphDashboardSensors(
                                        dashboard: dashboard,
                                      ),
                                    )));
                      },
                    )),
              ],
            ),
          );
        } else if (state is ProjectDashboardFetchFailure) {
          return Center(
            child: Text('Error: ${state.message}'),
          );
        } else {
          return const Center(
            child: Text('No data available.'),
          );
        }
      },
    );
  }
}

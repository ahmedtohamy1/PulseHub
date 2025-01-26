import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pulsehub/core/di/service_locator.dart';
import 'package:pulsehub/core/theming/app_styles.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/subfeatures/analyse/ui/graph_sensors/section_title.dart';
import 'package:pulsehub/features/project_dashboard/subfeatures/visualise/ui/special_widgets_screen.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/dashboard_card.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class VisualiseScreen extends StatefulWidget {
  const VisualiseScreen({super.key, required this.projectId});
  final int projectId;

  @override
  State<VisualiseScreen> createState() => _VisualiseScreenState();
}

class _VisualiseScreenState extends State<VisualiseScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProjectDashboardCubit>().getDashs(widget.projectId);
  }

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
              child: Text("Create New Visualise Dashboard",
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
                  listener: (context, state) {
                    if (state is ProjectDashboardCreateDashSuccess) {
                      Navigator.of(context).pop();

                      Fluttertoast.showToast(
                        msg: "Dashboard created successfully!",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                      );
                    }
                  },
                  builder: (context, state) {
                    return state is ProjectDashboardCreateDashLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                context
                                    .read<ProjectDashboardCubit>()
                                    .createDash(
                                        titleController.text,
                                        descController.text,
                                        'visualise',
                                        widget.projectId);
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Theme.of(context).primaryColor,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
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
    return BlocListener<ProjectDashboardCubit, ProjectDashboardState>(
      listener: (context, state) {
        if (state is ProjectDashboardDeleteDashSuccess ||
            state is ProjectDashboardUpdateDashSuccess) {
          // Refresh the dashboards list after successful deletion or update
          context.read<ProjectDashboardCubit>().getDashs(widget.projectId);
        }
      },
      child: BlocBuilder<ProjectDashboardCubit, ProjectDashboardState>(
        builder: (context, state) {
          if (state is ProjectDashboardFetchLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProjectDashboardFetchSuccess) {
            final dashboards = state.projectDashboards.dashboards
                .where((dashboard) =>
                    dashboard.groups.trim().toLowerCase() == 'visualise')
                .toList();

            return SingleChildScrollView(
              child: Column(
                children: [
                  SectionTitle(
                    title: 'Visualise Dashboards',
                    onAdd: () {
                      _onAdd(context);
                    },
                  ),
                  const SizedBox(height: 16),
                  if (dashboards.isEmpty)
                    const Center(
                      child: Text(
                          'No dashboards available for group "visualise".'),
                    )
                  else
                    ...dashboards.map((dashboard) => DashboardCard(
                          dashboard: dashboard,
                          projectId: widget.projectId,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SpecialWidgetsScreen(
                                  projectId: widget.projectId,
                                ),
                              ),
                            );
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
      ),
    );
  }
}

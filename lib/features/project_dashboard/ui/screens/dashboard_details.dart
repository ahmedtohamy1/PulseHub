import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/data/models/project_dashboards.dart';
import 'package:pulsehub/features/project_dashboard/data/repos/dash_repo_impl.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/dashboard_details_header_icons.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/dropdown_selector.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/field_selector.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/number_input.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/submit_button.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/time_db_response_builder.dart';

class DashboardDetails extends StatefulWidget {
  final Dashboard dashboard;

  const DashboardDetails({super.key, required this.dashboard});

  @override
  State<DashboardDetails> createState() => _DashboardDetailsState();
}

class _DashboardDetailsState extends State<DashboardDetails> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<ProjectDashboardCubit>(context)
        .getDashDetails(widget.dashboard.project);
  }

  final List<String> selectedFields = [];
  int windowSize = 20;
  String windowPeriod = '5m';
  final TextEditingController deviationController =
      TextEditingController(text: '0.05');
  final TextEditingController windowSizeController =
      TextEditingController(text: '20');
  final TextEditingController windowPeriodController =
      TextEditingController(text: '5m');

  String aggregateFunction = 'mean';
  String timeRange = '1h';
  bool isCustomRange = false;
  final TextEditingController customRangeController = TextEditingController();

  String? selectedMeasurement;
  String? selectedTopic;

  void _submitForm() {
    if (selectedMeasurement == null ||
        selectedTopic == null ||
        selectedFields.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please select measurement, topic, and at least one field'),
        ),
      );
      return;
    }

    // Construct query parameters and submit
    final queryParams = QueryParams(
      measurementName: selectedMeasurement,
      topic: selectedTopic,
      fields: selectedFields.join(','),
      sensorsToAnalyze: selectedFields.join(','),
      windowSize:
          List.filled(selectedFields.length, windowSize.toString()).join(','),
      deviationThreshold:
          List.filled(selectedFields.length, deviationController.text)
              .join(','),
      timeRangeStart: isCustomRange ? customRangeController.text : timeRange,
      aggregateFunc: aggregateFunction,
      bucket: 'CloudHub',
      org: 'DIC',
      windowPeriod: windowPeriod,
    );

    context.read<ProjectDashboardCubit>().getTimeDb(queryParams);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardDetailsheaderIcons(widget: widget),
          const SizedBox(height: 16),
          BlocBuilder<ProjectDashboardCubit, ProjectDashboardState>(
            builder: (context, state) {
              if (context.read<ProjectDashboardCubit>().cloudHubResponse !=
                  null) {
                final measurements = context
                    .read<ProjectDashboardCubit>()
                    .cloudHubResponse!
                    .buckets!
                    .first
                    .measurements;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownSelector<String>(
                      label: 'Data Source',
                      value: selectedMeasurement,
                      items: measurements!.map((m) => m.name!).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedMeasurement = value;
                          selectedTopic = null;
                          selectedFields.clear();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    if (selectedMeasurement != null)
                      DropdownSelector<String>(
                        label: 'CloudHub Topics',
                        value: selectedTopic,
                        items: measurements
                            .firstWhere((m) => m.name == selectedMeasurement)
                            .topics!
                            .map((t) => t.name!)
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedTopic = value;
                            selectedFields.clear();
                          });
                        },
                      ),
                    const SizedBox(height: 16),
                    if (selectedTopic != null)
                      FieldSelector(
                        fields: measurements
                            .firstWhere((m) => m.name == selectedMeasurement)
                            .topics!
                            .firstWhere((t) => t.name == selectedTopic)
                            .fields!
                            .map((f) => f.name!)
                            .toList(),
                        selectedFields: selectedFields,
                        onFieldSelected: (field, selected) {
                          setState(() {
                            if (selected) {
                              selectedFields.add(field);
                            } else {
                              selectedFields.remove(field);
                            }
                          });
                        },
                      ),
                  ],
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
          const SizedBox(height: 16),
          NumberInput(
            label: 'Window Size',
            controller: windowSizeController,
            onChanged: (value) {
              setState(() {
                windowSize = int.tryParse(value) ?? windowSize;
              });
            },
            onIncrement: () {
              setState(() {
                windowSize++;
                windowSizeController.text = windowSize.toString();
              });
            },
            onDecrement: () {
              setState(() {
                if (windowSize > 1) {
                  windowSize--;
                  windowSizeController.text = windowSize.toString();
                }
              });
            },
          ),
          const SizedBox(height: 16),
          DropdownSelector<String>(
            label: 'Window Period',
            value: windowPeriod,
            items: const ['5s', '10s', '1m', '5m', '15m', '30m', '1h'],
            onChanged: (value) {
              setState(() {
                windowPeriod = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          NumberInput(
            label: 'Deviation Threshold',
            controller: deviationController,
            onChanged: (value) {
              setState(() {
                double.tryParse(value) ??
                    double.parse(deviationController.text);
              });
            },
            onIncrement: () {
              setState(() {
                final currentValue =
                    double.tryParse(deviationController.text) ?? 0.0;
                deviationController.text =
                    (currentValue + 0.01).toStringAsFixed(2);
              });
            },
            onDecrement: () {
              setState(() {
                final currentValue =
                    double.tryParse(deviationController.text) ?? 0.0;
                if (currentValue > 0.01) {
                  deviationController.text =
                      (currentValue - 0.01).toStringAsFixed(2);
                }
              });
            },
          ),
          const SizedBox(height: 16),
          DropdownSelector<String>(
            label: 'Aggregate Function',
            value: aggregateFunction,
            items: const ['mean', 'sum', 'max', 'min', 'median'],
            onChanged: (value) {
              setState(() {
                aggregateFunction = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          DropdownSelector<String>(
            label: 'Select Time Range',
            value: timeRange,
            items: const [
              '1m',
              '5m',
              '15m',
              '1h',
              '3h',
              '6h',
              '24h',
              '2d',
              '7d',
              '30d',
              'Custom'
            ],
            onChanged: (value) {
              setState(() {
                if (value == 'Custom') {
                  isCustomRange = true;
                } else {
                  isCustomRange = false;
                  timeRange = value!;
                }
              });
            },
          ),
          if (isCustomRange)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextField(
                controller: customRangeController,
                decoration: const InputDecoration(
                  labelText: 'Enter Custom Range',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          const SizedBox(height: 16),
          SubmitButton(onPressed: _submitForm),
          const SizedBox(height: 16),
          TimeDbResponseBuilder(selectedFields: selectedFields),
        ],
      ),
    );
  }
}

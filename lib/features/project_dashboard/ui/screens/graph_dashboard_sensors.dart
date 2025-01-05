import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/data/models/project_dashboards.dart';
import 'package:pulsehub/features/project_dashboard/data/repos/dash_repo_impl.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/graph_sensors/dashboard_details_header_icons.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/graph_sensors/dropdown_selector.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/graph_sensors/field_selector.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/graph_sensors/number_input.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/graph_sensors/submit_button.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/graph_sensors/time_db_response_builder.dart';

class GraphDashboardSensors extends StatefulWidget {
  final Dashboard dashboard;

  const GraphDashboardSensors({super.key, required this.dashboard});

  @override
  State<GraphDashboardSensors> createState() => _GraphDashboardSensorsState();
}

class _GraphDashboardSensorsState extends State<GraphDashboardSensors> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<ProjectDashboardCubit>(context)
        .getDashDetails(widget.dashboard.project)
        .then((_) {
      // Get the CloudHub response
      final cloudHubResponse =
          context.read<ProjectDashboardCubit>().cloudHubResponse;
      if (cloudHubResponse != null && cloudHubResponse.buckets!.isNotEmpty) {
        final measurements = cloudHubResponse.buckets!.first.measurements;
        if (measurements != null && measurements.isNotEmpty) {
          // Set default measurement (mqtt_consumer)
          final mqttConsumer = measurements.firstWhere(
            (m) => m.name == 'mqtt_consumer',
            orElse: () => measurements.first,
          );

          if (mqttConsumer.topics != null && mqttConsumer.topics!.isNotEmpty) {
            // Set default topic (CloudHub_1001HME)
            final defaultTopic = mqttConsumer.topics!.firstWhere(
              (t) => t.name == 'CloudHub_1001HME',
              orElse: () => mqttConsumer.topics!.first,
            );
            if (defaultTopic.fields != null &&
                defaultTopic.fields!.isNotEmpty) {
              // Select all fields
              final allFields = ['all'];
              setState(() {
                selectedMeasurement = mqttConsumer.name;
                selectedTopic = defaultTopic.name;
                selectedFields.addAll(allFields);
              });
              // Submit form with default values
              _submitFormAll();
            }
          }
        }
      }
    });

    // Fetch CloudHub data
    BlocProvider.of<ProjectDashboardCubit>(context)
        .getCloudhubData(widget.dashboard.project);
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

  void _submitFormAll() {
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
      sensorsToAnalyze: null,
      windowSize: windowSize.toString(),
      deviationThreshold: deviationController.text,
      timeRangeStart: isCustomRange ? customRangeController.text : timeRange,
      aggregateFunc: aggregateFunction,
      bucket: 'CloudHub',
      org: 'DIC',
      windowPeriod: windowPeriod,
    );

    context.read<ProjectDashboardCubit>().getTimeDb(queryParams);
  }

  void _submitAnalyze() {
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

    context
        .read<ProjectDashboardCubit>()
        .analyzeSensorData(queryParams, widget.dashboard.project.toString());
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
                      Column(
                        children: [
                          FieldSelector(
                            fields: measurements
                                .firstWhere(
                                    (m) => m.name == selectedMeasurement)
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
                      ),
                    const SizedBox(height: 16),
                    // Two-column layout for input fields and dropdowns
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // First column
                        Expanded(
                          child: Column(
                            children: [
                              NumberInput(
                                label: 'Window Size',
                                controller: windowSizeController,
                                onChanged: (value) {
                                  setState(() {
                                    windowSize =
                                        int.tryParse(value) ?? windowSize;
                                  });
                                },
                                onIncrement: () {
                                  setState(() {
                                    windowSize++;
                                    windowSizeController.text =
                                        windowSize.toString();
                                  });
                                },
                                onDecrement: () {
                                  setState(() {
                                    if (windowSize > 1) {
                                      windowSize--;
                                      windowSizeController.text =
                                          windowSize.toString();
                                    }
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
                                    final currentValue = double.tryParse(
                                            deviationController.text) ??
                                        0.0;
                                    deviationController.text =
                                        (currentValue + 0.01)
                                            .toStringAsFixed(2);
                                  });
                                },
                                onDecrement: () {
                                  setState(() {
                                    final currentValue = double.tryParse(
                                            deviationController.text) ??
                                        0.0;
                                    if (currentValue > 0.01) {
                                      deviationController.text =
                                          (currentValue - 0.01)
                                              .toStringAsFixed(2);
                                    }
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              DropdownSelector<String>(
                                label: 'Aggregate Function',
                                value: aggregateFunction,
                                items: const [
                                  'mean',
                                  'sum',
                                  'max',
                                  'min',
                                  'median'
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    aggregateFunction = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16), // Spacing between columns
                        // Second column
                        Expanded(
                          child: Column(
                            children: [
                              DropdownSelector<String>(
                                label: 'Window Period',
                                value: windowPeriod,
                                items: const [
                                  '5s',
                                  '10s',
                                  '1m',
                                  '5m',
                                  '15m',
                                  '30m',
                                  '1h'
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    windowPeriod = value!;
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
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        SubmitButton(onPressed: _submitForm),
                        const SizedBox(width: 8),
                        SubmitButton(
                          onPressed: _submitAnalyze,
                          isAnalyze: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<ProjectDashboardCubit, ProjectDashboardState>(
                      builder: (context, state) {
                        if (state is ProjectDashboardAnalyzeSensorDataLoading) {
                          return const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 8),
                                Text('Analyzing sensor data...'),
                              ],
                            ),
                          );
                        }

                        if (state is ProjectDashboardAnalyzeSensorDataSuccess) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Analysis Results',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                MarkdownBody(
                                    data: state.aiAnalyzeDataModel.message),
                              ],
                            ),
                          );
                        }

                        if (state is ProjectDashboardAnalyzeSensorDataFailure) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red[300]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Analysis Error',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  state.message,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                    TimeDbResponseBuilder(
                      selectedFields: selectedFields,
                      onAnalyzeSensor: (field) {
                        final queryParams = QueryParams(
                          measurementName: selectedMeasurement!,
                          topic: selectedTopic!,
                          fields: selectedFields.join(','),
                          sensorsToAnalyze: field,
                          windowSize: windowSize.toString(),
                          deviationThreshold: deviationController.text,
                          timeRangeStart: isCustomRange
                              ? customRangeController.text
                              : timeRange,
                          aggregateFunc: aggregateFunction,
                          bucket: 'CloudHub',
                          org: 'DIC',
                          windowPeriod: windowPeriod,
                        );
                        context
                            .read<ProjectDashboardCubit>()
                            .getTimeDb(queryParams);
                      },
                      windowSize: windowSize.toString(),
                      deviationThreshold: deviationController.text,
                      timeRange: timeRange,
                      isCustomRange: isCustomRange,
                      customRangeController: customRangeController,
                      aggregateFunction: aggregateFunction,
                      windowPeriod: windowPeriod,
                      selectedMeasurement: selectedMeasurement,
                      selectedTopic: selectedTopic,
                    ),
                  ],
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ],
      ),
    );
  }
}

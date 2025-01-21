import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/data/models/project_dashboards.dart';
import 'package:pulsehub/features/project_dashboard/data/repos/dash_repo_impl.dart';
import 'package:pulsehub/features/project_dashboard/subfeatures/analyse/ui/graph_sensors/dashboard_details_header_icons.dart';
import 'package:pulsehub/features/project_dashboard/subfeatures/analyse/ui/graph_sensors/dropdown_selector.dart';
import 'package:pulsehub/features/project_dashboard/subfeatures/analyse/ui/graph_sensors/field_selector.dart';
import 'package:pulsehub/features/project_dashboard/subfeatures/analyse/ui/graph_sensors/number_input.dart';
import 'package:pulsehub/features/project_dashboard/subfeatures/analyse/ui/graph_sensors/submit_button.dart';
import 'package:pulsehub/features/project_dashboard/subfeatures/analyse/ui/graph_sensors/time_db_response_builder.dart';

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
              final allFields =
                  defaultTopic.fields!.map((f) => f.name!).toList();
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
      sensorsToAnalyze: null,
      windowSize: windowSize.toString(),
      deviationThreshold: deviationController.text,
      timeRangeStart: isCustomRange
          ? customRangeController.text.split('&')[0].split('=')[1]
          : timeRange,
      timeRangeStop: isCustomRange
          ? customRangeController.text.split('&')[1].split('=')[1]
          : 'now',
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
      timeRangeStart: isCustomRange
          ? customRangeController.text.split('&')[0].split('=')[1]
          : timeRange,
      timeRangeStop: isCustomRange
          ? customRangeController.text.split('&')[1].split('=')[1]
          : 'now',
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
      timeRangeStart: isCustomRange
          ? customRangeController.text.split('&')[0].split('=')[1]
          : timeRange,
      timeRangeStop: isCustomRange
          ? customRangeController.text.split('&')[1].split('=')[1]
          : 'now',
      aggregateFunc: aggregateFunction,
      bucket: 'CloudHub',
      org: 'DIC',
      windowPeriod: windowPeriod,
    );

    context
        .read<ProjectDashboardCubit>()
        .analyzeSensorData(queryParams, widget.dashboard.project.toString());
  }

  void _submitExpert() {
    context
        .read<ProjectDashboardCubit>()
        .analyzeSensorDataQ2(widget.dashboard.project.toString());
  }

  String _formatDateTime(DateTime dateTime) {
    final localDateTime = dateTime.toLocal();
    final hour = localDateTime.hour == 0
        ? 12
        : localDateTime.hour > 12
            ? localDateTime.hour - 12
            : localDateTime.hour;
    final minute = localDateTime.minute.toString().padLeft(2, '0');
    final period = localDateTime.hour >= 12 ? 'PM' : 'AM';
    final month = localDateTime.month.toString().padLeft(2, '0');
    final day = localDateTime.day.toString().padLeft(2, '0');

    return '${localDateTime.year}-$month-$day ${hour.toString().padLeft(2, '0')}:$minute $period';
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
                    // Two-column layout for input fields and dropdowns
                    Column(
                      children: [
                        // First Row: Window Period and Select Time Range
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: DropdownSelector<String>(
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
                            ),
                            const SizedBox(
                                width: 16), // Spacing between columns
                            Expanded(
                              child: Column(
                                children: [
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
                                    onChanged: (value) async {
                                      if (value == 'Custom') {
                                        final result =
                                            await showBoardDateTimeMultiPicker(
                                          context: context,
                                          pickerType:
                                              DateTimePickerType.datetime,
                                          minimumDate: DateTime(2020),
                                          maximumDate: DateTime.now(),
                                          startDate: DateTime.now().subtract(
                                              const Duration(hours: 1)),
                                          endDate: DateTime.now(),
                                          options: BoardDateTimeOptions(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .surface,
                                            textColor: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                            activeColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            startDayOfWeek: DateTime.monday,
                                            showDateButton: true,
                                            languages:
                                                const BoardPickerLanguages.en(),
                                            boardTitle: 'Select Time Range',
                                            boardTitleTextStyle: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        );

                                        if (result != null && context.mounted) {
                                          setState(() {
                                            isCustomRange = true;
                                            customRangeController.text =
                                                'time_range_start=${result.start.toUtc().toIso8601String()}&time_range_stop=${result.end.toUtc().toIso8601String()}';
                                            timeRange = 'Custom';
                                          });
                                        }
                                      } else {
                                        setState(() {
                                          isCustomRange = false;
                                          timeRange = value!;
                                        });
                                      }
                                    },
                                  ),
                                  if (isCustomRange)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primaryContainer
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primaryContainer
                                                .withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_today,
                                                  size: 14,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Custom Time Range',
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                      .withValues(alpha: 0.3),
                                                ),
                                              ),
                                              child: Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: 'From: ',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: _formatDateTime(
                                                          DateTime.parse(
                                                              customRangeController
                                                                  .text
                                                                  .split('&')[0]
                                                                  .split(
                                                                      '=')[1])),
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary
                                                            .withValues(
                                                                alpha: 0.8),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .tertiary
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .tertiary
                                                      .withValues(alpha: 0.3),
                                                ),
                                              ),
                                              child: Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: 'To: ',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .tertiary,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: _formatDateTime(
                                                          DateTime.parse(
                                                              customRangeController
                                                                  .text
                                                                  .split('&')[1]
                                                                  .split(
                                                                      '=')[1])),
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .tertiary
                                                            .withValues(
                                                                alpha: 0.8),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16), // Spacing between rows

                        // Second Row: Aggregate Function (takes entire row)
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
                        const SizedBox(height: 16), // Spacing between rows

                        // Third Row: Window Size and Deviation Threshold
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: NumberInput(
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
                            ),
                            const SizedBox(
                                width: 16), // Spacing between columns
                            Expanded(
                              child: NumberInput(
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
                            ),
                          ],
                        ),
                      ],
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

                    Row(
                      children: [
                        SubmitButton(onPressed: _submitForm),
                      ],
                    ),
                    const SizedBox(height: 16),

                    TimeDbResponseBuilder(
                      selectedFields: selectedFields,
                      onAnalyzeSensor: (params) {
                        context.read<ProjectDashboardCubit>().getTimeDb(params);
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
                    const SizedBox(height: 24),

                    // Analysis Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SubmitButton(
                          onPressed: _submitAnalyze,
                          isAnalyze: true,
                        ),
                        const SizedBox(width: 16),
                        SubmitButton(
                          onPressed: _submitExpert,
                          isExpert: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Analysis Results
                    BlocBuilder<ProjectDashboardCubit, ProjectDashboardState>(
                      builder: (context, state) {
                        if (state is ProjectDashboardAnalyzeSensorDataLoading ||
                            state
                                is ProjectDashboardAnalyzeSensorDataQ2Loading) {
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

                        return Column(
                          children: [
                            if (state
                                is ProjectDashboardAnalyzeSensorDataSuccess)
                              Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                      .withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                        .withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.analytics_outlined,
                                          size: 20,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Analysis Results',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    MarkdownBody(
                                      data: state.aiAnalyzeDataModel.message,
                                      styleSheet: MarkdownStyleSheet(
                                        p: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontSize: 14,
                                        ),
                                        h1: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontSize: 20,
                                        ),
                                        h2: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontSize: 18,
                                        ),
                                        h3: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontSize: 16,
                                        ),
                                        listBullet: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontSize: 14,
                                        ),
                                        strong: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        em: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (state
                                is ProjectDashboardAnalyzeSensorDataQ2Success)
                              Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer
                                      .withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer
                                        .withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.psychology_outlined,
                                          size: 20,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Expert Analysis Results',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    MarkdownBody(
                                      data: state
                                          .aiQ2ResponseModel.response.message,
                                      styleSheet: MarkdownStyleSheet(
                                        p: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontSize: 14,
                                        ),
                                        h1: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          fontSize: 20,
                                        ),
                                        h2: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          fontSize: 18,
                                        ),
                                        h3: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          fontSize: 16,
                                        ),
                                        listBullet: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontSize: 14,
                                        ),
                                        strong: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        em: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiary,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (state
                                    is ProjectDashboardAnalyzeSensorDataFailure ||
                                state
                                    is ProjectDashboardAnalyzeSensorDataQ2Failure)
                              Container(
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
                                      state is ProjectDashboardAnalyzeSensorDataFailure
                                          ? state.message
                                          : (state
                                                  as ProjectDashboardAnalyzeSensorDataQ2Failure)
                                              .message,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      },
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

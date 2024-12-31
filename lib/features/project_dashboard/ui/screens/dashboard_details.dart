import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/data/models/project_dashboards.dart';
import 'package:pulsehub/features/project_dashboard/data/repos/dash_repo_impl.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/time_series_chart.dart';

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
  int windowSize = 20; // Default window size
  String windowPeriod = '5m'; // Default window period
  final TextEditingController deviationController =
      TextEditingController(text: '0.05');
  final TextEditingController windowSizeController =
      TextEditingController(text: '20');
  final TextEditingController windowPeriodController =
      TextEditingController(text: '5m');

  String aggregateFunction = 'mean';
  String timeRange = '1h'; // Default time range
  bool isCustomRange = false; // Flag for custom range
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

    // Use server-side field names directly
    final serverFields = selectedFields.map((field) {
      switch (field) {
        case 'accelX':
          return 'accelX';
        case 'accelY':
          return 'accelY';
        case 'accelZ':
          return 'accelZ';
        default:
          return field;
      }
    }).join(' ');

    final queryParams = QueryParams(
      measurementName: selectedMeasurement,
      topic: selectedTopic,
      fields: serverFields,
      sensorsToAnalyze: serverFields,
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
              if (state is ProjectDashboardDetailsSuccess) {
                final measurements =
                    state.cloudHubResponse.buckets!.first.measurements;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedMeasurement,
                      decoration: const InputDecoration(
                        labelText: 'Data Source',
                        border: OutlineInputBorder(),
                      ),
                      items: measurements!
                          .map((measurement) => DropdownMenuItem(
                                value: measurement.name,
                                child: Text(measurement.name!),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedMeasurement = value;
                          selectedTopic = null;
                          selectedFields.clear(); // Clear selected fields
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    if (selectedMeasurement != null)
                      DropdownButtonFormField<String>(
                        value: selectedTopic,
                        decoration: const InputDecoration(
                          labelText: 'CloudHub Topics',
                          border: OutlineInputBorder(),
                        ),
                        items: measurements
                            .firstWhere((m) => m.name == selectedMeasurement)
                            .topics!
                            .map((topic) => DropdownMenuItem(
                                  value: topic.name,
                                  child: Text(topic.name!),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedTopic = value;
                            selectedFields
                                .clear(); // Clear selected fields when topic changes
                          });
                        },
                      ),
                    const SizedBox(height: 16),
                    if (selectedTopic != null) ...[
                      const Text(
                        'Fields to Analyze:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: measurements
                                .firstWhere(
                                    (m) => m.name == selectedMeasurement)
                                .topics!
                                .firstWhere((t) => t.name == selectedTopic)
                                .fields!
                                .map((field) => FilterChip(
                                      label: Text(field.name!),
                                      selected:
                                          selectedFields.contains(field.name),
                                      onSelected: (bool selected) {
                                        setState(() {
                                          if (selected) {
                                            selectedFields.add(field.name!);
                                          } else {
                                            selectedFields.remove(field.name!);
                                          }
                                        });
                                      },
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Window Size Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Window Size:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: windowSizeController,
                            onChanged: (value) {
                              setState(() {
                                windowSize = int.tryParse(value) ?? windowSize;
                              });
                            },
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              isDense: true,
                              suffixIcon: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        windowSize++;
                                        windowSizeController.text =
                                            windowSize.toString();
                                      });
                                    },
                                    child: Icon(
                                      Icons.keyboard_arrow_up,
                                      size: 18,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        if (windowSize > 1) {
                                          windowSize--;
                                          windowSizeController.text =
                                              windowSize.toString();
                                        }
                                      });
                                    },
                                    child: Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 18,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Window Period:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: windowPeriod,
                      decoration: const InputDecoration(
                        labelText: 'Select Window Period',
                        border: OutlineInputBorder(),
                      ),
                      items: ['5s', '10s', '1m', '5m', '15m', '30m', '1h']
                          .map((period) {
                        return DropdownMenuItem(
                          value: period,
                          child: Text(period),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          windowPeriod = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Deviation Threshold Section in a new row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Deviation Threshold:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: deviationController,
                            onChanged: (value) {
                              setState(() {
                                double.tryParse(value) ??
                                    double.parse(deviationController.text);
                              });
                            },
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              isDense: true,
                              suffixIcon: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        final currentValue = double.tryParse(
                                                deviationController.text) ??
                                            0.0;
                                        deviationController.text =
                                            (currentValue + 0.01)
                                                .toStringAsFixed(2);
                                      });
                                    },
                                    child: Icon(
                                      Icons.keyboard_arrow_up,
                                      size: 18,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
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
                                    child: Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 18,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: aggregateFunction,
            decoration: const InputDecoration(
              labelText: 'Aggregate Function',
              border: OutlineInputBorder(),
            ),
            items: ['mean', 'sum', 'max', 'min', 'median']
                .map((func) => DropdownMenuItem(value: func, child: Text(func)))
                .toList(),
            onChanged: (value) {
              setState(() {
                aggregateFunction = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: timeRange,
            decoration: const InputDecoration(
              labelText: 'Select Time Range',
              border: OutlineInputBorder(),
            ),
            items: [
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
            ]
                .map((range) =>
                    DropdownMenuItem(value: range, child: Text(range)))
                .toList(),
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
          Row(
            children: [
              const Spacer(),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          BlocBuilder<ProjectDashboardCubit, ProjectDashboardState>(
            builder: (context, state) {
              if (state is ProjectDashboardDetailsTimeDbLoading) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading sensor data...'),
                    ],
                  ),
                );
              }

              if (state is ProjectDashboardDetailsTimeDbFailure) {
                return Center(
                  child: Text(
                    'Error: ${state.message}',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                );
              }

              if (state is ProjectDashboardDetailsTimeDbSuccess) {
                if (state.sensorDataResponse.result == null) {
                  return const Center(
                    child: Text(
                        'No sensor data available for the selected time range'),
                  );
                }

                return TimeSeriesChart(
                  data: state.sensorDataResponse,
                  selectedFields: selectedFields,
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

class DashboardDetailsheaderIcons extends StatelessWidget {
  const DashboardDetailsheaderIcons({
    super.key,
    required this.widget,
  });

  final DashboardDetails widget;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.filled(
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            widget.dashboard.name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Tooltip(
          message: 'Import Dashboard Data',
          child: IconButton.filled(
            icon: const Icon(Icons.download),
            onPressed: () {},
          ),
        ),
        Tooltip(
          message: 'Export Dashboard Data',
          child: IconButton.filled(
            icon: const Icon(Icons.upload),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}

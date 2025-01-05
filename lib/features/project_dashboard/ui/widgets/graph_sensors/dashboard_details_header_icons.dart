import 'dart:io';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/data/models/timedb_response.dart';
import 'package:pulsehub/features/project_dashboard/ui/screens/graph_dashboard_sensors.dart';
import 'package:share_plus/share_plus.dart';

class DashboardDetailsheaderIcons extends StatelessWidget {
  const DashboardDetailsheaderIcons({
    super.key,
    required this.widget,
  });

  final GraphDashboardSensors widget;

  SensorDataResponse? _parseCsvData(String csvData) {
    try {
      final rows = const CsvToListConverter().convert(csvData);

      // If the file is empty or has no header row, bail out
      if (rows.isEmpty) {
        throw Exception("CSV file is empty");
      }

      // Get headers from first row
      final headers = List<String>.from(rows[0]);
      if (headers.isEmpty) {
        throw Exception("CSV file has no headers");
      }

      // Find the time column index
      final timeIndex = headers.indexOf('Time');
      if (timeIndex == -1) {
        throw Exception("CSV must have a 'Time' column");
      }

      // Initialize data structures
      final Map<String, List<DateTime>> times = {};
      final Map<String, List<double>> values = {};
      final Map<String, List<double>> frequencies = {};
      final Map<String, List<double>> magnitudes = {};
      final Map<String, List<double>> dominateFrequencies = {};
      final Map<String, List<List<double>>> anomalyRegions = {};
      final Map<String, double> anomalyPercentages = {};
      final Map<String, dynamic> tickets = {};
      final Map<String, dynamic> openTickets = {};

      // Determine which columns are sensor data fields
      // A field is considered a sensor if it's not one of the special columns
      final specialColumns = {
        'Time',
        'frequency',
        'magnitude',
        'dominate_frequencies',
        'anomaly_percentage',
        'anomaly_regions',
        'open_ticket',
        'ticket'
      };
      final sensorFields =
          headers.where((h) => !specialColumns.contains(h)).toList();

      // Initialize lists for each sensor field
      for (final field in sensorFields) {
        times[field] = [];
        values[field] = [];
      }

      // Process each row
      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.length != headers.length) continue;

        // Parse time
        final timestamp = int.tryParse(row[timeIndex].toString());
        if (timestamp == null) continue;
        final time = DateTime.fromMillisecondsSinceEpoch(timestamp);

        // Process each sensor field
        for (final field in sensorFields) {
          final valueIndex = headers.indexOf(field);
          if (valueIndex != -1) {
            final value =
                double.tryParse(row[valueIndex].toString() ?? '') ?? 0.0;
            times[field]!.add(time);
            values[field]!.add(value);
          }
        }

        // Process special columns if they exist
        _processSpecialColumns(
          row,
          headers,
          sensorFields.first, // Use first sensor field as default
          frequencies,
          magnitudes,
          dominateFrequencies,
          anomalyRegions,
          anomalyPercentages,
          tickets,
          openTickets,
        );
      }

      // Create fields map for Result
      final fields = <String, Data>{};
      for (final field in sensorFields) {
        if (times[field]!.isNotEmpty && values[field]!.isNotEmpty) {
          fields[field] = Data(time: times[field], value: values[field]);
        }
      }

      return SensorDataResponse(
        result: Result(fields: fields),
        frequency: frequencies.isNotEmpty ? frequencies : null,
        magnitude: magnitudes.isNotEmpty ? magnitudes : null,
        dominate_frequencies:
            dominateFrequencies.isNotEmpty ? dominateFrequencies : null,
        anomaly_percentage:
            anomalyPercentages.isNotEmpty ? anomalyPercentages : null,
        anomaly_regions: anomalyRegions.isNotEmpty ? anomalyRegions : null,
        ticket: tickets.isNotEmpty ? tickets : null,
        open_ticket: openTickets.isNotEmpty ? openTickets : null,
      );
    } catch (e) {
      debugPrint('Error parsing CSV: $e');
      return null;
    }
  }

  void _processSpecialColumns(
    List<dynamic> row,
    List<String> headers,
    String field,
    Map<String, List<double>> frequencies,
    Map<String, List<double>> magnitudes,
    Map<String, List<double>> dominateFrequencies,
    Map<String, List<List<double>>> anomalyRegions,
    Map<String, double> anomalyPercentages,
    Map<String, dynamic> tickets,
    Map<String, dynamic> openTickets,
  ) {
    // Look for field-specific special columns
    final freqIndex = headers.indexOf('${field}_frequency');
    final magIndex = headers.indexOf('${field}_magnitude');
    final domFreqIndex = headers.indexOf('${field}_dominate_frequencies');
    final anomalyPctIndex = headers.indexOf('${field}_anomaly_percentage');
    final anomalyRegionsIndex = headers.indexOf('${field}_anomaly_regions');
    final ticketIndex = headers.indexOf('${field}_ticket');
    final openTicketIndex = headers.indexOf('${field}_open_ticket');

    if (freqIndex != -1) {
      frequencies[field] ??= [];
      frequencies[field]!
          .add(double.tryParse(row[freqIndex].toString()) ?? 0.0);
    }

    if (magIndex != -1) {
      magnitudes[field] ??= [];
      magnitudes[field]!.add(double.tryParse(row[magIndex].toString()) ?? 0.0);
    }

    if (domFreqIndex != -1) {
      dominateFrequencies[field] ??= [];
      dominateFrequencies[field]!
          .add(double.tryParse(row[domFreqIndex].toString()) ?? 0.0);
    }

    if (anomalyPctIndex != -1) {
      final value = double.tryParse(row[anomalyPctIndex].toString()) ?? 0.0;
      anomalyPercentages[field] = value;
    }

    if (anomalyRegionsIndex != -1) {
      anomalyRegions[field] ??= [];
      final regions = (row[anomalyRegionsIndex].toString())
          .split(';')
          .map((e) => double.tryParse(e.trim()) ?? 0.0)
          .toList();
      anomalyRegions[field]!.add(regions);
    }

    if (ticketIndex != -1) {
      tickets[field] = row[ticketIndex];
    }

    if (openTicketIndex != -1) {
      openTickets[field] = row[openTicketIndex];
    }
  }

  Future<void> _importCsv(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'], // Restrict to CSV files
      );

      if (result == null || result.files.isEmpty) {
        throw Exception("No file selected");
      }

      final file = File(result.files.single.path!);
      final csvData = await file.readAsString();
      final parsedData = _parseCsvData(csvData);

      if (parsedData == null) {
        throw Exception("Invalid CSV structure");
      }

      context.read<ProjectDashboardCubit>().updateSensorData(parsedData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data uploaded successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  String _generateCsvData(SensorDataResponse data) {
    final List<List<dynamic>> csvData = [];
    final result = data.result;
    if (result == null) return '';

    // Get all field names
    final fields = result.getFieldNames();
    if (fields.isEmpty) return '';

    // Create headers with special columns for each field
    final headers = ['Time'];
    final specialColumns = [
      'frequency',
      'magnitude',
      'dominate_frequencies',
      'anomaly_percentage',
      'anomaly_regions',
      'open_ticket',
      'ticket'
    ];

    // Add field and its special columns
    for (final field in fields) {
      headers.add(field); // Add the main field
      // Add special columns for this field
      for (final special in specialColumns) {
        headers.add('${field}_$special');
      }
    }
    csvData.add(headers);

    // Get the time series with the most data points
    var maxTimePoints = 0;
    for (final field in fields) {
      final fieldData = result.getField(field);
      if (fieldData?.time != null && fieldData!.time!.length > maxTimePoints) {
        maxTimePoints = fieldData.time!.length;
      }
    }

    if (maxTimePoints == 0) return '';

    // For each time point
    for (var i = 0; i < maxTimePoints; i++) {
      final row = List<dynamic>.filled(headers.length, '');

      // Set time (use the first available field's time)
      for (final field in fields) {
        final fieldData = result.getField(field);
        if (fieldData?.time != null && i < fieldData!.time!.length) {
          row[0] = fieldData.time![i].millisecondsSinceEpoch;
          break;
        }
      }

      // For each field, set its value and special columns
      for (final field in fields) {
        final fieldData = result.getField(field);
        final baseIndex = headers.indexOf(field);
        if (baseIndex == -1) continue;

        // Set main field value
        if (fieldData?.value != null && i < fieldData!.value!.length) {
          row[baseIndex] = fieldData.value![i];
        }

        // Set frequency
        if (data.frequency?[field] != null &&
            i < data.frequency![field]!.length) {
          row[baseIndex + 1] = data.frequency![field]![i];
        }

        // Set magnitude
        if (data.magnitude?[field] != null &&
            i < data.magnitude![field]!.length) {
          row[baseIndex + 2] = data.magnitude![field]![i];
        }

        // Set dominate frequencies
        if (data.dominate_frequencies?[field] != null &&
            i < data.dominate_frequencies![field]!.length) {
          row[baseIndex + 3] = data.dominate_frequencies![field]![i];
        }

        // Set anomaly percentage
        if (data.anomaly_percentage?[field] != null) {
          row[baseIndex + 4] = data.anomaly_percentage![field];
        }

        // Set anomaly regions
        if (data.anomaly_regions?[field] != null &&
            i < data.anomaly_regions![field]!.length) {
          row[baseIndex + 5] = data.anomaly_regions![field]![i].join(';');
        }

        // Set open ticket
        if (data.open_ticket?[field] != null) {
          row[baseIndex + 6] = data.open_ticket![field];
        }

        // Set ticket
        if (data.ticket?[field] != null) {
          row[baseIndex + 7] = data.ticket![field];
        }
      }

      csvData.add(row);
    }

    return const ListToCsvConverter().convert(csvData);
  }

  void _exportCsv(SensorDataResponse data) {
    try {
      final csvData = _generateCsvData(data);

      final fileName = '${widget.dashboard.name}_data.csv';
      final csvBytes = Uint8List.fromList(csvData.codeUnits);

      Share.shareXFiles(
        [XFile.fromData(csvBytes, name: fileName, mimeType: 'text/csv')],
        text: 'Exported CSV File',
      ).then((_) {}).catchError((error) {
        Share.share(csvData, subject: 'Exported CSV File');
      });
    } catch (e) {
      rethrow;
    }
  }

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
        BlocBuilder<ProjectDashboardCubit, ProjectDashboardState>(
          builder: (context, state) {
            final isDownloadEnabled =
                state is ProjectDashboardDetailsTimeDbSuccess;

            return Tooltip(
              message: 'Import Dashboard Data',
              child: IconButton.filled(
                icon: const Icon(Icons.download),
                onPressed: isDownloadEnabled
                    ? () {
                        final data = (state).sensorDataResponse;
                        _exportCsv(data);
                      }
                    : null,
                color: isDownloadEnabled ? null : Colors.grey,
              ),
            );
          },
        ),
        Tooltip(
          message: 'Export Dashboard Data',
          child: IconButton.filled(
            icon: const Icon(Icons.upload),
            onPressed: () => _importCsv(context),
          ),
        ),
      ],
    );
  }
}

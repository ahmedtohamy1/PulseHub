import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/data/models/timedb_response.dart';
import 'package:csv/csv.dart';
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

      // If the file is completely empty or there's no header row, bail out
      if (rows.isEmpty || rows[0].length < 13) {
        throw Exception("CSV file format is incorrect");
      }

      final time = <DateTime>[];
      final accelX = <double>[];
      final accelY = <double>[];
      final accelZ = <double>[];
      final humidity = <double>[];
      final temperature = <double>[];
      final frequency = <double>[];
      final magnitude = <double>[];
      final dominateFrequencies = <double>[];
      final anomalyRegions = <List<double>>[];

      // Start from row index 1, because row[0] is typically your CSV header
      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];

        // --- 1) Skip if the row is too short to have all columns we need:
        if (row.length < 10) {
          continue;
        }

        // --- 2) Determine if this row is "empty" by checking columns you require:
        //         For instance, time, temperature, accelX, etc.
        bool isRowEmpty = true;
        // Check the first 6 columns as an example (depending on your CSV structure):
        for (var j = 0; j < 6; j++) {
          final cell = row[j];
          if (cell != null && cell.toString().trim().isNotEmpty) {
            isRowEmpty = false;
            break;
          }
        }
        if (isRowEmpty) {
          continue;
        }

        // If not empty, parse the row
        time.add(DateTime.fromMillisecondsSinceEpoch(
          int.tryParse(row[0].toString()) ?? 0,
        ));
        accelX.add(double.tryParse(row[1]?.toString() ?? '') ?? 0.0);
        accelY.add(double.tryParse(row[2]?.toString() ?? '') ?? 0.0);
        accelZ.add(double.tryParse(row[3]?.toString() ?? '') ?? 0.0);
        humidity.add(double.tryParse(row[4]?.toString() ?? '') ?? 0.0);
        temperature.add(double.tryParse(row[5]?.toString() ?? '') ?? 0.0);
        frequency.add(double.tryParse(row[6]?.toString() ?? '') ?? 0.0);
        magnitude.add(double.tryParse(row[7]?.toString() ?? '') ?? 0.0);
        dominateFrequencies
            .add(double.tryParse(row[8]?.toString() ?? '') ?? 0.0);

        final anomalyRegion = (row[9]?.toString() ?? '')
            .split(';')
            .map((e) => double.tryParse(e) ?? 0.0)
            .toList();
        anomalyRegions.add(anomalyRegion);
      }

      // Construct your SensorDataResponse only with the filtered, non-empty rows
      return SensorDataResponse(
        result: Result(
          accelX: Data(time: time, value: accelX),
          accelY: Data(time: time, value: accelY),
          accelZ: Data(time: time, value: accelZ),
          humidity: Data(time: time, value: humidity),
          temperature: Data(time: time, value: temperature),
        ),
        frequency: {'accelX': frequency},
        magnitude: {'accelX': magnitude},
        dominate_frequencies: {'accelX': dominateFrequencies},
        anomaly_regions: {'accelX': anomalyRegions},
        anomaly_percentage: {'accelX': 0.0}, // Default value
        open_ticket: {'accelX': false},
        ticket: {'accelX': false},
      );
    } catch (e) {
      debugPrint('Error parsing CSV: $e');
      return null;
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

    csvData.add([
      'Time',
      'accelX',
      'accelY',
      'accelZ',
      'humidity',
      'temperature',
      'frequency',
      'magnitude',
      'dominate_frequencies',
      'anomaly_percentage',
      'anomaly_regions',
      'open_ticket',
      'ticket'
    ]);

    // 1) Figure out which time list to use
    //    If accelX is empty, try temperature, etc.
    final allTimes = [
      data.result?.accelX?.time,
      data.result?.temperature?.time,
      data.result?.humidity?.time,
      data.result?.accelY?.time,
      data.result?.accelZ?.time,
    ];

    // Pick the first non-empty list of times we find:
    List<DateTime> time = [];
    for (final tList in allTimes) {
      if (tList != null && tList.isNotEmpty) {
        time = tList;
        break;
      }
    }

    // If we still have no times, throw an exception
    if (time.isEmpty) {
      throw Exception("No data available to export.");
    }

    // 2) Grab each series. If null or shorter than time, fill with empty strings
    List<double> accelX = data.result?.accelX?.value ?? [];
    List<double> accelY = data.result?.accelY?.value ?? [];
    List<double> accelZ = data.result?.accelZ?.value ?? [];
    List<double> humidity = data.result?.humidity?.value ?? [];
    List<double> temperature = data.result?.temperature?.value ?? [];

    // Frequencies, magnitudes, etc.
    final freqX = data.frequency?['accelX'] ?? [];
    final magX = data.magnitude?['accelX'] ?? [];
    final domFreqX = data.dominate_frequencies?['accelX'] ?? [];
    final anomalyRegionsX = data.anomaly_regions?['accelX'] ?? [];
    final anomalyPctX = data.anomaly_percentage?['accelX'] ?? '';
    final openTicketX = data.open_ticket?['accelX'] ?? '';
    final ticketX = data.ticket?['accelX'] ?? '';

    // 3) Loop through and add rows
    for (int i = 0; i < time.length; i++) {
      final row = [
        time[i].millisecondsSinceEpoch,
        i < accelX.length ? accelX[i] : '',
        i < accelY.length ? accelY[i] : '',
        i < accelZ.length ? accelZ[i] : '',
        i < humidity.length ? humidity[i] : '',
        i < temperature.length ? temperature[i] : '',
        i < freqX.length ? freqX[i] : '',
        i < magX.length ? magX[i] : '',
        i < domFreqX.length ? domFreqX[i] : '',
        anomalyPctX,
        i < anomalyRegionsX.length ? (anomalyRegionsX[i]).join('; ') : '',
        openTicketX,
        ticketX,
      ];
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
    } catch (e) {}
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

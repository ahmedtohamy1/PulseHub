import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/data/models/timedb_response.dart';
import 'package:csv/csv.dart';
import 'package:pulsehub/features/project_dashboard/ui/screens/dashboard_details.dart';
import 'package:share_plus/share_plus.dart';

class DashboardDetailsheaderIcons extends StatelessWidget {
  const DashboardDetailsheaderIcons({
    super.key,
    required this.widget,
  });

  final DashboardDetails widget;
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

    final time = data.result?.accelX?.time ?? [];
    final accelX = data.result?.accelX?.value ?? [];
    final accelY = data.result?.accelY?.value ?? [];
    final accelZ = data.result?.accelZ?.value ?? [];
    final humidity = data.result?.humidity?.value ?? [];
    final temperature = data.result?.temperature?.value ?? [];

    if (time.isEmpty) {
      throw Exception("No data available to export.");
    }

    for (int i = 0; i < time.length; i++) {
      csvData.add([
        time[i].millisecondsSinceEpoch,
        i < accelX.length ? accelX[i] : '',
        i < accelY.length ? accelY[i] : '',
        i < accelZ.length ? accelZ[i] : '',
        i < humidity.length ? humidity[i] : '',
        i < temperature.length ? temperature[i] : '',
        i < (data.frequency?['accelX']?.length ?? 0)
            ? data.frequency!['accelX']![i]
            : '',
        i < (data.magnitude?['accelX']?.length ?? 0)
            ? data.magnitude!['accelX']![i]
            : '',
        i < (data.dominate_frequencies?['accelX']?.length ?? 0)
            ? data.dominate_frequencies!['accelX']![i]
            : '',
        data.anomaly_percentage?['accelX'] ?? '',
        i < (data.anomaly_regions?['accelX']?.length ?? 0)
            ? data.anomaly_regions!['accelX']![i].join('; ')
            : '',
        data.open_ticket?['accelX'] ?? '',
        data.ticket?['accelX'] ?? '',
      ]);
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
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}

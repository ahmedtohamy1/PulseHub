import 'package:flutter/material.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/graph_sensors/number_input.dart';

class AnalysisParametersDialog extends StatefulWidget {
  final String initialWindowPeriod;
  final String initialDeviation;

  const AnalysisParametersDialog({
    super.key,
    required this.initialWindowPeriod,
    required this.initialDeviation,
  });

  @override
  State<AnalysisParametersDialog> createState() =>
      _AnalysisParametersDialogState();
}

class _AnalysisParametersDialogState extends State<AnalysisParametersDialog> {
  late String windowSize;
  late String deviation;
  late final TextEditingController windowSizeController;
  late final TextEditingController deviationController;

  @override
  void initState() {
    super.initState();
    windowSize = widget.initialWindowPeriod;
    deviation = widget.initialDeviation;
    windowSizeController =
        TextEditingController(text: widget.initialWindowPeriod);
    deviationController = TextEditingController(text: widget.initialDeviation);
  }

  @override
  void dispose() {
    windowSizeController.dispose();
    deviationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.analytics_outlined),
          SizedBox(width: 8),
          Text('Analysis Parameters'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NumberInput(
              label: 'Window Size',
              controller: windowSizeController,
              onChanged: (value) {
                setState(() => windowSize = value);
              },
              onIncrement: () {
                final currentValue =
                    int.tryParse(windowSizeController.text) ?? 0;
                windowSizeController.text = (currentValue + 1).toString();
              },
              onDecrement: () {
                final currentValue =
                    int.tryParse(windowSizeController.text) ?? 0;
                if (currentValue > 1) {
                  windowSizeController.text = (currentValue - 1).toString();
                }
              },
            ),
            const SizedBox(height: 16),
            NumberInput(
              label: 'Deviation Threshold',
              controller: deviationController,
              onChanged: (value) {
                setState(() => deviation = value);
              },
              onIncrement: () {
                final currentValue =
                    double.tryParse(deviationController.text) ?? 0;
                deviationController.text =
                    (currentValue + 0.01).toStringAsFixed(2);
              },
              onDecrement: () {
                final currentValue =
                    double.tryParse(deviationController.text) ?? 0;
                if (currentValue > 0.01) {
                  deviationController.text =
                      (currentValue - 0.01).toStringAsFixed(2);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop({
              'windowSize': windowSizeController.text,
              'deviation': deviationController.text,
            });
          },
          child: const Text('Analyze'),
        ),
      ],
    );
  }
}

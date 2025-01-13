import 'package:flutter/material.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

class CustomTimeRangeDialog extends StatefulWidget {
  const CustomTimeRangeDialog({
    super.key,
  });

  @override
  State<CustomTimeRangeDialog> createState() => _CustomTimeRangeDialogState();
}

class _CustomTimeRangeDialogState extends State<CustomTimeRangeDialog> {
  DateTime? startDateTime;
  DateTime? endDateTime;

  String _formatDateTime(DateTime dateTime) {
    final hour = dateTime.hour == 0
        ? 12
        : dateTime.hour > 12
            ? dateTime.hour - 12
            : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}, ${hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.date_range),
          SizedBox(width: 8),
          Text('Custom Time Range'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FilledButton.icon(
              onPressed: () async {
                final dateTimeList = await showOmniDateTimeRangePicker(
                  context: context,
                  startInitialDate: startDateTime ?? DateTime.now(),
                  startFirstDate: DateTime(2020),
                  startLastDate: DateTime.now(),
                  endInitialDate: endDateTime ?? DateTime.now(),
                  endFirstDate: DateTime(2020),
                  endLastDate: DateTime.now(),
                  is24HourMode: false,
                  isShowSeconds: false,
                  minutesInterval: 1,
                  secondsInterval: 1,
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  constraints: const BoxConstraints(
                    maxWidth: 350,
                    maxHeight: 650,
                  ),
                  transitionBuilder: (context, anim1, anim2, child) {
                    return FadeTransition(
                      opacity: anim1.drive(
                        Tween(
                          begin: 0,
                          end: 1,
                        ),
                      ),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 200),
                  barrierDismissible: true,
                );

                if (dateTimeList != null && context.mounted) {
                  setState(() {
                    startDateTime = dateTimeList[0];
                    endDateTime = dateTimeList[1];
                  });
                }
              },
              icon: const Icon(Icons.calendar_month),
              label: const Text('Select Date & Time Range'),
            ),
            if (startDateTime != null && endDateTime != null) ...[
              const SizedBox(height: 16),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Start: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: _formatDateTime(startDateTime!)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'End: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: _formatDateTime(endDateTime!)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        if (startDateTime != null && endDateTime != null)
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop({
                'start': startDateTime!.toUtc().toIso8601String(),
                'time_range_stop': endDateTime!.toUtc().toIso8601String(),
              });
            },
            child: const Text('Apply'),
          ),
      ],
    );
  }
}

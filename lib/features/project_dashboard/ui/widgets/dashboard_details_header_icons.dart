import 'package:flutter/material.dart';
import 'package:pulsehub/features/project_dashboard/ui/screens/dashboard_details.dart';

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

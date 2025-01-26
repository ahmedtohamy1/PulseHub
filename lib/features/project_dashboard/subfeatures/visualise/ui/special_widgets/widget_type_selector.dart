import 'package:flutter/material.dart';
import 'package:pulsehub/core/utils/user_manager.dart';

class WidgetTypeSelector extends StatelessWidget {
  final Function(String) onTypeSelected;

  const WidgetTypeSelector({
    super.key,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isStaffOrSuperuser = UserManager().user?.isStaff == true ||
        UserManager().user?.isSuperuser == true;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Select Widget Type',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: Icon(Icons.bar_chart, color: colorScheme.primary),
            title: const Text('Chart'),
            onTap: () => onTypeSelected('chart'),
          ),
          ListTile(
            leading: Icon(Icons.table_chart, color: colorScheme.primary),
            title: const Text('Table'),
            onTap: () => onTypeSelected('table'),
          ),
          if (isStaffOrSuperuser) ...[
            const Divider(),
            ListTile(
              leading: Icon(Icons.sensors, color: colorScheme.primary),
              title: const Text('Image Sensor Placing'),
              subtitle: const Text('Place sensors on an image (Staff only)'),
              onTap: () => onTypeSelected('image_sensor'),
            ),
          ],
        ],
      ),
    );
  }
}

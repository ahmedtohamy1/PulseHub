import 'package:flutter/material.dart';

class WidgetTypeSelector extends StatelessWidget {
  final Function(String) onTypeSelected;

  const WidgetTypeSelector({
    super.key,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Select Widget Type',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.bar_chart),
          title: const Text('Charts'),
          onTap: () => onTypeSelected('chart'),
        ),
        ListTile(
          leading: const Icon(Icons.table_chart),
          title: const Text('Tables'),
          onTap: () => onTypeSelected('table'),
        ),
      ],
    );
  }
}

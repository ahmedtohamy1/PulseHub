import 'package:flutter/material.dart';

class FieldSelector extends StatelessWidget {
  final List<String> fields;
  final List<String> selectedFields;
  final void Function(String, bool) onFieldSelected;

  const FieldSelector({
    super.key,
    required this.fields,
    required this.selectedFields,
    required this.onFieldSelected,
  });

  @override
  Widget build(BuildContext context) {
    return _buildLabeledWidget(
      label: 'Fields to Analyze',
      child: Container(
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
            children: fields.map((field) {
              return FilterChip(
                label: Text(field),
                selected: selectedFields.contains(field),
                onSelected: (selected) => onFieldSelected(field, selected),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// Reusable function to add a label and consistent border styling
Widget _buildLabeledWidget({
  required String label,
  required Widget child,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      const SizedBox(height: 8),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: child,
      ),
    ],
  );
}

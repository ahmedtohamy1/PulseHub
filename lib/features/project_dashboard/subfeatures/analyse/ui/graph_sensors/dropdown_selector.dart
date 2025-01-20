import 'package:flutter/material.dart';

class DropdownSelector<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T)? itemToString;
  final void Function(T?) onChanged;

  const DropdownSelector({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.itemToString,
  });

  @override
  Widget build(BuildContext context) {
    return _buildLabeledWidget(
      label: label,
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(itemToString?.call(item) ?? item.toString()),
          );
        }).toList(),
        onChanged: onChanged,
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

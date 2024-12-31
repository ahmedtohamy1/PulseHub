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
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(itemToString?.call(item) ?? item.toString()),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

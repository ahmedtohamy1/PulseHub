import 'package:flutter/material.dart';

class NumberInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final void Function(String) onChanged;
  final void Function()? onIncrement;
  final void Function()? onDecrement;

  const NumberInput({
    super.key,
    required this.label,
    required this.controller,
    required this.onChanged,
    this.onIncrement,
    this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return _buildLabeledWidget(
      label: label,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
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
          suffixIcon: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: onIncrement,
                child: Icon(
                  Icons.keyboard_arrow_up,
                  size: 18,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              InkWell(
                onTap: onDecrement,
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.left,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 14,
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

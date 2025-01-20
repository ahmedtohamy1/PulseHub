import 'package:flutter/material.dart';

class EditableInfoRow extends StatefulWidget {
  final String label;
  final String value;
  final bool isEditing;
  final TextEditingController? controller;
  final IconData? icon;

  const EditableInfoRow({
    super.key,
    required this.label,
    required this.value,
    required this.isEditing,
    this.controller,
    this.icon,
  });

  @override
  State<EditableInfoRow> createState() => _EditableInfoRowState();
}

class _EditableInfoRowState extends State<EditableInfoRow> {
  bool get isDateField {
    return widget.label.toLowerCase().contains('date') ||
        widget.label.toLowerCase().contains('start');
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _parseDate(widget.value) ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null && widget.controller != null) {
      // Display in MM/DD/YYYY format for UI
      final displayDate = "${picked.month}/${picked.day}/${picked.year}";
      // Store in YYYY-MM-DD format for API
      final apiDate =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      widget.controller!.text = apiDate;
      setState(() {
        _displayValue = displayDate;
      });
    }
  }

  DateTime? _parseDate(String value) {
    try {
      if (value == 'N/A') return null;

      // Try to parse YYYY-MM-DD format first
      if (value.contains('-')) {
        return DateTime.parse(value);
      }

      // Try to parse MM/DD/YYYY format
      final parts = value.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]), // year
          int.parse(parts[0]), // month
          int.parse(parts[1]), // day
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  String? _displayValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                widget.icon,
                size: 20,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 3,
            child: Text(
              widget.label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 5,
            child: widget.isEditing
                ? isDateField
                    ? TextFormField(
                        controller: widget.controller,
                        readOnly: true,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.all(8),
                          border: const OutlineInputBorder(),
                          hintText: widget.value,
                          hintStyle: TextStyle(
                            color: Theme.of(context).hintColor,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () => _showDatePicker(context),
                          ),
                        ),
                        // Show MM/DD/YYYY in the field but keep YYYY-MM-DD in the controller
                        onTap: () => _showDatePicker(context),
                      )
                    : TextFormField(
                        controller: widget.controller,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.all(8),
                          border: const OutlineInputBorder(),
                          hintText: widget.value,
                          hintStyle: TextStyle(
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      )
                : Text(_displayValue ?? widget.value),
          ),
        ],
      ),
    );
  }
}

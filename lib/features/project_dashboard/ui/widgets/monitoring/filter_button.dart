import 'package:flutter/material.dart';

class FilterButtonWidget extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const FilterButtonWidget({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.green, // Background color of the button
          borderRadius: BorderRadius.circular(8.0), // Rounded corners
        ),
        child: const Icon(
          Icons.filter_list,
          color: Colors.white, // Icon color
        ),
      ),
      onSelected: (value) {
        onFilterChanged(value); // Update the selected filter
      },
      itemBuilder: (context) {
        return [
          const PopupMenuItem(
            value: "All",
            child: ListTile(
              leading: Icon(Icons.public, color: Colors.blue),
              title: Text("All"),
            ),
          ),
          const PopupMenuItem(
            value: "Operational",
            child: ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text("Operational"),
            ),
          ),
          const PopupMenuItem(
            value: "Warning",
            child: ListTile(
              leading: Icon(Icons.warning, color: Colors.orange),
              title: Text("Warning"),
            ),
          ),
          const PopupMenuItem(
            value: "Critical",
            child: ListTile(
              leading: Icon(Icons.error, color: Colors.red),
              title: Text("Critical"),
            ),
          ),
        ];
      },
    );
  }
}

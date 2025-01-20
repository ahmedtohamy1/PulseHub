import 'package:flutter/material.dart';

class TableContainer extends StatelessWidget {
  final List<List<String>> data;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TableContainer({
    super.key,
    required this.data,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Data Table',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton.filled(
                      icon: const Icon(Icons.edit),
                      onPressed: onEdit,
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: onDelete,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width - 64,
                ),
                child: Table(
                  border: TableBorder.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                  defaultColumnWidth: const IntrinsicColumnWidth(),
                  children: [
                    // Header row
                    TableRow(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                      ),
                      children: data[0].map((header) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            header,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    // Data rows
                    ...data.skip(1).map((row) {
                      return TableRow(
                        children: row.map((cell) {
                          return Container(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              cell,
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

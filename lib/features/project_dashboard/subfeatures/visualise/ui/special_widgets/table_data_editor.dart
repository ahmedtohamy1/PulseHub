import 'package:flutter/material.dart';

class TableDataEditor extends StatefulWidget {
  final List<List<String>> initialData;
  final Function(List<List<String>>) onSave;

  const TableDataEditor({
    super.key,
    required this.initialData,
    required this.onSave,
  });

  @override
  State<TableDataEditor> createState() => _TableDataEditorState();
}

class _TableDataEditorState extends State<TableDataEditor> {
  late List<List<TextEditingController>> _controllers;
  late int _columns;
  late int _rows;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _columns = widget.initialData[0].length;
    _rows = widget.initialData.length;
    _controllers = List.generate(
      _rows,
      (i) => List.generate(
        _columns,
        (j) => TextEditingController(text: widget.initialData[i][j]),
      ),
    );
  }

  void _addRow() {
    setState(() {
      _rows++;
      _controllers.add(
        List.generate(
          _columns,
          (index) => TextEditingController(text: ''),
        ),
      );
    });
  }

  void _removeRow() {
    if (_rows > 2) {
      setState(() {
        _rows--;
        for (var controller in _controllers.last) {
          controller.dispose();
        }
        _controllers.removeLast();
      });
    }
  }

  void _addColumn() {
    setState(() {
      _columns++;
      for (var row in _controllers) {
        row.add(TextEditingController(text: ''));
      }
    });
  }

  void _removeColumn() {
    if (_columns > 1) {
      setState(() {
        _columns--;
        for (var row in _controllers) {
          row.last.dispose();
          row.removeLast();
        }
      });
    }
  }

  @override
  void dispose() {
    for (var row in _controllers) {
      for (var controller in row) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Edit Table Data',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildToolbarButton(
                      icon: Icons.add,
                      label: 'Add Row',
                      onPressed: _addRow,
                    ),
                    const SizedBox(width: 8),
                    _buildToolbarButton(
                      icon: Icons.remove,
                      label: 'Remove Row',
                      onPressed: _rows > 2 ? _removeRow : null,
                    ),
                    const SizedBox(width: 16),
                    _buildToolbarButton(
                      icon: Icons.add,
                      label: 'Add Column',
                      onPressed: _addColumn,
                    ),
                    const SizedBox(width: 8),
                    _buildToolbarButton(
                      icon: Icons.remove,
                      label: 'Remove Column',
                      onPressed: _columns > 1 ? _removeColumn : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Table(
                      border: TableBorder.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      defaultColumnWidth: const FixedColumnWidth(150),
                      children: List.generate(_rows, (i) {
                        return TableRow(
                          decoration: i == 0
                              ? BoxDecoration(
                                  color: Colors.grey.shade100,
                                )
                              : null,
                          children: List.generate(_columns, (j) {
                            return Container(
                              padding: const EdgeInsets.all(8),
                              child: TextField(
                                controller: _controllers[i][j],
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  hintText: i == 0 ? 'Header ${j + 1}' : 'Cell',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                style: TextStyle(
                                  fontWeight: i == 0 ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          }),
                        );
                      }),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      final data = _controllers.map(
                        (row) => row.map((c) => c.text).toList(),
                      ).toList();
                      widget.onSave(data);
                      Navigator.pop(context);
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

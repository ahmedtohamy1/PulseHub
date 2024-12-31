import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartDataEditor extends StatefulWidget {
  final String type;
  final dynamic data;
  final Function(dynamic) onSave;

  const ChartDataEditor({
    super.key,
    required this.type,
    required this.data,
    required this.onSave,
  });

  @override
  State<ChartDataEditor> createState() => _ChartDataEditorState();
}

class _ChartDataEditorState extends State<ChartDataEditor> {
  final formKey = GlobalKey<FormState>();
  final xControllers = <TextEditingController>[];
  final yControllers = <TextEditingController>[];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  // Initialize controllers based on chart type
  void _initializeControllers() {
    if (widget.type == 'pie' || widget.type == 'radar') {
      for (var value in widget.data) {
        yControllers.add(TextEditingController(text: value.toString()));
      }
    } else {
      for (var spot in widget.data) {
        xControllers.add(TextEditingController(text: spot.x.toString()));
        yControllers.add(TextEditingController(text: spot.y.toString()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Chart Data'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (widget.type == 'pie' || widget.type == 'radar')
                ...yControllers.map((controller) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: controller,
                            decoration: const InputDecoration(
                              labelText: 'Value',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a value';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              yControllers.remove(controller);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                })
              else
                ...List.generate(xControllers.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: xControllers[index],
                            decoration: const InputDecoration(
                              labelText: 'X',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a value';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: yControllers[index],
                            decoration: const InputDecoration(
                              labelText: 'Y',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a value';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              xControllers.removeAt(index);
                              yControllers.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                }),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    if (widget.type == 'pie' || widget.type == 'radar') {
                      yControllers.add(TextEditingController());
                    } else {
                      xControllers.add(TextEditingController());
                      yControllers.add(TextEditingController());
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              widget.onSave(_getUpdatedData());
              Navigator.of(context).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  // Function to get updated data from controllers
  dynamic _getUpdatedData() {
    if (widget.type == 'pie') {
      return yControllers.map((c) => double.tryParse(c.text) ?? 0.0).toList();
    } else if (widget.type == 'radar') {
      return yControllers
          .map((c) => RadarEntry(value: double.tryParse(c.text) ?? 0.0))
          .toList();
    } else {
      return List.generate(xControllers.length, (index) {
        return FlSpot(
          double.tryParse(xControllers[index].text) ?? 0.0,
          double.tryParse(yControllers[index].text) ?? 0.0,
        );
      });
    }
  }
}

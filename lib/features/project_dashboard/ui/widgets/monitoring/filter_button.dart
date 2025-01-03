import 'package:flutter/material.dart';

class FilterButtonWidget extends StatefulWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const FilterButtonWidget({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  State<FilterButtonWidget> createState() => _FilterButtonWidgetState();
}

class _FilterButtonWidgetState extends State<FilterButtonWidget> {
  Offset buttonPosition = const Offset(16, 16);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: buttonPosition.dy,
      left: buttonPosition.dx,
      child: Draggable(
        feedback: _buildFilterButton(),
        childWhenDragging: Container(),
        onDragEnd: (details) {
          final screenSize = MediaQuery.of(context).size;
          const buttonSize = 56.0;
          const bottomMargin = 200.0;

          setState(() {
            buttonPosition = Offset(
              details.offset.dx.clamp(0.0, screenSize.width - buttonSize),
              details.offset.dy
                  .clamp(0.0, screenSize.height - buttonSize - bottomMargin),
            );
          });
        },
        child: _buildFilterButton(),
      ),
    );
  }

  Widget _buildFilterButton() {
    return FloatingActionButton(
      onPressed: () {
        showMenu(
          context: context,
          position: RelativeRect.fromLTRB(
            buttonPosition.dx,
            buttonPosition.dy,
            MediaQuery.of(context).size.width - buttonPosition.dx - 56,
            MediaQuery.of(context).size.height - buttonPosition.dy - 56,
          ),
          items: [
            PopupMenuItem(
              child: ListTile(
                leading: const Icon(Icons.public, color: Colors.blue),
                title: const Text("All"),
                onTap: () {
                  widget.onFilterChanged("All");
                  Navigator.pop(context);
                },
              ),
            ),
            PopupMenuItem(
              child: ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text("Operational"),
                onTap: () {
                  widget.onFilterChanged("Operational");
                  Navigator.pop(context);
                },
              ),
            ),
            PopupMenuItem(
              child: ListTile(
                leading: const Icon(Icons.warning, color: Colors.orange),
                title: const Text("Warning"),
                onTap: () {
                  widget.onFilterChanged("Warning");
                  Navigator.pop(context);
                },
              ),
            ),
            PopupMenuItem(
              child: ListTile(
                leading: const Icon(Icons.error, color: Colors.red),
                title: const Text("Critical"),
                onTap: () {
                  widget.onFilterChanged("Critical");
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        );
      },
      backgroundColor: Colors.green,
      child: const Icon(Icons.filter_list, color: Colors.white),
    );
  }
}

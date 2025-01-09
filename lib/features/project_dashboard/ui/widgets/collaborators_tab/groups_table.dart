import 'package:flutter/material.dart';
import 'package:pulsehub/features/project_dashboard/data/models/get_collaborators_response_model.dart';

class GroupsTable extends StatelessWidget {
  final List<Group> groups;
  final Function(Group group) onEditGroup;
  final Function(Group group) onDeleteGroup;

  const GroupsTable({
    super.key,
    required this.groups,
    required this.onEditGroup,
    required this.onDeleteGroup,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          headingRowColor: MaterialStateColor.resolveWith(
            (states) => Theme.of(context).colorScheme.primary,
          ),
          columns: const [
            DataColumn(
              label: Text('Group Name', style: TextStyle(color: Colors.white)),
            ),
            DataColumn(
              label: Text('Description', style: TextStyle(color: Colors.white)),
            ),
            DataColumn(
              label: Text('Actions', style: TextStyle(color: Colors.white)),
            ),
          ],
          rows: List.generate(groups.length, (index) {
            final group = groups[index];
            final rowColor = index % 2 == 0
                ? Theme.of(context).colorScheme.secondaryContainer
                : Theme.of(context).colorScheme.surface;

            return DataRow(
              color: MaterialStateColor.resolveWith((states) => rowColor),
              cells: [
                DataCell(Text(group.name ?? '')),
                DataCell(Text(group.description ?? '')),
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => onEditGroup(group),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      onPressed: () => onDeleteGroup(group),
                    ),
                  ],
                )),
              ],
            );
          }),
        ),
      ),
    );
  }
}
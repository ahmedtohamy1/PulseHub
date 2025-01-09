import 'package:flutter/material.dart';
import 'package:pulsehub/features/project_dashboard/data/models/get_collaborators_response_model.dart';

class CollaboratorsTable extends StatelessWidget {
  final List<Member> members;
  final Function(Member member) onEditCollaborator;
  final Function(Member member) onDeleteCollaborator;

  const CollaboratorsTable({
    super.key,
    required this.members,
    required this.onEditCollaborator,
    required this.onDeleteCollaborator,
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
              label: Text('Full Name', style: TextStyle(color: Colors.white)),
            ),
            DataColumn(
              label: Text('Email', style: TextStyle(color: Colors.white)),
            ),
            DataColumn(
              label: Text('Title', style: TextStyle(color: Colors.white)),
            ),
            DataColumn(
              label: Text('Actions', style: TextStyle(color: Colors.white)),
            ),
          ],
          rows: List.generate(members.length, (index) {
            final member = members[index];
            final rowColor = index % 2 == 0
                ? Theme.of(context).colorScheme.secondaryContainer
                : Theme.of(context).colorScheme.surface;

            return DataRow(
              color: MaterialStateColor.resolveWith((states) => rowColor),
              cells: [
                DataCell(Text('${member.firstName ?? ''} ${member.lastName ?? ''}')),
                DataCell(Text(member.email ?? '')),
                DataCell(Text(member.title ?? '')),
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => onEditCollaborator(member),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      onPressed: () => onDeleteCollaborator(member),
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
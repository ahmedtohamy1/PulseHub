import 'package:flutter/material.dart';
import 'package:pulsehub/features/projects/data/models/project_response.dart';

class ControlScreen extends StatefulWidget {
  final Project project;
  const ControlScreen({super.key, required this.project});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 8.0),
              width: 5,
              height: 30,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8.0),
                    topLeft: Radius.circular(8.0)),
              ),
            ),
            Text(
              'Project Control Panel',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TabBar(
          labelPadding: const EdgeInsets.symmetric(horizontal: 1),
          padding: const EdgeInsets.symmetric(horizontal: 1),
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Customisation'),
            Tab(text: 'Media Library'),
            Tab(text: 'Collaborators'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              OverviewTab(
                project: widget.project,
                isEditing: _isEditing,
                onEdit: () => setState(() => _isEditing = true),
                onCancel: () => setState(() => _isEditing = false),
                onSave: () {
                  // TODO: Implement save functionality
                  setState(() => _isEditing = false);
                },
              ),
              const Center(child: Text('Customisation content coming soon')),
              const Center(child: Text('Media Library content coming soon')),
              const Center(child: Text('Collaborators content coming soon')),
            ],
          ),
        ),
      ],
    );
  }
}

class OverviewTab extends StatelessWidget {
  final Project project;
  final bool isEditing;
  final VoidCallback onEdit;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const OverviewTab({
    super.key,
    required this.project,
    required this.isEditing,
    required this.onEdit,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!isEditing)
                FilledButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                )
              else ...[
                OutlinedButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: onSave,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Changes'),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          EditableInfoRow(
            label: 'Project Title:',
            value: project.title ?? 'N/A',
            isEditing: isEditing,
          ),
          EditableInfoRow(
            label: 'Project Acronym:',
            value: project.acronym ?? 'N/A',
            isEditing: isEditing,
          ),
          EditableInfoRow(
            label: 'Start Date:',
            value: project.startDate ?? 'N/A',
            isEditing: isEditing,
          ),
          EditableInfoRow(
            label: 'Duration:',
            value: project.duration ?? 'N/A',
            isEditing: isEditing,
          ),
          EditableInfoRow(
            label: 'Time Zone:',
            value: project.timeZone ?? 'N/A',
            isEditing: isEditing,
          ),
          EditableInfoRow(
            label: 'Budget:',
            value: project.budget ?? 'N/A',
            isEditing: isEditing,
          ),
          EditableInfoRow(
            label: 'Consultant:',
            value: project.consultant ?? 'N/A',
            isEditing: isEditing,
          ),
          EditableInfoRow(
            label: 'Contractor:',
            value: project.contractor ?? 'N/A',
            isEditing: isEditing,
          ),
          EditableInfoRow(
            label: 'Construction Date:',
            value: project.constructionDate ?? 'N/A',
            isEditing: isEditing,
          ),
          EditableInfoRow(
            label: 'Age of building:',
            value: project.ageOfBuilding ?? 'N/A',
            isEditing: isEditing,
          ),
          EditableInfoRow(
            label: 'Type of building:',
            value: project.typeOfBuilding ?? 'N/A',
            isEditing: isEditing,
          ),
          EditableInfoRow(
            label: 'Size of building:',
            value: project.size ?? 'N/A',
            isEditing: isEditing,
          ),
          EditableInfoRow(
            label: 'Structure:',
            value: project.structure ?? 'N/A',
            isEditing: isEditing,
          ),
          EditableInfoRow(
            label: 'Building History:',
            value: project.buildingHistory ?? 'N/A',
            isEditing: isEditing,
          ),
          EditableInfoRow(
            label: 'Construction Characteristics:',
            value: project.constructionCharacteristics ?? 'N/A',
            isEditing: isEditing,
          ),
          EditableInfoRow(
            label: 'Plans and files:',
            value: project.plansAndFiles ?? 'N/A',
            isEditing: isEditing,
          ),
          EditableInfoRow(
            label: 'Description:',
            value: project.description ?? 'N/A',
            isEditing: isEditing,
          ),
        ],
      ),
    );
  }
}

class EditableInfoRow extends StatefulWidget {
  final String label;
  final String value;
  final bool isEditing;

  const EditableInfoRow({
    super.key,
    required this.label,
    required this.value,
    required this.isEditing,
  });

  @override
  State<EditableInfoRow> createState() => _EditableInfoRowState();
}

class _EditableInfoRowState extends State<EditableInfoRow> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(EditableInfoRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value;
    }
  }

  bool get isDateField {
    return widget.label.toLowerCase().contains('date') ||
        widget.label.toLowerCase().contains('start');
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _parseDate(_controller.text) ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      final formattedDate = "${picked.month}/${picked.day}/${picked.year}";
      setState(() {
        _controller.text = formattedDate;
      });
    }
  }

  DateTime? _parseDate(String value) {
    try {
      if (value == 'N/A') return null;

      // Try to parse MM/DD/YYYY format
      final parts = value.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]), // year
          int.parse(parts[0]), // month
          int.parse(parts[1]), // day
        );
      }

      // Fallback to DateTime.parse for ISO format
      return DateTime.parse(value);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                        controller: _controller,
                        readOnly: true,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.all(8),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () => _showDatePicker(context),
                          ),
                        ),
                      )
                    : TextFormField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.all(8),
                          border: OutlineInputBorder(),
                        ),
                      )
                : Text(_controller.text),
          ),
        ],
      ),
    );
  }
}

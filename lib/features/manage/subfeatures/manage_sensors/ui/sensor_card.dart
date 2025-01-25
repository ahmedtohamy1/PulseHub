import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_sensors/cubit/manage_sensors_cubit.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_sensors/data/models/get_all_sensor_types_response_model.dart';

class SensorCard extends StatelessWidget {
  final SensorTypeList sensorType;

  const SensorCard({
    super.key,
    required this.sensorType,
  });

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final TextEditingController confirmController = TextEditingController();
    bool isLoading = false;
    final cubit = context.read<ManageSensorsCubit>();

    await showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ManageSensorsCubit>(),
        child: StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(
              'Delete Sensor Type',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.error,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This action cannot be undone. Please type "${sensorType.name}" to confirm.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmController,
                  decoration: InputDecoration(
                    hintText: 'Type sensor name to confirm',
                    errorText: confirmController.text.isNotEmpty &&
                            confirmController.text != sensorType.name
                        ? 'Name does not match'
                        : null,
                  ),
                  onChanged: (value) => setState(() {}),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        Navigator.of(context).pop();
                      },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: isLoading
                        ? colorScheme.onSurface.withValues(alpha: 0.38)
                        : colorScheme.primary,
                  ),
                ),
              ),
              TextButton(
                onPressed: isLoading ||
                        confirmController.text != sensorType.name
                    ? null
                    : () async {
                        setState(() => isLoading = true);
                        await cubit.deleteSensorType(sensorType.sensorTypeId);

                        if (!context.mounted) return;
                        Navigator.of(context).pop();

                        // Show result in snackbar
                        final state = cubit.state;
                        if (state is DeleteSensorTypeSuccess) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Sensor type deleted successfully'),
                            ),
                          );
                        } else if (state is DeleteSensorTypeError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.error),
                              backgroundColor: colorScheme.error,
                            ),
                          );
                        }
                      },
                child: isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.error,
                        ),
                      )
                    : Text(
                        'Delete',
                        style: TextStyle(
                          color: confirmController.text == sensorType.name
                              ? colorScheme.error
                              : colorScheme.onSurface.withValues(alpha: 0.38),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEditSensorDialog(BuildContext context) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final TextEditingController nameController =
        TextEditingController(text: sensorType.name);
    final TextEditingController functionController =
        TextEditingController(text: sensorType.function);
    bool isLoading = false;
    final cubit = context.read<ManageSensorsCubit>();

    await showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ManageSensorsCubit>(),
        child: StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(
              'Edit Sensor Type',
              style: theme.textTheme.titleLarge,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.sensors),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: functionController,
                  decoration: const InputDecoration(
                    labelText: 'Function',
                    prefixIcon: Icon(Icons.functions),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        Navigator.of(context).pop();
                      },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: isLoading
                        ? colorScheme.onSurface.withValues(alpha: 0.38)
                        : colorScheme.primary,
                  ),
                ),
              ),
              FilledButton(
                onPressed: isLoading ||
                        nameController.text.isEmpty ||
                        functionController.text.isEmpty
                    ? null
                    : () async {
                        setState(() => isLoading = true);
                        await cubit.createEditSensorType(
                          nameController.text,
                          functionController.text,
                          sensorType.sensorTypeId,
                        );

                        if (!context.mounted) return;
                        Navigator.of(context).pop();

                        // Show result in snackbar
                        final state = cubit.state;
                        if (state is CreateEditSensorTypeSuccess) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Sensor type updated successfully'),
                            ),
                          );
                          // Refresh the list
                          cubit.getAllSensorTypes();
                        } else if (state is CreateEditSensorTypeError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.error),
                              backgroundColor: colorScheme.error,
                            ),
                          );
                          setState(() => isLoading = false);
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.sensors,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sensorType.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${sensorType.sensorTypeId}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  icon: Icon(
                    Icons.more_vert,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 20,
                            color: colorScheme.onSurface,
                          ),
                          const SizedBox(width: 12),
                          Text('Edit Sensor'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Delete Sensor',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showEditSensorDialog(context);
                        break;
                      case 'delete':
                        _showDeleteConfirmationDialog(context);
                        break;
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Function',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sensorType.function,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

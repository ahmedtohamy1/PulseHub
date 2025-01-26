import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';

class DeleteConfirmationDialog extends StatefulWidget {
  final String title;
  final String confirmationText;
  final String confirmButtonText;
  final Function() onConfirm;

  const DeleteConfirmationDialog({
    super.key,
    required this.title,
    required this.confirmationText,
    required this.confirmButtonText,
    required this.onConfirm,
  });

  @override
  State<DeleteConfirmationDialog> createState() =>
      _DeleteConfirmationDialogState();
}

class _DeleteConfirmationDialogState extends State<DeleteConfirmationDialog> {
  final TextEditingController confirmController = TextEditingController();
  bool isNameMatch = false;

  @override
  void dispose() {
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProjectDashboardCubit, ProjectDashboardState>(
      listenWhen: (previous, current) =>
          current is ProjectDashboardDeleteCollaboratorsSuccess ||
          current is ProjectDashboardRemoveUserFromCollaboratorsGroupSuccess,
      listener: (context, state) {
        if (state is ProjectDashboardDeleteCollaboratorsSuccess ||
            state is ProjectDashboardRemoveUserFromCollaboratorsGroupSuccess) {
          if (mounted) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        }
      },
      child: StatefulBuilder(
        builder: (context, setState) {
          return BlocBuilder<ProjectDashboardCubit, ProjectDashboardState>(
            buildWhen: (previous, current) =>
                current is ProjectDashboardDeleteCollaboratorsLoading ||
                current
                    is ProjectDashboardRemoveUserFromCollaboratorsGroupLoading,
            builder: (context, state) {
              final isLoading = state
                      is ProjectDashboardDeleteCollaboratorsLoading ||
                  state
                      is ProjectDashboardRemoveUserFromCollaboratorsGroupLoading;

              return AlertDialog(
                title: Text(widget.title),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.confirmationText),
                    const SizedBox(height: 16),
                    const Text(
                      'Please type the name to confirm:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: confirmController,
                      autofocus: true,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText: 'Enter name',
                        border: const OutlineInputBorder(),
                        errorText:
                            confirmController.text.isNotEmpty && !isNameMatch
                                ? 'Name does not match'
                                : null,
                      ),
                      onChanged: (value) {
                        setState(() {
                          isNameMatch = value == widget.confirmationText;
                        });
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed:
                        isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  if (isLoading)
                    const SizedBox(
                      width: 80,
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  else
                    FilledButton(
                      onPressed: isNameMatch ? widget.onConfirm : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        disabledBackgroundColor: Theme.of(context)
                            .colorScheme
                            .error
                            .withValues(alpha: 0.3),
                      ),
                      child: Text(widget.confirmButtonText),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

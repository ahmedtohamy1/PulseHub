import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/core/di/service_locator.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_owners/cubit/manage_owners_cubit.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_owners/ui/edit_owner_screen.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_projects/data/models/owner_model.dart';

class OwnerCard extends StatelessWidget {
  final OwnerModel owner;

  const OwnerCard({
    super.key,
    required this.owner,
  });

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    final TextEditingController controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final cubit = context.read<ManageOwnersCubit>();

    return showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: BlocConsumer<ManageOwnersCubit, ManageOwnersState>(
          listenWhen: (previous, current) =>
              current is DeleteOwnerSuccess ||
              (current is DeleteOwnerFailure &&
                  previous is DeleteOwnerLoading &&
                  (previous).ownerId == owner.ownerId),
          listener: (context, state) {
            if (state is DeleteOwnerSuccess) {
              Navigator.of(context).pop(); // Close the dialog
              cubit.getAllOwners(); // Refresh the owners list
            }
          },
          buildWhen: (previous, current) =>
              current is DeleteOwnerLoading &&
                  current.ownerId == owner.ownerId ||
              current is DeleteOwnerSuccess ||
              current is DeleteOwnerFailure,
          builder: (context, state) {
            return AlertDialog(
              title: const Text('Delete Owner'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state is DeleteOwnerFailure)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          state.error,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    const Text(
                      'This action cannot be undone. Please type the owner name to confirm deletion:',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      owner.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'Type owner name here',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value != owner.name) {
                          return 'Owner name does not match';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: state is DeleteOwnerLoading
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: state is DeleteOwnerLoading
                      ? null
                      : () {
                          if (formKey.currentState?.validate() ?? false) {
                            context
                                .read<ManageOwnersCubit>()
                                .deleteOwner(owner.ownerId);
                          }
                        },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: state is DeleteOwnerLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Delete'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocConsumer<ManageOwnersCubit, ManageOwnersState>(
      listenWhen: (previous, current) =>
          (current is DeleteOwnerSuccess &&
              previous is DeleteOwnerLoading &&
              (previous).ownerId == owner.ownerId) ||
          (current is UpdateOwnerSuccess),
      listener: (context, state) async {
        if (state is DeleteOwnerSuccess || state is UpdateOwnerSuccess) {
          // Refresh owners list after a short delay
          await Future.delayed(const Duration(milliseconds: 100));
          if (context.mounted) {
            context.read<ManageOwnersCubit>().getAllOwners();
          }
        }
      },
      buildWhen: (previous, current) =>
          (current is DeleteOwnerLoading && current.ownerId == owner.ownerId) ||
          (current is DeleteOwnerSuccess &&
              previous is DeleteOwnerLoading &&
              (previous).ownerId == owner.ownerId),
      builder: (context, state) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  // Owner Logo Banner
                  SizedBox(
                    width: double.infinity,
                    height: 200,
                    child: owner.logoUrl.isNotEmpty
                        ? Image.network(
                            owner.logoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: colorScheme.primary.withOpacity(0.1),
                              child: Center(
                                child: Icon(
                                  Icons.business,
                                  size: 64,
                                  color: colorScheme.primary.withOpacity(0.5),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: colorScheme.primary.withOpacity(0.1),
                            child: Center(
                              child: Icon(
                                Icons.business,
                                size: 64,
                                color: colorScheme.primary.withOpacity(0.5),
                              ),
                            ),
                          ),
                  ),
                  // Gradient Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.black.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Action Buttons
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Row(
                      children: [
                        // Edit Button
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider(
                                    create: (context) =>
                                        sl<ManageOwnersCubit>(),
                                    child: EditOwnerScreen(owner: owner),
                                  ),
                                ),
                              ),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.edit_outlined,
                                  color: colorScheme.onPrimary,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Delete Button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.red.shade600,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: state is DeleteOwnerLoading
                                  ? null
                                  : () =>
                                      _showDeleteConfirmationDialog(context),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: state is DeleteOwnerLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.delete_outline,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Owner Name
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Text(
                      owner.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              // Owner Details
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      'Address',
                      owner.addresse ?? 'N/A',
                      Icons.location_on_outlined,
                      context: context,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      'Country',
                      owner.country ?? 'N/A',
                      Icons.public,
                      context: context,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      'Phone',
                      owner.phone ?? 'N/A',
                      Icons.phone_outlined,
                      context: context,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      'Website',
                      owner.website ?? 'N/A',
                      Icons.language_outlined,
                      context: context,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

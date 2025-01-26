import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_projects/cubit/manage_projects_cubit.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_projects/data/models/owner_model.dart'
    as owner_model;
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({super.key});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _imagePicker = ImagePicker();
  File? _selectedImage;
  owner_model.Owner? _selectedOwner;

  // Add Owner Form Controllers
  final _ownerNameController = TextEditingController();
  final _ownerPhoneController = TextEditingController();
  final _ownerAddressController = TextEditingController();
  final _ownerCountryController = TextEditingController();
  final _ownerWebsiteController = TextEditingController();
  XFile? _ownerLogo;

  // Project Form Controllers
  final titleController = TextEditingController();
  final acronymController = TextEditingController();
  final startDateController = TextEditingController();
  final durationController = TextEditingController();
  final budgetController = TextEditingController();
  final consultantController = TextEditingController();
  final contractorController = TextEditingController();
  final descriptionController = TextEditingController();
  final typeOfBuildingController = TextEditingController();
  final sizeController = TextEditingController();
  final ageOfBuildingController = TextEditingController();
  final surroundingEnvironmentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load owners when screen opens
    context.read<ManageProjectsCubit>().getAllOwners();
  }

  @override
  void dispose() {
    _ownerNameController.dispose();
    _ownerPhoneController.dispose();
    _ownerAddressController.dispose();
    _ownerCountryController.dispose();
    _ownerWebsiteController.dispose();
    titleController.dispose();
    acronymController.dispose();
    startDateController.dispose();
    durationController.dispose();
    budgetController.dispose();
    consultantController.dispose();
    contractorController.dispose();
    descriptionController.dispose();
    typeOfBuildingController.dispose();
    sizeController.dispose();
    ageOfBuildingController.dispose();
    surroundingEnvironmentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null && mounted) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting image: ${e.toString()}')),
        );
      }
    }
  }

  InputDecoration _getInputDecoration(BuildContext context,
      {Widget? suffixIcon}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: theme.dividerColor,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: theme.dividerColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: colorScheme.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: colorScheme.error,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: colorScheme.error,
          width: 2,
        ),
      ),
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
      isDense: true,
      suffixIcon: suffixIcon,
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool isRequired = false,
    TextInputType? keyboardType,
    int? maxLines,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines ?? 1,
          validator: validator,
          decoration: _getInputDecoration(context),
        ),
      ],
    );
  }

  void _showAddOwnerSheet() {
    // Store cubit instance
    final cubit = context.read<ManageProjectsCubit>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final parentContext = context;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (context) {
        return [
          WoltModalSheetPage(
            hasSabGradient: false,
            topBarTitle: Text(
              'Add New Owner',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            isTopBarLayerAlwaysVisible: true,
            child: BlocProvider.value(
              value: cubit,
              child: Builder(
                builder: (context) =>
                    BlocListener<ManageProjectsCubit, ManageProjectsState>(
                  listener: (context, state) {
                    if (state is CreateOwnerSuccess) {
                      // Clear form fields
                      _ownerNameController.clear();
                      _ownerPhoneController.clear();
                      _ownerAddressController.clear();
                      _ownerCountryController.clear();
                      _ownerWebsiteController.clear();
                      _ownerLogo = null;

                      // Close sheet first
                      Navigator.pop(context);

                      // Show success message in parent context after a short delay
                      Future.microtask(() {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: const Text('Owner created successfully'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      });

                      // Refresh owners list in parent context
                      Future.microtask(() {
                        if (parentContext.mounted) {
                          cubit.getAllOwners();
                        }
                      });
                    } else if (state is CreateOwnerFailure) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content:
                              Text('Failed to create owner: ${state.error}'),
                          backgroundColor: colorScheme.error,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Owner Logo
                            Text(
                              'Owner Logo',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            StatefulBuilder(
                              builder: (context, setSheetState) =>
                                  GestureDetector(
                                onTap: () async {
                                  try {
                                    final XFile? image =
                                        await _imagePicker.pickImage(
                                      source: ImageSource.gallery,
                                      imageQuality: 80,
                                    );
                                    if (image != null && mounted) {
                                      setSheetState(() {
                                        _ownerLogo = image;
                                      });
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text('Error selecting image: $e'),
                                          backgroundColor: colorScheme.error,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: colorScheme.outline,
                                      width: 1,
                                    ),
                                  ),
                                  child: _ownerLogo != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.file(
                                            File(_ownerLogo!.path),
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons
                                                  .add_photo_alternate_outlined,
                                              size: 32,
                                              color: colorScheme.primary,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Add Logo',
                                              style: theme.textTheme.labelMedium
                                                  ?.copyWith(
                                                color: colorScheme.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Owner Details Form
                            _buildTextField(
                              label: 'Name',
                              controller: _ownerNameController,
                              isRequired: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Name is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'Phone',
                              controller: _ownerPhoneController,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'Address',
                              controller: _ownerAddressController,
                              maxLines: 2,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'Country',
                              controller: _ownerCountryController,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'Website',
                              controller: _ownerWebsiteController,
                              keyboardType: TextInputType.url,
                            ),
                            const SizedBox(height: 24),

                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () {
                                  if (_ownerNameController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                            'Please enter owner name'),
                                        backgroundColor: colorScheme.error,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                    return;
                                  }

                                  cubit.createOwner(
                                    _ownerNameController.text,
                                    _ownerPhoneController.text,
                                    _ownerAddressController.text,
                                    null, // city is no longer used
                                    _ownerCountryController.text,
                                    _ownerLogo,
                                  );
                                },
                                style: FilledButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Create Owner'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      BlocBuilder<ManageProjectsCubit, ManageProjectsState>(
                        builder: (context, state) {
                          if (state is CreateOwnerLoading) {
                            return Container(
                              color: Colors.black26,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ];
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Project',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Image
            Text(
              'Project Image',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline,
                    width: 1,
                  ),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 48,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Add Project Image',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Basic Information Section
            Text(
              'Basic Information',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Title',
              controller: titleController,
              isRequired: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Acronym',
              controller: acronymController,
              isRequired: true,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Start Date',
                    controller: startDateController,
                    isRequired: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    label: 'Duration',
                    controller: durationController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Budget',
              controller: budgetController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // Project Details Section
            Text(
              'Project Details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Consultant',
                    controller: consultantController,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    label: 'Contractor',
                    controller: contractorController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Description',
              controller: descriptionController,
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Building Information Section
            Text(
              'Building Information',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Type of Building',
              controller: typeOfBuildingController,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Size',
                    controller: sizeController,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    label: 'Age of Building',
                    controller: ageOfBuildingController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Surrounding Environment',
              controller: surroundingEnvironmentController,
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Owner Selection Section
            Text(
              'Project Owner',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            BlocBuilder<ManageProjectsCubit, ManageProjectsState>(
              builder: (context, state) {
                if (state is GetAllOwnersLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is GetAllOwnersSuccess) {
                  final allOwners =
                      state.owners.expand((model) => model.results).toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest
                              .withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.dividerColor,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<owner_model.Owner>(
                            isExpanded: true,
                            value: _selectedOwner,
                            hint: const Text('Select Owner'),
                            items: allOwners.map((owner) {
                              return DropdownMenuItem<owner_model.Owner>(
                                value: owner,
                                child: Text(owner.name),
                              );
                            }).toList(),
                            onChanged: (owner_model.Owner? value) {
                              setState(() {
                                _selectedOwner = value;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton.icon(
                          onPressed: _showAddOwnerSheet,
                          icon: const Icon(Icons.add),
                          label: const Text('Add New Owner'),
                        ),
                      ),
                    ],
                  );
                } else if (state is GetAllOwnersFailure) {
                  return Column(
                    children: [
                      Text(
                        'Failed to load owners: ${state.error}',
                        style: TextStyle(color: colorScheme.error),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () =>
                            context.read<ManageProjectsCubit>().getAllOwners(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  // TODO: Implement project creation
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Create Project'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

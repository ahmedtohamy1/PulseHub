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
  owner_model.OwnerModel? _selectedOwner;

  // Add Owner Form Controllers
  final _ownerNameController = TextEditingController();
  final _ownerPhoneController = TextEditingController();
  final _ownerAddressController = TextEditingController();
  final _ownerCityController = TextEditingController();
  final _ownerCountryController = TextEditingController();
  XFile? _ownerLogo;

  final titleController = TextEditingController();
  final acronymController = TextEditingController();
  final startDateController = TextEditingController();
  final durationController = TextEditingController();
  final consultantController = TextEditingController();
  final contractorController = TextEditingController();
  final constructionDateController = TextEditingController();

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
    _ownerCityController.dispose();
    _ownerCountryController.dispose();
    titleController.dispose();
    acronymController.dispose();
    startDateController.dispose();
    durationController.dispose();
    consultantController.dispose();
    contractorController.dispose();
    constructionDateController.dispose();
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
          print('DEBUG: Image selected successfully - Path: ${image.path}');
        });
      }
    } catch (e) {
      print('DEBUG: Error selecting image - $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting image: ${e.toString()}')),
        );
      }
    }
  }

  InputDecoration _getInputDecoration(BuildContext context,
      {Widget? suffixIcon}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(
          color: Theme.of(context).dividerColor,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(
          color: Theme.of(context).dividerColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      isDense: true,
      suffixIcon: suffixIcon,
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool isRequired = false,
    TextInputType? keyboardType,
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
          decoration: _getInputDecoration(context),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (date != null) {
              controller.text = date.toIso8601String().split('T')[0];
            }
          },
          decoration: _getInputDecoration(
            context,
            suffixIcon: const Icon(Icons.calendar_today),
          ),
        ),
      ],
    );
  }

  void _showAddOwnerSheet() {
    // Store cubit instance
    final cubit = context.read<ManageProjectsCubit>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final parentContext = context;

    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (context) {
        return [
          WoltModalSheetPage(
            hasSabGradient: false,
            topBarTitle: const Text('Add New Owner'),
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
                      _ownerCityController.clear();
                      _ownerCountryController.clear();
                      _ownerLogo = null;

                      // Close sheet first
                      Navigator.pop(context);

                      // Show success message in parent context after a short delay
                      Future.microtask(() {
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text('Owner created successfully'),
                            backgroundColor: Colors.green,
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
                              Text('Failed to create owner: ${state.message}'),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                    }
                  },
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Owner Logo
                            Text(
                              'Owner Logo',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
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
                                        print(
                                            'DEBUG: Owner logo selected - Path: ${image.path}');
                                      });
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Error selecting image: $e')),
                                      );
                                    }
                                  }
                                },
                                child: Container(
                                  height: 120,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                  child: _ownerLogo != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.file(
                                            File(_ownerLogo!.path),
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              print(
                                                  'DEBUG: Error loading owner logo - $error');
                                              return Center(
                                                child: Icon(
                                                  Icons.error_outline,
                                                  size: 48,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .error,
                                                ),
                                              );
                                            },
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
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Add Logo',
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Owner Name
                            _buildTextField(
                              label: 'Name',
                              controller: _ownerNameController,
                              isRequired: true,
                            ),
                            const SizedBox(height: 16),

                            // Owner Phone
                            _buildTextField(
                              label: 'Phone',
                              controller: _ownerPhoneController,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16),

                            // Owner Address
                            _buildTextField(
                              label: 'Address',
                              controller: _ownerAddressController,
                            ),
                            const SizedBox(height: 16),

                            // Owner City
                            _buildTextField(
                              label: 'City',
                              controller: _ownerCityController,
                            ),
                            const SizedBox(height: 16),

                            // Owner Country
                            _buildTextField(
                              label: 'Country',
                              controller: _ownerCountryController,
                            ),
                            const SizedBox(height: 24),

                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              child: BlocBuilder<ManageProjectsCubit,
                                  ManageProjectsState>(
                                builder: (context, state) {
                                  final isLoading = state is CreateOwnerLoading;
                                  return isLoading
                                      ? Text('Loading...')
                                      : FilledButton(
                                          onPressed: isLoading
                                              ? null
                                              : () async {
                                                  if (_ownerNameController.text
                                                      .trim()
                                                      .isEmpty) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'Please enter owner name'),
                                                      ),
                                                    );
                                                    return;
                                                  }

                                                  // Create owner
                                                  await context
                                                      .read<
                                                          ManageProjectsCubit>()
                                                      .createOwner(
                                                        _ownerNameController
                                                            .text
                                                            .trim(),
                                                        _ownerPhoneController
                                                            .text
                                                            .trim(),
                                                        _ownerAddressController
                                                            .text
                                                            .trim(),
                                                        _ownerCityController
                                                            .text
                                                            .trim(),
                                                        _ownerCountryController
                                                            .text
                                                            .trim(),
                                                        _ownerLogo,
                                                      );
                                                },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                            child: const Text('Create Owner'),
                                          ),
                                        );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Loading Overlay
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Project'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              if (_selectedOwner != null) {
                print(
                    'DEBUG: Creating project with owner: ${_selectedOwner!.name}');
                // TODO: Implement project creation
                Navigator.pop(context);
              } else {
                print('DEBUG: Cannot create project - No owner selected');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select an owner')),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Picker
            Text(
              'Project Picture',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.5),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _selectedImage != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print('DEBUG: Error loading image - $error');
                                return Center(
                                  child: Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                );
                              },
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surface
                                      .withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  onPressed: _pickImage,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 48,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add Project Picture',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap to select',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Form Fields
            _buildTextField(
              label: 'Title',
              controller: titleController,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Acronym',
              controller: acronymController,
            ),
            const SizedBox(height: 16),

            // Owner Section
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Owner',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      BlocBuilder<ManageProjectsCubit, ManageProjectsState>(
                        builder: (context, state) {
                          return switch (state) {
                            GetAllOwnersSuccess(owners: final owners) =>
                              DropdownButtonFormField<String>(
                                value: _selectedOwner?.name,
                                decoration: _getInputDecoration(context),
                                items: owners.map((owner) {
                                  return DropdownMenuItem<String>(
                                    value: owner.name,
                                    child: Text(owner.name),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  if (value != null) {
                                    final selectedOwner = owners.firstWhere(
                                      (owner) => owner.name == value,
                                      orElse: () => owners.first,
                                    );
                                    setState(() {
                                      _selectedOwner = selectedOwner;
                                    });
                                  }
                                },
                                hint: const Text('Select Owner'),
                                isExpanded: true,
                              ),
                            GetAllOwnersLoading() =>
                              DropdownButtonFormField<String>(
                                value: null,
                                decoration: _getInputDecoration(
                                  context,
                                  suffixIcon: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ),
                                ),
                                items: const [],
                                onChanged: null,
                                hint: const Text('Loading owners...'),
                                isExpanded: true,
                              ),
                            GetAllOwnersFailure(message: final message) =>
                              DropdownButtonFormField<String>(
                                value: null,
                                decoration: _getInputDecoration(
                                  context,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      Icons.refresh,
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                                    onPressed: () {
                                      context
                                          .read<ManageProjectsCubit>()
                                          .getAllOwners();
                                    },
                                  ),
                                ).copyWith(
                                  helperText: 'Error: $message',
                                  helperStyle: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    borderSide: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    borderSide: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    borderSide: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                                  ),
                                ),
                                items: const [],
                                onChanged: null,
                                hint: Text(
                                  'Failed to load owners',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                                isExpanded: true,
                              ),
                            _ => const SizedBox(),
                          };
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: TextButton.icon(
                    onPressed: _showAddOwnerSheet,
                    icon: const Icon(
                      Icons.add,
                    ),
                    label: const Text('Add Owner'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Date Fields
            _buildDateField(
              context: context,
              label: 'Start Date',
              controller: startDateController,
            ),
            const SizedBox(height: 16),
            _buildDateField(
              context: context,
              label: 'Construction Date',
              controller: constructionDateController,
            ),
            const SizedBox(height: 16),

            // Duration Field
            Text(
              'Duration (months)',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: durationController,
              keyboardType: TextInputType.number,
              decoration: _getInputDecoration(context),
            ),
            const SizedBox(height: 16),

            // Regular Text Fields
            _buildTextField(
              label: 'Consultant',
              controller: consultantController,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Contractor',
              controller: contractorController,
            ),
          ],
        ),
      ),
    );
  }
}

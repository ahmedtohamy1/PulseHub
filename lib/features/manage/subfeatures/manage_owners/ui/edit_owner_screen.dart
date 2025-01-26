import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_owners/cubit/manage_owners_cubit.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_projects/data/models/owner_model.dart';

class EditOwnerScreen extends StatefulWidget {
  final Owner owner;

  const EditOwnerScreen({
    super.key,
    required this.owner,
  });

  @override
  State<EditOwnerScreen> createState() => _EditOwnerScreenState();
}

class _EditOwnerScreenState extends State<EditOwnerScreen> {
  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController addressController;
  late final TextEditingController countryController;
  late final TextEditingController websiteController;
  final imagePicker = ImagePicker();
  XFile? newLogo;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.owner.name);
    phoneController = TextEditingController(text: widget.owner.phone);
    addressController = TextEditingController(text: widget.owner.addresse);
    countryController = TextEditingController(text: widget.owner.country);
    websiteController = TextEditingController(text: widget.owner.website);
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    countryController.dispose();
    websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<ManageOwnersCubit, ManageOwnersState>(
      listenWhen: (previous, current) =>
          (current is UpdateOwnerSuccess) ||
          (current is UpdateOwnerFailure &&
              previous is UpdateOwnerLoading &&
              (previous).ownerId == widget.owner.ownerId),
      listener: (context, state) async {
        if (state is UpdateOwnerSuccess) {
          // Show success message
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Owner updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }

          // Refresh owners list and pop
          if (context.mounted) {
            context.read<ManageOwnersCubit>().getAllOwners();
            Navigator.pop(context);
          }
        } else if (state is UpdateOwnerFailure) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to update owner: ${state.error}'),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Owner'),
          actions: [
            BlocBuilder<ManageOwnersCubit, ManageOwnersState>(
              buildWhen: (previous, current) =>
                  (current is UpdateOwnerLoading &&
                      current.ownerId == widget.owner.ownerId) ||
                  (current is UpdateOwnerSuccess &&
                      previous is UpdateOwnerLoading &&
                      (previous).ownerId == widget.owner.ownerId),
              builder: (context, state) {
                final isLoading = state is UpdateOwnerLoading &&
                    state.ownerId == widget.owner.ownerId;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: FilledButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (nameController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter owner name'),
                                ),
                              );
                              return;
                            }

                            await context.read<ManageOwnersCubit>().updateOwner(
                                  widget.owner.ownerId,
                                  nameController.text.trim(),
                                  phoneController.text.trim(),
                                  addressController.text.trim(),
                                  countryController.text.trim(),
                                  newLogo,
                                  websiteController.text.trim(),
                                );
                          },
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Save'),
                  ),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
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
              GestureDetector(
                onTap: () async {
                  try {
                    final XFile? image = await imagePicker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                    );
                    if (image != null && mounted) {
                      setState(() {
                        newLogo = image;
                      });
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error selecting image: $e'),
                        ),
                      );
                    }
                  }
                },
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.5),
                    ),
                  ),
                  child: newLogo != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(newLogo!.path),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: colorScheme.error,
                                ),
                              );
                            },
                          ),
                        )
                      : widget.owner.logoUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                widget.owner.logoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildDefaultLogo(context),
                              ),
                            )
                          : _buildDefaultLogo(context),
                ),
              ),
              const SizedBox(height: 24),

              // Owner Name
              _buildTextField(
                context: context,
                label: 'Name',
                controller: nameController,
                isRequired: true,
              ),
              const SizedBox(height: 16),

              // Owner Phone
              _buildTextField(
                context: context,
                label: 'Phone',
                controller: phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Owner Address
              _buildTextField(
                context: context,
                label: 'Address',
                controller: addressController,
              ),
              const SizedBox(height: 16),

              // Owner Country
              _buildTextField(
                context: context,
                label: 'Country',
                controller: countryController,
              ),
              const SizedBox(height: 16),

              // Owner Website
              _buildTextField(
                context: context,
                label: 'Website',
                controller: websiteController,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultLogo(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 32,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 8),
        Text(
          'Change Logo',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool isRequired = false,
    TextInputType? keyboardType,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label${isRequired ? ' *' : ''}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
          ),
        ),
      ],
    );
  }
}

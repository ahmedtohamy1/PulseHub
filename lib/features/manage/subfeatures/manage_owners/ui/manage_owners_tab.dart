import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_owners/cubit/manage_owners_cubit.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_owners/ui/owner_card.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class ManageOwnersTab extends StatefulWidget {
  const ManageOwnersTab({super.key});

  @override
  State<ManageOwnersTab> createState() => _ManageOwnersTabState();
}

class _ManageOwnersTabState extends State<ManageOwnersTab> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _ownerPhoneController = TextEditingController();
  final TextEditingController _ownerAddressController = TextEditingController();
  final TextEditingController _ownerCityController = TextEditingController();
  final TextEditingController _ownerCountryController = TextEditingController();
  final _imagePicker = ImagePicker();
  XFile? _ownerLogo;
  bool _showSearch = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _ownerNameController.dispose();
    _ownerPhoneController.dispose();
    _ownerAddressController.dispose();
    _ownerCityController.dispose();
    _ownerCountryController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      if (!_showSearch) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  void _showAddOwnerSheet(BuildContext context) {
    // Store cubit instance
    final cubit = context.read<ManageOwnersCubit>();
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
                    BlocListener<ManageOwnersCubit, ManageOwnersState>(
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
                              Text('Failed to create owner: ${state.error}'),
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
                                      });
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text('Error selecting image: $e'),
                                        ),
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
                              child: BlocBuilder<ManageOwnersCubit,
                                  ManageOwnersState>(
                                builder: (context, state) {
                                  final isLoading = state is CreateOwnerLoading;
                                  return FilledButton(
                                    onPressed: isLoading
                                        ? null
                                        : () async {
                                            if (_ownerNameController.text
                                                .trim()
                                                .isEmpty) {
                                              ScaffoldMessenger.of(context)
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
                                                .read<ManageOwnersCubit>()
                                                .createOwner(
                                                  _ownerNameController.text
                                                      .trim(),
                                                  _ownerPhoneController.text
                                                      .trim(),
                                                  _ownerAddressController.text
                                                      .trim(),
                                                  _ownerCityController.text
                                                      .trim(),
                                                  _ownerCountryController.text
                                                      .trim(),
                                                  _ownerLogo,
                                                );
                                          },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      child: isLoading
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                            )
                                          : const Text('Create Owner'),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Loading Overlay
                      BlocBuilder<ManageOwnersCubit, ManageOwnersState>(
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool isRequired = false,
    TextInputType? keyboardType,
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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
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
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Scaffold(
          body: BlocBuilder<ManageOwnersCubit, ManageOwnersState>(
            builder: (context, state) {
              final colorScheme = Theme.of(context).colorScheme;

              return Stack(
                children: [
                  // Main List with gesture detector to close search
                  GestureDetector(
                    onTap: _showSearch ? _toggleSearch : null,
                    behavior: HitTestBehavior.translucent,
                    child: BlocBuilder<ManageOwnersCubit, ManageOwnersState>(
                      builder: (context, state) {
                        if (state is GetAllOwnersLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (state is GetAllOwnersFailure) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Failed to load owners',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  state.error,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                ),
                                const SizedBox(height: 16),
                                FilledButton.icon(
                                  onPressed: () {
                                    context
                                        .read<ManageOwnersCubit>()
                                        .getAllOwners();
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Retry'),
                                ),
                              ],
                            ),
                          );
                        }

                        if (state is GetAllOwnersSuccess) {
                          if (state.owners.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'No owners found',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Add your first owner to get started',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 16),
                                  FilledButton.icon(
                                    onPressed: () {
                                      // TODO: Navigate to add owner screen
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Owner'),
                                  ),
                                ],
                              ),
                            );
                          }

                          final filteredOwners = _searchQuery.isEmpty
                              ? state.owners
                              : state.owners
                                  .where((owner) => owner.name
                                      .toLowerCase()
                                      .contains(_searchQuery.toLowerCase()))
                                  .toList();

                          if (filteredOwners.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'No owners found',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Try a different search term',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              top: 16,
                              bottom: 80,
                            ),
                            itemCount: filteredOwners.length,
                            itemBuilder: (context, index) {
                              final owner = filteredOwners[index];
                              return OwnerCard(owner: owner);
                            },
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ),

                  // Search TextField
                  if (_showSearch)
                    Positioned(
                      right: 16,
                      bottom: 80,
                      child: Container(
                        width: 250,
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.shadow.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search owners...',
                            prefixIcon: Icon(
                              Icons.search,
                              color: colorScheme.primary,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorScheme.outline,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorScheme.outline.withOpacity(0.5),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorScheme.primary,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // FABs
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_showSearch)
                          FloatingActionButton(
                            heroTag: 'searchFab',
                            onPressed: _toggleSearch,
                            child: Icon(
                              Icons.close,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          )
                        else ...[
                          FloatingActionButton(
                            heroTag: 'addFab',
                            onPressed: () => _showAddOwnerSheet(context),
                            child: Icon(
                              Icons.add,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FloatingActionButton(
                            heroTag: 'searchFab',
                            onPressed: _toggleSearch,
                            child: Icon(
                              Icons.search,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

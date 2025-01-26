import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/core/di/service_locator.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_owners/cubit/manage_owners_cubit.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_owners/ui/add_owner_screen.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_owners/ui/owner_card.dart';

class ManageOwnersTab extends StatefulWidget {
  const ManageOwnersTab({super.key});

  @override
  State<ManageOwnersTab> createState() => _ManageOwnersTabState();
}

class _ManageOwnersTabState extends State<ManageOwnersTab> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;
  String _searchQuery = '';
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _searchQuery = value;
        });
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManageOwnersCubit, ManageOwnersState>(
      builder: (context, state) {
        final colorScheme = Theme.of(context).colorScheme;

        return Stack(
          children: [
            // Main List
            GestureDetector(
              onTap: _showSearch ? _toggleSearch : null,
              behavior: HitTestBehavior.translucent,
              child: _buildOwnerList(context, state),
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
                        color: colorScheme.shadow.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    onChanged: _onSearchChanged,
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
                                if (mounted) {
                                  setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  });
                                }
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
                          color: colorScheme.outline.withValues(alpha: 0.5),
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
                      key: const ValueKey('closeFab'),
                      onPressed: _toggleSearch,
                      child: Icon(
                        Icons.close,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    )
                  else ...[
                    FloatingActionButton(
                      key: const ValueKey('addFab'),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BlocProvider(
                            create: (context) => sl<ManageOwnersCubit>(),
                            child: const AddOwnerScreen(),
                          ),
                        ),
                      ),
                      child: Icon(
                        Icons.add,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FloatingActionButton(
                      key: const ValueKey('searchFab'),
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
    );
  }

  Widget _buildOwnerList(BuildContext context, ManageOwnersState state) {
    if (state is GetAllOwnersLoading) {
      return const Center(child: CircularProgressIndicator());
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                context.read<ManageOwnersCubit>().getAllOwners();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is GetAllOwnersSuccess) {
      final owners = state.owners;
      if (owners.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'No owners found',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Add your first owner to get started',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => sl<ManageOwnersCubit>(),
                      child: const AddOwnerScreen(),
                    ),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Add Owner'),
              ),
            ],
          ),
        );
      }

      final filteredOwners = _searchQuery.isEmpty
          ? owners
          : owners
              .where((owner) =>
                  owner.name.toLowerCase().contains(_searchQuery.toLowerCase()))
              .toList();

      if (filteredOwners.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'No owners found',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Try a different search term',
                style: Theme.of(context).textTheme.bodyMedium,
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
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/core/di/service_locator.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_users/cubit/manage_users_cubit.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_users/ui/screens/create_user_screen.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_users/ui/user_card.dart';

class ManageUsersTab extends StatefulWidget {
  const ManageUsersTab({super.key});

  @override
  State<ManageUsersTab> createState() => _ManageUsersTabState();
}

class _ManageUsersTabState extends State<ManageUsersTab>
    with AutomaticKeepAliveClientMixin {
  late final ManageUsersCubit _cubit;
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _cubit = sl<ManageUsersCubit>();
    _cubit.getAllUsers();
  }

  @override
  void dispose() {
    _cubit.close();
    _searchController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

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
    super.build(context);
    final colorScheme = Theme.of(context).colorScheme;

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        body: Stack(
          children: [
            // Main List
            GestureDetector(
              onTap: _showSearch ? _toggleSearch : null,
              behavior: HitTestBehavior.translucent,
              child: BlocBuilder<ManageUsersCubit, ManageUsersState>(
                builder: (context, state) {
                  if (state is ManageUsersLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ManageUsersFailure) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Failed to load users',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.error,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () {
                              context.read<ManageUsersCubit>().getAllUsers();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is ManageUsersSuccess) {
                    if (state.response.users?.isEmpty ?? true) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'No users found',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No users have been added yet',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      );
                    }

                    final filteredUsers = _searchQuery.isEmpty
                        ? state.response.users!
                        : state.response.users!
                            .where((user) =>
                                (user.firstName ?? '')
                                    .toLowerCase()
                                    .contains(_searchQuery.toLowerCase()) ||
                                (user.lastName ?? '')
                                    .toLowerCase()
                                    .contains(_searchQuery.toLowerCase()) ||
                                (user.email ?? '')
                                    .toLowerCase()
                                    .contains(_searchQuery.toLowerCase()))
                            .toList();

                    return ListView.builder(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                        bottom: 80, // Extra padding for FAB
                      ),
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        return UserCard(user: user);
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
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search users...',
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

            // FAB
            Positioned(
              right: 16,
              bottom: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_showSearch)
                    FloatingActionButton(
                      heroTag: 'manage_users_search_close_fab',
                      onPressed: _toggleSearch,
                      child: Icon(
                        Icons.close,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    )
                  else ...[
                    FloatingActionButton(
                      heroTag: 'manage_users_add_fab',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BlocProvider.value(
                              value: _cubit,
                              child: const CreateUserScreen(),
                            ),
                          ),
                        );
                      },
                      child: Icon(
                        Icons.add,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FloatingActionButton(
                      heroTag: 'manage_users_search_fab',
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
        ),
      ),
    );
  }
}

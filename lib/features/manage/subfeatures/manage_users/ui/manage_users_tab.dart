import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/core/di/service_locator.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_users/cubit/manage_users_cubit.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_users/ui/screens/create_user_screen.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_users/ui/user_card.dart';

class ManageUsersTab extends StatefulWidget {
  final bool? isDic;
  const ManageUsersTab({super.key, this.isDic});

  @override
  State<ManageUsersTab> createState() => _ManageUsersTabState();
}

class _ManageUsersTabState extends State<ManageUsersTab>
    with AutomaticKeepAliveClientMixin {
  late final ManageUsersCubit _cubit;
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;
  bool _showFilters = true;
  String _searchQuery = '';
  String? _selectedRole;
  bool? _selectedActiveStatus;

  @override
  void initState() {
    super.initState();
    _cubit = sl<ManageUsersCubit>();
    _cubit.getAllUsers();
  }

  @override
  void dispose() {
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
                    if (state.response.users == null ||
                        state.response.users!.isEmpty) {
                      return const Center(
                        child: Text('No users found'),
                      );
                    }

                    final filteredUsers = state.response.users!.where((user) {
                      bool matchesSearch = _searchQuery.isEmpty ||
                          (user.firstName ?? '')
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()) ||
                          (user.lastName ?? '')
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()) ||
                          (user.email ?? '')
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase());

                      bool matchesRole = _selectedRole == null ||
                          (_selectedRole == 'admin' &&
                              user.isSuperuser == true) ||
                          (_selectedRole == 'staff' &&
                              user.isStaff == true &&
                              user.isSuperuser != true) ||
                          (_selectedRole == 'user' &&
                              user.isStaff != true &&
                              user.isSuperuser != true);

                      bool matchesActiveStatus =
                          _selectedActiveStatus == null ||
                              user.isActive == _selectedActiveStatus;

                      return matchesSearch &&
                          matchesRole &&
                          matchesActiveStatus;
                    }).toList();

                    return Column(
                      children: [
                        // Filters
                        if (_showFilters)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                // Role Filter
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedRole,
                                    decoration: InputDecoration(
                                      labelText: 'Role',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                    ),
                                    items: [
                                      DropdownMenuItem(
                                        value: null,
                                        child: Text(
                                          'All Roles',
                                          style: TextStyle(
                                            color: colorScheme.onSurface
                                                .withValues(alpha: 0.7),
                                          ),
                                        ),
                                      ),
                                      const DropdownMenuItem(
                                        value: 'admin',
                                        child: Text('Admin'),
                                      ),
                                      const DropdownMenuItem(
                                        value: 'staff',
                                        child: Text('Staff'),
                                      ),
                                      const DropdownMenuItem(
                                        value: 'user',
                                        child: Text('User'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedRole = value;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Active Status Filter
                                Expanded(
                                  child: DropdownButtonFormField<bool>(
                                    value: _selectedActiveStatus,
                                    decoration: InputDecoration(
                                      labelText: 'Status',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                    ),
                                    items: [
                                      DropdownMenuItem(
                                        value: null,
                                        child: Text(
                                          'All Status',
                                          style: TextStyle(
                                            color: colorScheme.onSurface
                                                .withValues(alpha: 0.7),
                                          ),
                                        ),
                                      ),
                                      const DropdownMenuItem(
                                        value: true,
                                        child: Text('Active'),
                                      ),
                                      const DropdownMenuItem(
                                        value: false,
                                        child: Text('Inactive'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedActiveStatus = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Users List
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.only(
                              left: 16,
                              right: 16,
                              top: _showFilters ? 0 : 16,
                              bottom: 80, // Extra padding for FAB
                            ),
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = filteredUsers[index];
                              return UserCard(
                                user: user,
                                isDic: widget.isDic,
                              );
                            },
                          ),
                        ),
                      ],
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
                        color: colorScheme.shadow.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextField(
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
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_searchQuery.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                ),
                              SizedBox(
                                height: 40,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(width: 8),
                                    Text(
                                      'Filters',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    Transform.scale(
                                      scale: 0.8,
                                      child: Checkbox(
                                        value: _showFilters,
                                        onChanged: (value) {
                                          setState(() {
                                            _showFilters = value ?? false;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
                    ],
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
                            builder: (context) => BlocProvider(
                              create: (context) => sl<ManageUsersCubit>(),
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

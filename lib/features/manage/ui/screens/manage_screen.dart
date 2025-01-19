import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/core/di/service_locator.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_owners/cubit/manage_owners_cubit.dart';

import '../../subfeatures/manage_owners/ui/manage_owners_tab.dart';
import '../../subfeatures/manage_projects/ui/manage_projects_tab.dart';
import '../../subfeatures/manage_sensors/ui/manage_sensors_tab.dart';
import '../../subfeatures/manage_users/ui/manage_users_tab.dart';

class ManageScreen extends StatelessWidget {
  const ManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                IconButton.filled(
                  icon: const Icon(Icons.arrow_back_ios_new_outlined),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 16),
                Container(
                  margin: const EdgeInsets.only(right: 8.0),
                  width: 5,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8.0),
                        topLeft: Radius.circular(8.0)),
                  ),
                ),
                Text(
                  'Manage Panel',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                isScrollable: false,
                labelPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: colorScheme.primary,
                ),
                dividerColor: Colors.transparent,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                labelColor: colorScheme.onPrimary,
                unselectedLabelColor: colorScheme.onSurfaceVariant,
                tabs: [
                  Tooltip(
                    message: 'Projects',
                    child: Tab(
                      height: 32,
                      icon: Icon(
                        Icons.folder_outlined,
                        size: 24,
                      ),
                    ),
                  ),
                  Tooltip(
                    message: 'Owners',
                    child: Tab(
                      height: 32,
                      icon: Icon(
                        Icons.people_alt_outlined,
                        size: 24,
                      ),
                    ),
                  ),
                  Tooltip(
                    message: 'Managed Users',
                    child: Tab(
                      height: 32,
                      icon: Icon(
                        Icons.manage_accounts_outlined,
                        size: 24,
                      ),
                    ),
                  ),
                  Tooltip(
                    message: 'Sensor Types',
                    child: Tab(
                      height: 32,
                      icon: Icon(
                        Icons.sensors_outlined,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ManageProjectsTab(),
                  BlocProvider(
                    create: (context) =>
                        sl<ManageOwnersCubit>()..getAllOwners(),
                    child: ManageOwnersTab(),
                  ),
                  ManageUsersTab(),
                  ManageSensorsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

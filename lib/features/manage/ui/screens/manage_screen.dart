import 'package:flutter/material.dart';

class ManageScreen extends StatelessWidget {
  const ManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            TabBar(
              isScrollable: false,
              labelPadding: const EdgeInsets.symmetric(vertical: 8),
              tabs: const [
                Tab(
                  height: 65,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.folder_outlined, size: 20),
                      SizedBox(height: 4),
                      Text(
                        'Projects',
                        textAlign: TextAlign.center,
                        softWrap: true,
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Tab(
                  height: 65,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people_alt_outlined, size: 20),
                      SizedBox(height: 4),
                      Text(
                        'Owners',
                        textAlign: TextAlign.center,
                        softWrap: true,
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Tab(
                  height: 65,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.manage_accounts_outlined, size: 20),
                      SizedBox(height: 4),
                      Text(
                        'Managed\nUsers',
                        textAlign: TextAlign.center,
                        softWrap: true,
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Tab(
                  height: 65,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sensors_outlined, size: 20),
                      SizedBox(height: 4),
                      Text(
                        'Sensor\nTypes',
                        textAlign: TextAlign.center,
                        softWrap: true,
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  _ProjectsTab(),
                  _OwnersTab(),
                  _ManagedUsersTab(),
                  _SensorTypesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectsTab extends StatelessWidget {
  const _ProjectsTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Projects Tab Content'),
    );
  }
}

class _OwnersTab extends StatelessWidget {
  const _OwnersTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Owners Tab Content'),
    );
  }
}

class _ManagedUsersTab extends StatelessWidget {
  const _ManagedUsersTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Managed Users Tab Content'),
    );
  }
}

class _SensorTypesTab extends StatelessWidget {
  const _SensorTypesTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Sensor Types Tab Content'),
    );
  }
}

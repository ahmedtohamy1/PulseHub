import 'package:flutter/material.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_users/ui/manage_users_tab.dart';

class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
      ),
      body: ManageUsersTab(isDic: true),
    );
  }
}

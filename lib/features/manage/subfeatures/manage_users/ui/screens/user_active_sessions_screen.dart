import 'package:flutter/material.dart';
import 'package:pulsehub/features/project_dashboard/data/models/get_all_users_response_model.dart';

class UserActiveSessionsScreen extends StatelessWidget {
  final User user;

  const UserActiveSessionsScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${user.firstName}\'s Active Sessions'),
      ),
      body: const Center(
        child: Text('Active sessions coming soon...'),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pulsehub/features/project_dashboard/data/models/get_all_users_response_model.dart';

class UserServicesScreen extends StatelessWidget {
  final User user;

  const UserServicesScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${user.firstName}\'s Services'),
      ),
      body: const Center(
        child: Text('Services coming soon...'),
      ),
    );
  }
}

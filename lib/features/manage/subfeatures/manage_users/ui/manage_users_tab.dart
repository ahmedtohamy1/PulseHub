import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/manage_users_cubit.dart';

class ManageUsersTab extends StatelessWidget {
  const ManageUsersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<ManageUsersCubit>(),
      child: const ManageUsersView(),
    );
  }
}

class ManageUsersView extends StatelessWidget {
  const ManageUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Managed Users Tab Content'),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/manage_projects_cubit.dart';

class ManageProjectsTab extends StatelessWidget {
  const ManageProjectsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<ManageProjectsCubit>(),
      child: const ManageProjectsView(),
    );
  }
}

class ManageProjectsView extends StatelessWidget {
  const ManageProjectsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Projects Tab Content'),
    );
  }
}

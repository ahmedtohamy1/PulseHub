import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/manage_owners_cubit.dart';

class ManageOwnersTab extends StatelessWidget {
  const ManageOwnersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<ManageOwnersCubit>(),
      child: const ManageOwnersView(),
    );
  }
}

class ManageOwnersView extends StatelessWidget {
  const ManageOwnersView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Owners Tab Content'),
    );
  }
}

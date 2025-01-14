import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/manage_sensors_cubit.dart';

class ManageSensorsTab extends StatelessWidget {
  const ManageSensorsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<ManageSensorsCubit>(),
      child: const ManageSensorsView(),
    );
  }
}

class ManageSensorsView extends StatelessWidget {
  const ManageSensorsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Sensor Types Tab Content'),
    );
  }
}

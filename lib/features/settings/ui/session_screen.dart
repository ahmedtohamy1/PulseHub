import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/features/settings/cubit/settings_cubit.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  @override
  void initState() {
    super.initState();

    BlocProvider.of<SettingsCubit>(context).getSessions();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        if (state is SessionsError) {
          return const Center(
            child: Text(
                'Failed to get sessions: No Current active session in Cookies'),
          );
        } else {
          return const Center(child: Text('No data available.'));
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsehub/core/routing/routes.dart';
import 'package:pulsehub/core/utils/user_manager.dart';
import 'package:pulsehub/features/dics/cubit/dic_cubit.dart';
import 'package:pulsehub/features/dics/data/models/dic_services_model.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_users/ui/manage_users_screen.dart';

class DicScreen extends StatefulWidget {
  const DicScreen({super.key});

  @override
  DicScreenState createState() => DicScreenState();
}

class DicScreenState extends State<DicScreen> {
  @override
  void initState() {
    super.initState();

    context.read<DicCubit>().getDic();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PulseHub Services',
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (UserManager().user?.isStaff == true ||
              UserManager().user?.isSuperuser == true)
            IconButton(
              tooltip: 'Manage Users',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ManageUsersScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.manage_accounts_outlined),
            ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () {
              context.read<DicCubit>().logout();
              context.go(Routes.loginScreen);
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: BlocListener<DicCubit, DicState>(
        listener: (context, state) {
          if (state is DicError) {
            UserManager().clearUser();
            context.go(Routes.loginScreen);
          }
        },
        child: BlocBuilder<DicCubit, DicState>(
          builder: (context, state) {
            if (state is DicLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DicSuccess) {
              return _buildDicServicesList(state.dic.dicServicesList.first);
            }
            return const Center(child: Text('Unexpected state.'));
          },
        ),
      ),
    );
  }

  Widget _buildDicServicesList(DicService service) {
    final List<Map<String, dynamic>> services = [
      {
        'name': 'CloudMATE',
        'enabled': service.cloudmate,
        'icon': Icons.cloud,
        'onTap': () {
          context.go(Routes.homePage);
        },
        'description': 'Manage your projects efficiently.'
      },
      {
        'name': 'Collaboration',
        'enabled': service.collaboration,
        'icon': Icons.group,
        'onTap': () {},
        'description': 'Work together seamlessly.'
      },
      {
        'name': 'Project Preparation',
        'enabled': service.projectPreparation,
        'icon': Icons.task,
        'onTap': () {},
        'description': 'Plan and organize your projects.'
      },
      {
        'name': 'Active Projects',
        'enabled': service.activeProjects,
        'icon': Icons.list,
        'onTap': () {},
        'description': 'Track and manage ongoing projects.'
      },
      {
        'name': 'Financial',
        'enabled': service.financial,
        'icon': Icons.attach_money,
        'onTap': () {},
        'description': 'Keep track of your finances.'
      },
      {
        'name': 'Administration',
        'enabled': service.administration,
        'icon': Icons.admin_panel_settings,
        'onTap': () {},
        'description': 'Manage team and resources.'
      },
    ];

    // Filter services that are enabled
    final filteredServices =
        services.where((s) => s['enabled'] == true).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome to PulseHub - Your Gate to DIC’s Innovations',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8.0),
          const Center(
            child: Text(
              'Select an Option Below to Get Started',
              style: TextStyle(fontSize: 16.0, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: ListView.builder(
              itemCount: filteredServices.length,
              itemBuilder: (context, index) {
                final service = filteredServices[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: _buildServiceCard(
                    service['icon'],
                    service['name'],
                    service['description'],
                    service['onTap'],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
      IconData icon, String name, String description, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 1.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 64.0, color: Colors.green),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      description,
                      style:
                          const TextStyle(fontSize: 16.0, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

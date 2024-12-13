import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsehub/core/routing/routes.dart';
import 'package:pulsehub/features/home/cubit/dic_cubit.dart';
import 'package:pulsehub/features/home/data/dic_services_model.dart';

class DicScreen extends StatefulWidget {
  const DicScreen({super.key});

  @override
  DicScreenState createState() => DicScreenState();
}

class DicScreenState extends State<DicScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger the getDic function in the Cubit
    context.read<DicCubit>().getDic(); // Pass the valid user ID here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PulseHub Services',
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 24.0,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: BlocBuilder<DicCubit, DicState>(
        builder: (context, state) {
          if (state is DicLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DicError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is DicSuccess) {
            return _buildDicServicesList(state.dic.dicServicesList.first);
          }
          return const Center(child: Text('Unexpected state.'));
        },
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

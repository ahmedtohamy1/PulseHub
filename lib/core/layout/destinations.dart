import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class Destination {
  const Destination({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

const destinations = [
  Destination(label: 'CloudMATE', icon: Icons.cloud),
  Destination(label: 'DIC Services', icon: Icons.dashboard),
  Destination(label: 'Notifications', icon: LucideIcons.bell),
  Destination(label: 'More', icon: Icons.menu),
];

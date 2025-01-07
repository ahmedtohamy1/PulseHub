import 'package:flutter/material.dart';

class Destination {
  const Destination({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

const destinations = [
  Destination(label: 'CloudMate', icon: Icons.cloud),
  Destination(label: 'DIC Services', icon: Icons.dashboard),
  Destination(label: 'More', icon: Icons.menu),
];

import 'package:flutter/material.dart';

class Destination {
  const Destination({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

const destinations = [
  Destination(label: 'Cloud Mate', icon: Icons.cloud),
  Destination(label: 'Cloud Mate', icon: Icons.more),
  Destination(label: 'More', icon: Icons.menu),
];

import 'package:flutter/material.dart';

class CircleIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;

  const CircleIcon({
    required this.icon,
    required this.isActive,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).primaryColor : Colors.white,
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(10.0),
      child: Icon(
        icon,
        color: isActive ? Colors.white : Theme.of(context).primaryColor,
      ),
    );
  }
}

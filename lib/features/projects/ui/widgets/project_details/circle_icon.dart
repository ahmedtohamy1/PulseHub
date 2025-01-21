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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: isActive ? colorScheme.primary : colorScheme.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? colorScheme.primary : colorScheme.outlineVariant,
          width: 1,
        ),
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      padding: const EdgeInsets.all(10.0),
      child: Icon(
        icon,
        color: isActive ? colorScheme.onPrimary : colorScheme.primary,
      ),
    );
  }
}

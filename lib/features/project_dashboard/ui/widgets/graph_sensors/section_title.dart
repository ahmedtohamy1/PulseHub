import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback onAdd;

  const SectionTitle({required this.title, super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton.filled(
              onPressed: onAdd, icon: const Icon(LucideIcons.plus))
        ],
      ),
    );
  }
}

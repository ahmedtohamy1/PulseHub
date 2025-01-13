import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'circle_icon.dart';

class HeaderIcons extends StatelessWidget {
  final int activeIconIndex;
  final Function(int) onIconTap;

  const HeaderIcons({
    required this.activeIconIndex,
    required this.onIconTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = [
      Icons.arrow_back_ios_new_outlined,
      LucideIcons.layoutGrid,
      Icons.map_sharp,
      LucideIcons.gauge,
      LucideIcons.fileText,
      MdiIcons.monitorEye,
      MdiIcons.wrench,
    ];

    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Tooltip(
              message: _getTooltipMessage(0),
              child: IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  foregroundColor: colorScheme.onSurfaceVariant,
                ),
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  iconData[0],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          for (int i = 1; i < iconData.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Tooltip(
                message: _getTooltipMessage(i),
                child: InkWell(
                  onTap: () => onIconTap(i),
                  child: CircleIcon(
                    icon: iconData[i],
                    isActive: activeIconIndex == i,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getTooltipMessage(int index) {
    switch (index) {
      case 0:
        return 'Back';
      case 1:
        return 'Dashboard';
      case 2:
        return 'Visualise';
      case 3:
        return 'Analyse';
      case 4:
        return 'Report';
      case 5:
        return 'Monitor';
      case 6:
        return 'Control';
      default:
        return '';
    }
  }
}

import 'package:flutter/material.dart';

class FileSideItem extends StatelessWidget {
  const FileSideItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.scale = 1.0,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Colors.white.withValues(alpha: 0.10) : Colors.transparent,
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        leading: Icon(
          icon,
          color: selected ? Colors.white : Colors.white54,
          size: 16 * scale,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white60,
            fontSize: 12 * scale,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:ubuntu_simulate/commons/styles/os_colors.dart';
import 'package:ubuntu_simulate/commons/styles/os_scale.dart';

class ContextMenu extends StatelessWidget {
  const ContextMenu({
    super.key,
    required this.pos,
    required this.scale,
    required this.onDismiss,
  });
  final Offset pos;
  final OsScaleTokens scale;
  final VoidCallback onDismiss;

  static const _items = <String?>[
    'New Folder',
    'New Document',
    null,
    'Paste',
    null,
    'Display Settings',
    null,
    'Open Terminal Here',
  ];

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: pos.dx,
      top: pos.dy,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: (scale.barFontSize * 16).clamp(160.0, 240.0),
          decoration: BoxDecoration(
            color: OsColors.ctxMenu,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: OsColors.ctxBorder),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 20,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _items.map((item) {
              if (item == null) {
                return Divider(height: 1, color: Colors.white.withValues(alpha: 0.1));
              }
              return _CtxItem(
                label: item,
                fontSize: scale.barFontSize,
                onTap: onDismiss,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _CtxItem extends StatefulWidget {
  const _CtxItem({
    required this.label,
    required this.fontSize,
    required this.onTap,
  });
  final String label;
  final double fontSize;
  final VoidCallback onTap;
  @override
  State<_CtxItem> createState() => _CtxItemState();
}

class _CtxItemState extends State<_CtxItem> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          padding: EdgeInsets.symmetric(
            horizontal: widget.fontSize * 1.1,
            vertical: widget.fontSize * 0.65,
          ),
          decoration: BoxDecoration(
            color: _hover ? OsColors.ctxMenuHover : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            widget.label,
            style: TextStyle(color: Colors.white, fontSize: widget.fontSize),
          ),
        ),
      ),
    );
  }
}

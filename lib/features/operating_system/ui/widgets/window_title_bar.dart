import 'package:flutter/material.dart';
import 'package:ubuntu_simulate/commons/styles/os_colors.dart';
import 'package:ubuntu_simulate/commons/styles/os_scale.dart';

class WindowTitleBar extends StatelessWidget {
  const WindowTitleBar({
    super.key,
    required this.title,
    required this.scale,
    required this.maximized,
    required this.onClose,
    required this.onMinimize,
    required this.onMaximize,
  });
  final String title;
  final OsScaleTokens scale;
  final bool maximized;
  final VoidCallback onClose, onMinimize, onMaximize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: onMaximize,
      child: Container(
        height: scale.titleBarHeight,
        color: OsColors.titleBar,
        padding: EdgeInsets.symmetric(horizontal: scale.titleBarPadding),
        child: Row(
          children: [
            SizedBox(width: scale.controlSize * 3 + scale.controlSpacing * 2),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: OsColors.titleBarText,
                  fontSize: scale.titleBarFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            _WinCtrl(
              size: scale.controlSize,
              iconSize: scale.controlIconSize,
              hoverIcon: Icons.remove,
              onTap: onMinimize,
            ),
            SizedBox(width: scale.controlSpacing),
            _WinCtrl(
              size: scale.controlSize,
              iconSize: scale.controlIconSize,
              hoverIcon: maximized ? Icons.fullscreen_exit : Icons.crop_square,
              onTap: onMaximize,
            ),
            SizedBox(width: scale.controlSpacing),
            _WinCtrl(
              size: scale.controlSize,
              iconSize: scale.controlIconSize,
              hoverIcon: Icons.close,
              isClose: true,
              onTap: onClose,
            ),
          ],
        ),
      ),
    );
  }
}

class _WinCtrl extends StatefulWidget {
  const _WinCtrl({
    required this.size,
    required this.iconSize,
    required this.hoverIcon,
    required this.onTap,
    this.isClose = false,
  });
  final double size, iconSize;
  final IconData hoverIcon;
  final bool isClose;
  final VoidCallback onTap;
  @override
  State<_WinCtrl> createState() => _WinCtrlState();
}

class _WinCtrlState extends State<_WinCtrl> {
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
          duration: const Duration(milliseconds: 100),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _hover
                ? (widget.isClose ? const Color(0xFFE95420) : OsColors.winCtrlHover)
                : OsColors.winCtrl,
          ),
          child: _hover
              ? Icon(
                  widget.hoverIcon,
                  size: widget.iconSize,
                  color: Colors.white,
                )
              : null,
        ),
      ),
    );
  }
}

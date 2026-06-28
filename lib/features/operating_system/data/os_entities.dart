import 'package:flutter/material.dart';
import 'package:ubuntu_simulate/commons/styles/os_colors.dart';

class DockApp {
  const DockApp({
    required this.id,
    required this.label,
    required this.icon,
    this.assetPath,
    this.color = OsColors.dockActive,
    this.onLaunch,
    this.designSize,
  });
  final String id;
  final String label;
  final IconData icon;
  final String? assetPath;
  final Color color;
  final VoidCallback? onLaunch;
  final Size? designSize;
}

class WindowState {
  WindowState({
    required this.appId,
    required this.title,
    required this.child,
    required this.offset,
    required this.size,
  });

  final String appId;
  final String title;
  final Widget child;
  Offset offset;
  Size size;
  bool minimized = false;
  bool maximized = false;
  Offset _prevOffset = Offset.zero;
  Size _prevSize = Size.zero;

  void toggleMaximize(Size viewport, double dockWidth, double barHeight) {
    if (maximized) {
      offset = _prevOffset;
      size = _prevSize;
      maximized = false;
    } else {
      _prevOffset = offset;
      _prevSize = size;
      // Agora o offset é 0, pois a Stack do desktop já começa após o Dock e a Bar
      offset = Offset.zero;
      size = Size(viewport.width - dockWidth, viewport.height - barHeight);
      maximized = true;
    }
  }
}

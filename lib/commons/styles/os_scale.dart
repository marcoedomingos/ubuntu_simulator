import 'package:flutter/material.dart';

class OsScaleTokens {
  OsScaleTokens.fromViewport(Size viewport, {required int dockAppCount}) {
    final w = viewport.width;
    final h = viewport.height;
    final ref = w < h ? w : h;

    barHeight = (h * 0.048).clamp(20.0, 34.0);
    barFontSize = (ref * 0.028).clamp(8.0, 13.0);
    barIconSize = (barHeight * 0.48).clamp(10.0, 17.0);
    barPadding = (w * 0.018).clamp(4.0, 14.0);

    final dockAreaH = (h - barHeight).clamp(80.0, double.infinity);
    const chromeSlots = 2.0;
    final slots = chromeSlots + dockAppCount;
    final slotH = dockAreaH / (slots + 0.8);
    dockIconSize = (slotH * 0.52).clamp(16.0, 40.0);
    dockSpacing = (slotH * 0.12).clamp(2.0, 10.0);
    dockPadding = (slotH * 0.10).clamp(3.0, 12.0);
    dockWidth = (dockIconSize * 1.32).clamp(36.0, 64.0);
    dockSlotHeight = slotH;

    titleBarHeight = (h * 0.055).clamp(22.0, 36.0);
    titleBarFontSize = (ref * 0.024).clamp(8.0, 13.0);
    titleBarPadding = (w * 0.016).clamp(4.0, 14.0);

    controlSize = (ref * 0.028).clamp(10.0, 16.0);
    controlIconSize = (controlSize * 0.62).clamp(6.0, 11.0);
    controlSpacing = (ref * 0.010).clamp(2.0, 7.0);

    splashLogoSize = (ref * 0.14).clamp(40.0, 80.0);
    splashSpacing = (ref * 0.04).clamp(10.0, 22.0);

    tooltipFontSize = (ref * 0.020).clamp(7.0, 12.0);
    runDotSize = (dockIconSize * 0.08).clamp(2.0, 5.0);
  }

  late final double barHeight, barFontSize, barIconSize, barPadding;
  late final double dockWidth,
      dockIconSize,
      dockPadding,
      dockSpacing,
      dockSlotHeight;
  late final double titleBarHeight, titleBarFontSize, titleBarPadding;
  late final double controlSize, controlIconSize, controlSpacing;
  late final double splashLogoSize, splashSpacing;
  late final double tooltipFontSize, runDotSize;
}

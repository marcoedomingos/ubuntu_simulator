import 'package:flutter/material.dart';

class UiScale extends InheritedWidget {
  const UiScale({super.key, required this.factor, required super.child});

  final double factor;

  static const _referenceW = 960.0;
  static const _referenceH = 600.0;

  static double factorFromViewport(Size viewport) {
    final fw = viewport.width / _referenceW;
    final fh = viewport.height / _referenceH;
    return (fw < fh ? fw : fh).clamp(0.35, 1.5);
  }

  static double of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<UiScale>();
    return result?.factor ?? 1.0;
  }

  static double s(BuildContext context, double value) => value * of(context);

  @override
  bool updateShouldNotify(UiScale old) => old.factor != factor;
}

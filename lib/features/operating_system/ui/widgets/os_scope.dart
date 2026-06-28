import 'package:flutter/material.dart';
import '../../data/os_state_data.dart';

class OsScope extends InheritedWidget {
  const OsScope({
    super.key,
    required this.data,
    required this.controller,
    required super.child,
  });

  final OsStateData data;
  final OsController controller;

  static OsController of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<OsScope>();
    assert(result != null, 'No OsScope found in context');
    return result!.controller;
  }

  static OsStateData dataOf(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<OsScope>();
    assert(result != null, 'No OsScope found in context');
    return result!.data;
  }

  @override
  bool updateShouldNotify(OsScope oldWidget) {
    return oldWidget.data != data;
  }
}

import 'package:flutter/material.dart';
import 'package:ubuntu_simulate/features/operating_system/ui/widgets/os_scope.dart';
import 'package:ubuntu_simulate/commons/widgets/ui_scale.dart';
import '../widgets/settings_widgets.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  int _sel = 0;

  static const _sections = <(IconData, String)>[
    (Icons.wifi, 'Wi-Fi'),
    (Icons.bluetooth, 'Bluetooth'),
    (Icons.wallpaper, 'Background'),
    (Icons.notifications_none, 'Notifications'),
    (Icons.info_outline, 'About'),
  ];

  @override
  Widget build(BuildContext context) {
    final s = UiScale.of(context);
    final label = _sections[_sel].$2;
    final data = OsScope.dataOf(context);
    final controller = OsScope.of(context);

    const settingsBg = Color(0xFF1E1E1E);
    const settingsSide = Color(0xFF252526);
    const dockActive = Color(0xFF3584E4);

    return Container(
      color: settingsBg,
      child: Row(
        children: [
          // Sidebar
          Material(
            color: settingsSide,
            child: SizedBox(
              width: 180 * s,
              child: ListView.builder(
                itemCount: _sections.length,
                itemBuilder: (_, i) {
                  final (icon, name) = _sections[i];
                  return ListTile(
                    dense: true,
                    selected: _sel == i,
                    selectedTileColor: dockActive.withValues(alpha: 0.25),
                    leading: Icon(
                      icon,
                      color: _sel == i ? dockActive : Colors.white54,
                      size: 18 * s,
                    ),
                    title: Text(
                      name,
                      style: TextStyle(
                        color: _sel == i ? Colors.white : Colors.white70,
                        fontSize: 13 * s,
                      ),
                    ),
                    onTap: () => setState(() => _sel = i),
                  );
                },
              ),
            ),
          ),

          // Detail panel
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(24 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20 * s,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16 * s),
                  Expanded(
                    child: SettingsDetailPanel(
                      label: label,
                      data: data,
                      controller: controller,
                      s: s,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

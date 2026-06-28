import 'package:flutter/material.dart';
import 'package:ubuntu_simulate/features/operating_system/data/os_state_data.dart';

class SettingsDetailPanel extends StatelessWidget {
  const SettingsDetailPanel({
    super.key,
    required this.label,
    required this.data,
    required this.controller,
    required this.s,
  });

  final String label;
  final OsStateData data;
  final OsController controller;
  final double s;

  @override
  Widget build(BuildContext context) {
    const dockActive = Color(0xFF3584E4);
    switch (label) {
      case 'Wi-Fi':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Enable Wi-Fi Network',
                  style: TextStyle(color: Colors.white70, fontSize: 13 * s),
                ),
                const Spacer(),
                Switch(
                  value: data.wifiEnabled,
                  onChanged: (val) => controller.toggleWifi(),
                  activeThumbColor: dockActive,
                ),
              ],
            ),
            if (data.wifiEnabled) ...[
              SizedBox(height: 12 * s),
              Text(
                'Connected to: "Portfolio-WiFi"\nIP Address: 192.168.1.127\nSignal Strength: Excellent',
                style: TextStyle(color: Colors.white54, fontSize: 13 * s, height: 1.5),
              ),
            ],
          ],
        );
      case 'Bluetooth':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Enable Bluetooth Service',
                  style: TextStyle(color: Colors.white70, fontSize: 13 * s),
                ),
                const Spacer(),
                Switch(
                  value: data.bluetoothEnabled,
                  onChanged: (val) => controller.toggleBluetooth(),
                  activeThumbColor: dockActive,
                ),
              ],
            ),
            if (data.bluetoothEnabled) ...[
              SizedBox(height: 12 * s),
              Text(
                'Status: Scanning for devices...\nPaired Devices:\n- Pixel Watch 2.0 (Connected)',
                style: TextStyle(color: Colors.white54, fontSize: 13 * s, height: 1.5),
              ),
            ],
          ],
        );
      case 'Background':
        final options = [
          ('assets/src/ubuntu_background.jpg', 'Ubuntu Classic'),
          ('gradient:jellyfish', 'Jellyfish Aubergine'),
          ('gradient:aurora', 'Teal Aurora'),
          ('gradient:cyber', 'Neon Cyberpunk'),
        ];
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10 * s,
            mainAxisSpacing: 10 * s,
            childAspectRatio: 1.6,
          ),
          itemCount: options.length,
          itemBuilder: (context, idx) {
            final opt = options[idx];
            final isSelected = data.wallpaperPath == opt.$1;
            return GestureDetector(
              onTap: () => controller.changeWallpaper(opt.$1),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? dockActive : Colors.white24,
                    width: isSelected ? 3 : 1,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (opt.$1.startsWith('gradient:'))
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: opt.$1 == 'gradient:jellyfish'
                                ? [const Color(0xFF2C001E), const Color(0xFFE95420)]
                                : opt.$1 == 'gradient:aurora'
                                    ? [const Color(0xFF001F3F), const Color(0xFF00FFCC)]
                                    : [const Color(0xFF120458), const Color(0xFF3F0071), Colors.black],
                          ),
                        ),
                      )
                    else
                      Image.asset(opt.$1, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(color: Colors.purple)),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: Colors.black54,
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        child: Text(
                          opt.$2,
                          style: const TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      case 'About':
        return Text(
          'Ubuntu Desktop Edition\nVersion: 22.04.3 LTS (Jammy Jellyfish)\nDE: GNOME 42.9\nSimulated Host Architecture: WebAssembly / CanvasKit\nMemory: 8 GB RAM\nVirtual OS Disk Capacity: 512 MB (VFS Memory)',
          style: TextStyle(color: Colors.white54, fontSize: 13 * s, height: 1.8),
        );
      default:
        return Text(
          'Notifications are set to Default (Show Banners)',
          style: TextStyle(color: Colors.white54, fontSize: 13 * s),
        );
    }
  }
}

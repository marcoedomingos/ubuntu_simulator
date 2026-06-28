import 'package:ubuntu_simulate/features/monitor/ui/widgets/monitor_frame_painter.dart';
import 'package:ubuntu_simulate/features/operating_system/ui/operating_system_view.dart';
import 'package:ubuntu_simulate/features/operating_system/ui/pages/ubuntu_desktop_page.dart';
import 'package:flutter/material.dart';

class Monitor extends StatefulWidget {
  const Monitor({super.key});

  @override
  State<Monitor> createState() => _MonitorState();
}

class _MonitorState extends State<Monitor> {
  final GlobalKey<UbuntuDesktopState> _osKey = GlobalKey();
  static const double aspectFactor = 0.62;

  void _handleMonitorTap(Offset localPos, Size size) {
    final w = size.width;
    final h = size.height;

    final powerPos = Offset(w * 0.920, h * 0.930);
    final distance = (localPos - powerPos).distance;

    if (distance < w * 0.02) {
      final state = _osKey.currentState;
      if (state != null && state.mounted) {
        state.powerOn(); 
      }
    }
    
    for (int i = 0; i < 4; i++) {
      final btnPos = Offset(w * 0.850 + i * w * 0.016, h * 0.930);
      if ((localPos - btnPos).distance < w * 0.015) {
        _showMonitorOsd(i);
        break;
      }
    }
  }

  void _showMonitorOsd(int index) {
    final labels = ['Source', 'Brightness', 'Contrast', 'Menu'];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Monitor OSD: ${labels[index]}'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        width: 200,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF0C0C0E),
      child: Center(
        child: AspectRatio(
          aspectRatio: 1 / aspectFactor,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);

              return GestureDetector(
                onTapDown: (details) => _handleMonitorTap(details.localPosition, size),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CustomPaint(
                      size: size,
                      painter: Painter(),
                    ),
                    Positioned(
                      left: size.width * 0.06,
                      right: size.width * 0.06,
                      top: size.height * 0.08,
                      bottom: size.height * 0.08,
                      child: OperatingSystem(osKey: _osKey),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

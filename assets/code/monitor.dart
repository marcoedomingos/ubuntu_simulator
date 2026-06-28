import 'package:ubuntu_simulate/features/monitor/ui/widgets/monitor_frame_painter.dart';
import 'package:ubuntu_simulate/features/operating_system/ui/operating_system_view.dart';
import 'package:flutter/material.dart';

class Monitor extends StatelessWidget {
  const Monitor({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;
        final double availableHeight = constraints.maxHeight;

        // Check if we are on a mobile-sized or portrait screen
        final bool isMobile = availableWidth < 600 || availableWidth < availableHeight;

        if (isMobile) {
          // Mobile Layout: Provide a clean, distraction-free edge-to-edge view
          // with light padding so it doesn't clip into mobile status bars.
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: const OperatingSystem(),
            ),
          );
        }

        // Desktop/Tablet Layout: Keep your custom painted monitor frame
        const double maxAllowedWidth = 1024.0;
        const double aspectFactor = 0.62; // Height = Width * 0.62
        const double maxAllowedHeight = maxAllowedWidth * aspectFactor;

        final clampedWidth = availableWidth.clamp(0.0, maxAllowedWidth);
        final clampedHeight = availableHeight.clamp(0.0, maxAllowedHeight);

        double w;
        double h;

        if (clampedWidth * aspectFactor <= clampedHeight) {
          w = clampedWidth;
          h = w * aspectFactor;
        } else {
          h = clampedHeight;
          w = h / aspectFactor;
        }

        return Center(
          child: SizedBox(
            width: w,
            height: h,
            child: Stack(
              children: [
                CustomPaint(size: Size(w, h), painter: Painter()),
                Positioned(
                  left: w * 0.06,
                  right: w * 0.06,
                  top: h * 0.08,
                  bottom: h * 0.08,
                  child: const OperatingSystem(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

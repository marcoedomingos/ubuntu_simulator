import 'package:flutter/material.dart';
import 'package:smart_watch/smart_watch.dart' as watch;

class PixelWatchView extends StatelessWidget {
  const PixelWatchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E1E1E),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: 800,
              height: 1000,
              child: watch.HomePage(),
            ),
          ),
        ),
      ),
    );
  }
}

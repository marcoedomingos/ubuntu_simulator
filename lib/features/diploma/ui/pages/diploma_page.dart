import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class Diploma extends StatelessWidget {
  const Diploma({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(
      child: ModelViewer(
        src: 'assets/src/base_basic_shaded.glb',
        alt: 'Digital Diploma 3D Model',
        ar: false,
        autoRotate: true,
        cameraControls: true,
        backgroundColor: Color(0xFF1E1E1E),
      ),
    );
  }
}

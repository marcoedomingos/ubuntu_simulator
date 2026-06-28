import 'package:flutter/material.dart';
import 'pages/ubuntu_desktop_page.dart';

class OperatingSystem extends StatelessWidget {
  const OperatingSystem({super.key, this.osKey});
  final GlobalKey<UbuntuDesktopState>? osKey;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.transparent,
    body: UbuntuDesktop(key: osKey),
  );
}

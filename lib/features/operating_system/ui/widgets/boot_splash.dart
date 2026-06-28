import 'package:flutter/material.dart';
import 'package:ubuntu_simulate/commons/styles/os_scale.dart';

class BootSplash extends StatefulWidget {
  const BootSplash({super.key, required this.scale, this.isShuttingDown = false});
  final OsScaleTokens scale;
  final bool isShuttingDown;

  @override
  State<BootSplash> createState() => _BootSplashState();
}

class _BootSplashState extends State<BootSplash> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        // Ajustando o tamanho do logo para ser proporcional à largura da tela (ex: 30% da largura)
        final logoSize = screenWidth * 0.25; 

        return Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFF2C001E), // Ubuntu Aubergine
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ubuntu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: logoSize * 0.5, // Texto proporcional ao logo
                          fontWeight: FontWeight.w300,
                          fontFamily: 'Ubuntu',
                          shadows: [
                            Shadow(
                              blurRadius: 15,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: logoSize * 0.12,
                        height: logoSize * 0.12,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE95420),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.circle,
                            color: Colors.white,
                            size: logoSize * 0.06,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (index) {
                          // Efeito de pulso sincronizado com o vídeo
                          final progress = (_controller.value * 5 - index) % 5;
                          final opacity = (1.0 - (progress / 5)).clamp(0.1, 1.0);
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: opacity),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ],
              ),
              if (widget.isShuttingDown)
                Positioned(
                  bottom: 60,
                  child: Text(
                    'Shutting down...',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 16,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
            ],
          ),
        );
      }
    );
  }
}

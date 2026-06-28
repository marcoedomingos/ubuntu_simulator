import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class CMatrixWidget extends StatefulWidget {
  const CMatrixWidget({super.key, required this.onExit});
  final VoidCallback onExit;

  @override
  State<CMatrixWidget> createState() => _CMatrixWidgetState();
}

class _CMatrixWidgetState extends State<CMatrixWidget> {
  final _random = math.Random();
  late List<_MatrixColumn> _columns;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _columns = List.generate(40, (index) => _MatrixColumn(_random));
    _timer = Timer.periodic(const Duration(milliseconds: 65), (timer) {
      if (mounted) {
        setState(() {
          for (final col in _columns) {
            col.update(_random);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: CustomPaint(
        painter: _CMatrixPainter(_columns),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _MatrixColumn {
  _MatrixColumn(math.Random rand) {
    xPercent = rand.nextDouble();
    speed = rand.nextDouble() * 14 + 4;
    y = -rand.nextDouble() * 400;
    chars = List.generate(15, (_) => _randomChar(rand));
  }

  late double xPercent;
  late double speed;
  late double y;
  late List<String> chars;

  String _randomChar(math.Random rand) {
    const src = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ#\$%&*()@';
    return src[rand.nextInt(src.length)];
  }

  void update(math.Random rand) {
    y += speed;
    if (y > 700) {
      y = -rand.nextDouble() * 250;
      speed = rand.nextDouble() * 14 + 4;
    }
    if (rand.nextDouble() < 0.15) {
      chars[rand.nextInt(chars.length)] = _randomChar(rand);
    }
  }
}

class _CMatrixPainter extends CustomPainter {
  _CMatrixPainter(this.columns);
  final List<_MatrixColumn> columns;

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);

    for (final col in columns) {
      final x = col.xPercent * size.width;
      for (var i = 0; i < col.chars.length; i++) {
        final charY = col.y - (i * 17);
        if (charY < 0 || charY > size.height) continue;

        final opacity = (1.0 - (i / col.chars.length)).clamp(0.08, 1.0);
        final color = i == 0 ? Colors.white : Colors.greenAccent.withValues(alpha: opacity);

        textPainter.text = TextSpan(
          text: col.chars[i],
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
          ),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x, charY));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CMatrixPainter oldDelegate) => true;
}

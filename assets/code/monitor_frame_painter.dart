import 'package:flutter/material.dart';

/// CustomPainter that draws the portfolio desk-monitor bezel, screen, stand,
/// webcam, and LED details. Shown in VS Code inside the Ubuntu simulation.
class Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final s = size;

    Paint fill(Color c) => Paint()
      ..color = c
      ..style = PaintingStyle.fill;
    Paint stroke(Color c, double w) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = w;

    // ── Bezel outer shadow edge ───────────────────────
    final outerBezel = RRect.fromLTRBR(
      s.width * 0.04,
      s.height * 0.06,
      s.width * 0.96,
      s.height * 0.94,
      const Radius.circular(4),
    );
    canvas.drawRRect(outerBezel, fill(const Color(0xFF151618)));

    // ── Bezel main face ───────────────────────────────
    final mainBezelRect = Rect.fromLTWH(
      s.width * 0.042,
      s.height * 0.063,
      s.width * 0.916,
      s.height * 0.877,
    );
    final mainBezel = RRect.fromRectXY(mainBezelRect, 3, 3);
    canvas.drawRRect(
      mainBezel,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF3A3C40), Color(0xFF28292D)],
        ).createShader(mainBezelRect),
    );

    // ── Bezel inner stepped shade ─────────────────────
    final innerBezelStep = RRect.fromLTRBR(
      s.width * 0.050,
      s.height * 0.072,
      s.width * 0.950,
      s.height * 0.930,
      const Radius.circular(1),
    );
    canvas.drawRRect(innerBezelStep, fill(const Color(0xFF242529)));

    // ── Screen well ───────────────────────────────────
    canvas.drawRect(
      Rect.fromLTRB(
        s.width * 0.057,
        s.height * 0.080,
        s.width * 0.943,
        s.height * 0.922,
      ),
      fill(const Color(0xFF0A0A0A)),
    );

    // ── Screen face ───────────────────────────────────
    final screenRect = Rect.fromLTRB(
      s.width * 0.059,
      s.height * 0.082,
      s.width * 0.941,
      s.height * 0.919,
    );
    canvas.drawRect(
      screenRect,
      Paint()
        ..shader = LinearGradient(
          begin: const Alignment(-0.6, -1),
          end: const Alignment(0.8, 1),
          colors: const [
            Color(0xFF141414),
            Color(0xFF0E0E0E),
            Color(0xFF1A1A1A),
            Color(0xFF0A0A0A),
          ],
          stops: const [0.0, 0.35, 0.65, 1.0],
        ).createShader(screenRect),
    );

    // ── Bottom bezel bar ──────────────────────────────
    canvas.drawRect(
      Rect.fromLTRB(
        s.width * 0.042,
        s.height * 0.919,
        s.width * 0.958,
        s.height * 0.940,
      ),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF44474F), Color(0xFF2A2D34)],
        ).createShader(Rect.fromLTWH(0, 0, 1, 1)),
    );

    // ── Button dots bottom-right ──────────────────────
    for (int i = 0; i < 4; i++) {
      canvas.drawCircle(
        Offset(s.width * 0.850 + i * s.width * 0.016, s.height * 0.930),
        s.width * 0.003,
        fill(const Color(0xFF4B4F58)),
      );
    }

    // ── Power LED ─────────────────────────────────────
    canvas.drawCircle(
      Offset(s.width * 0.920, s.height * 0.930),
      s.width * 0.004,
      fill(const Color(0xFF4D90FF).withValues(alpha: 0.85)),
    );
    canvas.drawCircle(
      Offset(s.width * 0.920, s.height * 0.930),
      s.width * 0.008,
      fill(const Color(0xFF4D90FF).withValues(alpha: 0.10)),
    );

    // ── Stand joint ───────────────────────────────────
    final standRect = RRect.fromRectXY(
      Rect.fromLTWH(
        cx - s.width * 0.04,
        s.height * 0.94,
        s.width * 0.08,
        s.height * 0.035,
      ),
      2,
      2,
    );
    canvas.drawRRect(standRect, fill(const Color(0xFF2B2D32)));
    canvas.drawRRect(standRect, stroke(const Color(0xFF151618), 1.5));

    // ── Stand base ───────────────────────────────────
    final jointRect = RRect.fromRectXY(
      Rect.fromLTWH(
        cx - s.width * 0.05,
        s.height * 0.97,
        s.width * 0.1,
        s.height * 0.035,
      ),
      2,
      2,
    );
    canvas.drawRRect(jointRect, fill(const Color(0xFF2B2D32)));
    canvas.drawRRect(jointRect, stroke(const Color(0xFF151618), 1.5));

    // ── Right-side interface notches ──────────────────
    for (int i = 0; i < 5; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
          s.width * 0.952,
          s.height * 0.42 + i * s.height * 0.030,
          s.width * 0.003,
          s.height * 0.006,
        ),
        fill(const Color(0xFF151618)),
      );
    }

    // ── Webcam clip foot ──────────────────────────────
    final clipRect = RRect.fromRectXY(
      Rect.fromLTWH(
        cx - s.width * 0.035,
        s.height * 0.048,
        s.width * 0.07,
        s.height * 0.018,
      ),
      2,
      2,
    );
    canvas.drawRRect(clipRect, fill(const Color(0xFF1D1E22)));
    canvas.drawRRect(clipRect, stroke(const Color(0xFF151618), 1.0));

    // ── Webcam body ───────────────────────────────────
    final camBodyRect = Rect.fromLTWH(
      cx - s.width * 0.06,
      s.height * 0.008,
      s.width * 0.12,
      s.height * 0.044,
    );
    final camBody = RRect.fromRectXY(camBodyRect, 4, 4);
    canvas.drawRRect(
      camBody,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2A2A2C), Color(0xFF1A1A1C)],
        ).createShader(camBodyRect),
    );
    canvas.drawRRect(camBody, stroke(const Color(0xFF151618), 1.5));

    canvas.drawLine(
      Offset(cx - s.width * 0.022, s.height * 0.008),
      Offset(cx - s.width * 0.022, s.height * 0.052),
      stroke(const Color(0xFF111113), 1.0),
    );
    canvas.drawLine(
      Offset(cx + s.width * 0.022, s.height * 0.008),
      Offset(cx + s.width * 0.022, s.height * 0.052),
      stroke(const Color(0xFF111113), 1.0),
    );

    for (int i = 0; i < 5; i++) {
      canvas.drawLine(
        Offset(cx - s.width * 0.054 + i * s.width * 0.008, s.height * 0.010),
        Offset(cx - s.width * 0.054 + i * s.width * 0.008, s.height * 0.050),
        stroke(const Color(0xFF111113), 0.8),
      );
    }

    for (int i = 0; i < 5; i++) {
      canvas.drawLine(
        Offset(cx + s.width * 0.025 + i * s.width * 0.008, s.height * 0.010),
        Offset(cx + s.width * 0.025 + i * s.width * 0.008, s.height * 0.050),
        stroke(const Color(0xFF111113), 0.8),
      );
    }

    // ── Lens rings ────────────────────────────────────
    final lensCenter = Offset(cx, s.height * 0.030);
    canvas.drawCircle(lensCenter, s.width * 0.022, fill(const Color(0xFF111113)));
    canvas.drawCircle(lensCenter, s.width * 0.018, fill(const Color(0xFF1A1A1C)));
    canvas.drawCircle(
      lensCenter,
      s.width * 0.013,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFF0A0A0C)
        ..strokeWidth = s.width * 0.004,
    );
    canvas.drawCircle(lensCenter, s.width * 0.010, fill(const Color(0xFF0A0C14)));
    canvas.drawCircle(lensCenter, s.width * 0.006, fill(const Color(0xFF060810)));

    canvas.drawCircle(
      Offset(cx - s.width * 0.004, s.height * 0.022),
      s.width * 0.002,
      fill(const Color(0xFF6BB5FF).withValues(alpha: 0.9)),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

class WavyGradientPainter extends CustomPainter {
  final double animationValue;

  WavyGradientPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.blue.shade800,
          Colors.cyan.shade600,
          Colors.purple.shade800,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    const waveHeight = 50.0;
    const waveCount = 3;
    final offset = animationValue * 2 * math.pi;

    path.moveTo(0, size.height * 0.5);
    for (double x = 0; x <= size.width; x += 5) {
      final y = size.height * 0.5 +
          math.sin((x / size.width) * waveCount * 2 * math.pi + offset) *
              waveHeight;
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Second wave layer for depth
    final paint2 = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.cyan.shade300.withOpacity(0.5),
          Colors.blue.shade600.withOpacity(0.5),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path2 = Path();
    path2.moveTo(0, size.height * 0.6);
    for (double x = 0; x <= size.width; x += 5) {
      final y = size.height * 0.6 +
          math.sin((x / size.width) * (waveCount - 1) * 2 * math.pi - offset) *
              (waveHeight * 0.8);
      path2.lineTo(x, y);
    }
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

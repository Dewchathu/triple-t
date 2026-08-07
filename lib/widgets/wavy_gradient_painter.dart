import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:triple_t/providers/game_provider.dart';

class WavyGradientPainter extends CustomPainter {
  final double animationValue;
  final GameTheme theme;

  WavyGradientPainter(this.animationValue, {this.theme = GameTheme.classic});

  @override
  void paint(Canvas canvas, Size size) {
    List<Color> mainColors;
    List<Color> waveColors;
    Color bgFillColor = Colors.transparent;

    switch (theme) {
      case GameTheme.classic:
        mainColors = [
          Colors.blue.shade800,
          Colors.cyan.shade600,
          Colors.purple.shade800,
        ];
        waveColors = [
          Colors.cyan.shade300.withOpacity(0.5),
          Colors.blue.shade600.withOpacity(0.5),
        ];
        break;
      case GameTheme.neon:
        bgFillColor = Colors.black;
        mainColors = [
          const Color(0xFF1E0B36), // dark purple replacement for shade950
          Colors.blue.shade900,
          Colors.black,
        ];
        waveColors = [
          Colors.pinkAccent.withOpacity(0.4),
          Colors.deepPurpleAccent.withOpacity(0.4),
        ];
        break;
      case GameTheme.chalkboard:
        bgFillColor = const Color(0xFF1E352F); // chalkboard green
        mainColors = [
          const Color(0xFF1E352F),
          const Color(0xFF15221F),
        ];
        waveColors = [
          Colors.white.withOpacity(0.05),
          Colors.white.withOpacity(0.02),
        ];
        break;
      case GameTheme.retro:
        bgFillColor = const Color(0xFF110022);
        mainColors = [
          const Color(0xFF220044),
          const Color(0xFF110022),
        ];
        waveColors = [
          Colors.orange.withOpacity(0.4),
          Colors.red.withOpacity(0.3),
        ];
        break;
      case GameTheme.glassmorphism:
        mainColors = [
          const Color(0xFF1A1F3C), // dark indigo replacement for shade950
          Colors.blueGrey.shade900,
          const Color(0xFF3C1A2F).withOpacity(0.8), // dark pink replacement for shade950
        ];
        waveColors = [
          Colors.tealAccent.withOpacity(0.25),
          Colors.purpleAccent.withOpacity(0.25),
        ];
        break;
    }

    if (bgFillColor != Colors.transparent) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = bgFillColor);
    }

    final paint = Paint()
      ..shader = LinearGradient(
        colors: mainColors,
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

    final paint2 = Paint()
      ..shader = LinearGradient(
        colors: waveColors,
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

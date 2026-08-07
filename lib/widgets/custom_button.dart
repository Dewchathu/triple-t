import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:triple_t/providers/sound_provider.dart';
import 'package:triple_t/providers/game_provider.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? bottomColor;
  final Color? darkColor;
  final Color? lightColor;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.bottomColor,
    this.darkColor,
    this.lightColor,
    this.icon,
  });

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _playSound() {
    if (Provider.of<SoundProvider>(context, listen: false).isMusicOn) {
      FlameAudio.play('button_click.mp3', volume: 0.7);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final gameProvider = Provider.of<GameProvider>(context);

    // Default colors based on theme
    Color btnLight = Colors.cyan.shade300;
    Color btnDark = Colors.cyan.shade700;
    Color btnBottom = Colors.blue.shade900;
    Color borderCol = Colors.white.withOpacity(0.4);
    Color glowCol = Colors.cyanAccent.withOpacity(0.6);

    switch (gameProvider.theme) {
      case GameTheme.neon:
        btnLight = const Color(0xFFFF66CC);
        btnDark = const Color(0xFF990099);
        btnBottom = const Color(0xFF330033);
        borderCol = Colors.pinkAccent.withOpacity(0.6);
        glowCol = Colors.pinkAccent.withOpacity(0.8);
        break;
      case GameTheme.chalkboard:
        btnLight = Colors.white.withOpacity(0.15);
        btnDark = Colors.white.withOpacity(0.05);
        btnBottom = Colors.white24;
        borderCol = Colors.white38;
        glowCol = Colors.white10;
        break;
      case GameTheme.retro:
        btnLight = Colors.amber.shade300;
        btnDark = Colors.orange.shade800;
        btnBottom = Colors.red.shade900;
        borderCol = Colors.yellowAccent.withOpacity(0.6);
        glowCol = Colors.amberAccent.withOpacity(0.8);
        break;
      case GameTheme.glassmorphism:
        btnLight = Colors.white.withOpacity(0.18);
        btnDark = Colors.white.withOpacity(0.05);
        btnBottom = Colors.white.withOpacity(0.08);
        borderCol = Colors.white.withOpacity(0.25);
        glowCol = Colors.white.withOpacity(0.2);
        break;
      default:
        break;
    }

    // Apply overrides if provided (and not the boilerplate default blue/cyan colors)
    final isBoilerplate = widget.bottomColor == Colors.blue.shade900 ||
        widget.darkColor == Colors.cyan.shade700 ||
        widget.lightColor == Colors.cyan.shade300;

    final finalLight = (widget.lightColor != null && !isBoilerplate) ? widget.lightColor! : btnLight;
    final finalDark = (widget.darkColor != null && !isBoilerplate) ? widget.darkColor! : btnDark;
    final finalBottom = (widget.bottomColor != null && !isBoilerplate) ? widget.bottomColor! : btnBottom;

    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTapDown: (_) {
                _controller.forward();
                _playSound();
              },
              onTapUp: (_) {
                _controller.reverse();
                widget.onPressed();
              },
              onTapCancel: () => _controller.reverse(),
              child: Stack(
                children: [
                  Container(
                    height: 70,
                    width: size.width * 0.7,
                    decoration: BoxDecoration(
                      color: finalBottom,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: glowCol,
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 2,
                    left: 6,
                    right: 2,
                    bottom: 12,
                    child: Container(
                      height: 65,
                      width: size.width * 0.7,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [finalLight, finalDark],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        border: Border.all(
                          color: borderCol,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: glowCol,
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: Colors.white,
                              size: size.width * 0.06,
                            ),
                            const SizedBox(width: 10),
                          ],
                          Stack(
                            children: [
                              Text(
                                widget.text,
                                style: GoogleFonts.lemon(
                                  fontSize: size.width * 0.05,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                widget.text,
                                style: GoogleFonts.lemon(
                                  fontSize: size.width * 0.05,
                                  foreground: Paint()
                                    ..strokeWidth = 0.8
                                    ..color = Colors.black
                                    ..style = PaintingStyle.stroke,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

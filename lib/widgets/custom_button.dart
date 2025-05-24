import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:triple_t/providers/sound_provider.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color bottomColor;
  final Color darkColor;
  final Color lightColor;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.bottomColor,
    required this.darkColor,
    required this.lightColor,
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
    if (Provider.of<SoundProvider>(context, listen: false).isSoundOn) {
      FlameAudio.play('button_click.mp3', volume: 0.7);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

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
                      color: widget.bottomColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.4),
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
                          colors: [widget.lightColor, widget.darkColor],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyanAccent.withOpacity(0.6),
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

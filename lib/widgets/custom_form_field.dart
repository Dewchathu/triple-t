import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:triple_t/providers/game_provider.dart';

class CustomFormField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const CustomFormField({
    Key? key,
    required this.hintText,
    required this.controller,
    this.validator,
  }) : super(key: key);

  @override
  _CustomFormFieldState createState() => _CustomFormFieldState();
}

class _CustomFormFieldState extends State<CustomFormField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final gameProvider = Provider.of<GameProvider>(context);

    // Default theme colors (Classic)
    Color borderColor = Colors.cyanAccent.withOpacity(0.8);
    Color focusedBorderColor = Colors.cyanAccent;
    Color fillColor = Colors.blue.shade900.withOpacity(0.3);
    Color textColor = Colors.white;

    switch (gameProvider.theme) {
      case GameTheme.classic:
        borderColor = Colors.cyanAccent.withOpacity(0.8);
        focusedBorderColor = Colors.cyanAccent;
        fillColor = Colors.blue.shade900.withOpacity(0.3);
        textColor = Colors.white;
        break;
      case GameTheme.neon:
        borderColor = Colors.pinkAccent.withOpacity(0.6);
        focusedBorderColor = Colors.pinkAccent;
        fillColor = const Color(0xFF1E0B36).withOpacity(0.4);
        textColor = Colors.greenAccent;
        break;
      case GameTheme.chalkboard:
        borderColor = Colors.white38;
        focusedBorderColor = Colors.white70;
        fillColor = Colors.transparent;
        textColor = Colors.white.withOpacity(0.9);
        break;
      case GameTheme.retro:
        borderColor = Colors.amber.withOpacity(0.6);
        focusedBorderColor = Colors.amber;
        fillColor = Colors.orange.shade900.withOpacity(0.2);
        textColor = Colors.yellowAccent;
        break;
      case GameTheme.glassmorphism:
        borderColor = Colors.white.withOpacity(0.15);
        focusedBorderColor = Colors.white.withOpacity(0.4);
        fillColor = Colors.white.withOpacity(0.06);
        textColor = Colors.white;
        break;
    }

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              if (_focusNode.hasFocus)
                BoxShadow(
                  color: focusedBorderColor.withOpacity(0.4),
                  blurRadius: _glowAnimation.value,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            style: GoogleFonts.lemon(
              fontSize: size.width * 0.04,
              color: textColor,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: GoogleFonts.lemon(
                fontSize: size.width * 0.04,
                color: textColor.withOpacity(0.6),
              ),
              filled: true,
              fillColor: fillColor,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: borderColor,
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: focusedBorderColor,
                  width: 3,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Colors.redAccent,
                  width: 2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Colors.redAccent,
                  width: 3,
                ),
              ),
              errorStyle: GoogleFonts.lemon(
                fontSize: size.width * 0.035,
                color: Colors.redAccent,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: size.width * 0.04,
                vertical: size.height * 0.02,
              ),
            ),
            validator: widget.validator,
          ),
        );
      },
    );
  }
}

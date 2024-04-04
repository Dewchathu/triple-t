import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color bottomColor;
  final Color darkColor;
  final Color lightColor;
  const CustomButton({super.key,
    required this.text,
    required this.onPressed,
    required this.bottomColor,
    required this.darkColor,
    required this.lightColor,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return GestureDetector(
      onTap: onPressed,
      child: Stack(
        children: [
          Container(
            height: 65,
            width: size.width*0.7,
            decoration: BoxDecoration(
                color: bottomColor,
                borderRadius: BorderRadius.circular(24)
            ),
          ),
          Positioned(
            top: 1,
            left: 5,
            right: 1,
            bottom: 10,
            child: Container(
              height: 65,
              width: size.width*0.7,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                      colors:[
                        lightColor,
                        darkColor
                      ],
                      begin: Alignment.topCenter,
                      end:  Alignment.bottomCenter
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(.3),
                    width: 1.5,
                  ),

              ),
              child: Center(
                  child: Stack(
                    children: [
                      Text(text, style: GoogleFonts.lemon(
                        fontSize: 25,
                        color: Colors.white,
                      ),
                      ),
                      Text(text, style: GoogleFonts.lemon(
                          fontSize: 25,
                          foreground: Paint()
                            ..strokeWidth = 0.6
                            ..color = Colors.black
                            ..style = PaintingStyle.stroke
                      ),
                      ),
                    ],
                  )
              ),
            ),
          )
        ],
      ),
    );
  }
}

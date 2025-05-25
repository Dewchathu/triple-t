import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:triple_t/widgets/custom_button.dart';

import '../providers/sound_provider.dart';

class ExitDialog {
  static Future<bool?> showExitConfirmationDialog(BuildContext context) async {
    final size = MediaQuery.sizeOf(context);

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(size.width * 0.04),
            decoration: BoxDecoration(
              color: Colors.blue.shade900.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.cyanAccent.withOpacity(0.8),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Exit Confirmation',
                  style: GoogleFonts.lemon(
                    fontSize: size.width * 0.07,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.cyanAccent.withOpacity(0.8),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Text(
                  'Do you want to exit?',
                  style: GoogleFonts.lemon(
                    fontSize: size.width * 0.05,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: size.width * 0.02,
                  runSpacing: size.height * 0.01,
                  children: [
                    SizedBox(
                      width: size.width * 0.25,
                      child: CustomButton(
                        text: 'No',
                        icon: Icons.cancel,
                        onPressed: () {
                          if (Provider.of<SoundProvider>(context, listen: false)
                              .isMusicOn) {
                            FlameAudio.play('button_click.mp3', volume: 0.7);
                          }
                          Navigator.of(context).pop(false);
                        },
                        bottomColor: Colors.blue.shade900,
                        darkColor: Colors.cyan.shade700,
                        lightColor: Colors.cyan.shade300,
                      ),
                    ),
                    SizedBox(
                      width: size.width * 0.25,
                      child: CustomButton(
                        text: 'Yes',
                        icon: Icons.check,
                        onPressed: () {
                          if (Provider.of<SoundProvider>(context, listen: false)
                              .isMusicOn) {
                            FlameAudio.play('button_click.mp3', volume: 0.7);
                          }
                          SystemNavigator.pop();
                        },
                        bottomColor: Colors.blue.shade900,
                        darkColor: Colors.cyan.shade700,
                        lightColor: Colors.cyan.shade300,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:triple_t/widgets/custom_button.dart';
import 'package:triple_t/providers/game_provider.dart';
import '../providers/sound_provider.dart';

class ExitDialog {
  static Future<bool?> showExitConfirmationDialog(BuildContext context) async {
    final size = MediaQuery.sizeOf(context);

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final gameProvider = Provider.of<GameProvider>(context);

        // Theme colors
        Color containerColor = Colors.blue.shade900.withOpacity(0.85);
        Color borderColor = Colors.cyanAccent;
        Color glowColor = Colors.cyanAccent.withOpacity(0.4);
        Color textColor = Colors.white;
        List<Shadow> textShadows = [
          Shadow(blurRadius: 10.0, color: Colors.cyanAccent.withOpacity(0.8))
        ];

        switch (gameProvider.theme) {
          case GameTheme.neon:
            containerColor = const Color(0xFF1E0B36).withOpacity(0.9);
            borderColor = Colors.pinkAccent;
            glowColor = Colors.pinkAccent.withOpacity(0.4);
            textColor = Colors.greenAccent;
            textShadows = [
              Shadow(blurRadius: 10.0, color: Colors.pinkAccent.withOpacity(0.8))
            ];
            break;
          case GameTheme.chalkboard:
            containerColor = const Color(0xFF1E352F).withOpacity(0.95);
            borderColor = Colors.white70;
            glowColor = Colors.white10;
            textColor = Colors.white.withOpacity(0.9);
            textShadows = [];
            break;
          case GameTheme.retro:
            containerColor = const Color(0xFF220044).withOpacity(0.9);
            borderColor = Colors.amber;
            glowColor = Colors.orange.withOpacity(0.4);
            textColor = Colors.yellowAccent;
            textShadows = [
              Shadow(blurRadius: 10.0, color: Colors.redAccent.withOpacity(0.8))
            ];
            break;
          case GameTheme.glassmorphism:
            containerColor = Colors.white.withOpacity(0.12);
            borderColor = Colors.white.withOpacity(0.25);
            glowColor = Colors.white.withOpacity(0.15);
            textColor = Colors.white;
            textShadows = [
              Shadow(blurRadius: 8.0, color: Colors.white.withOpacity(0.3))
            ];
            break;
          default:
            break;
        }

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(size.width * 0.04),
            decoration: BoxDecoration(
              color: containerColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: borderColor,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: glowColor,
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  gameProvider.t('exit_confirm'),
                  style: GoogleFonts.lemon(
                    fontSize: size.width * 0.06,
                    color: textColor,
                    shadows: textShadows,
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Text(
                  gameProvider.t('exit_prompt'),
                  style: GoogleFonts.lemon(
                    fontSize: size.width * 0.045,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: size.height * 0.025),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: gameProvider.t('no'),
                        icon: Icons.cancel,
                        onPressed: () {
                          if (Provider.of<SoundProvider>(context, listen: false)
                              .isMusicOn) {
                            FlameAudio.play('button_click.mp3', volume: 0.7);
                          }
                          Navigator.of(context).pop(false);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomButton(
                        text: gameProvider.t('yes'),
                        icon: Icons.check,
                        onPressed: () {
                          if (Provider.of<SoundProvider>(context, listen: false)
                              .isMusicOn) {
                            FlameAudio.play('button_click.mp3', volume: 0.7);
                          }
                          SystemNavigator.pop();
                        },
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

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:triple_t/actions/moveto_next_screen.dart';
import 'package:triple_t/providers/sound_provider.dart';
import 'package:triple_t/screens/entry_screen.dart';
import 'package:triple_t/widgets/custom_button.dart';
import 'package:triple_t/widgets/wavy_gradient_painter.dart';

import '../widgets/exit_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _titleController;
  late Animation<double> _titleAnimation;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _titleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeInOut),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final soundProvider = Provider.of<SoundProvider>(context);

    return WillPopScope(
      onWillPop: () => _onBackPressed(context),
      child: Scaffold(
        body: Stack(
          children: [
            AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: WavyGradientPainter(_waveController.value),
                );
              },
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _titleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _titleAnimation.value,
                      child: Text(
                        'Triple-T Settings',
                        style: GoogleFonts.lemon(
                          fontSize: size.width * 0.1,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 15.0,
                              color: Colors.cyanAccent.withOpacity(0.8),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: size.height * 0.05),
                AnimatedScale(
                  scale: soundProvider.isMusicOn ? 1.0 : 0.95,
                  duration: const Duration(milliseconds: 200),
                  child: SizedBox(
                    width: size.width * 0.5,
                    child: CustomButton(
                      text: soundProvider.isMusicOn ? 'Music Off' : 'Music On',
                      icon: soundProvider.isMusicOn
                          ? Icons.music_note
                          : Icons.music_off,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        soundProvider.toggleMusic();
                        if (soundProvider.isEffectsOn) {
                          FlameAudio.play('button_click.mp3',
                                  volume: soundProvider.effectsVolume)
                              .catchError((e) {
                            print('Error playing button_click.mp3: $e');
                          });
                        }
                      },
                      bottomColor: Colors.blue.shade900,
                      darkColor: Colors.cyan.shade700,
                      lightColor: Colors.cyan.shade300,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                  child: Row(
                    children: [
                      Icon(Icons.volume_up,
                          color: Colors.white, size: size.width * 0.06),
                      Expanded(
                        child: Semantics(
                          label: 'Music volume',
                          child: Slider(
                            value: soundProvider.musicVolume,
                            onChanged: (value) {
                              soundProvider.setMusicVolume(value);
                            },
                            onChangeEnd: (value) {
                              HapticFeedback.selectionClick();
                            },
                            min: 0.0,
                            max: 1.0,
                            activeColor: Colors.cyanAccent,
                            inactiveColor: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                AnimatedScale(
                  scale: soundProvider.isEffectsOn ? 1.0 : 0.95,
                  duration: const Duration(milliseconds: 200),
                  child: SizedBox(
                    width: size.width * 0.5,
                    child: CustomButton(
                      text: soundProvider.isEffectsOn
                          ? 'Effects Off'
                          : 'Effects On',
                      icon: soundProvider.isEffectsOn
                          ? Icons.vibration
                          : Icons.highlight_off_rounded,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        soundProvider.toggleEffects();
                        if (soundProvider.isEffectsOn) {
                          FlameAudio.play('button_click.mp3',
                                  volume: soundProvider.effectsVolume)
                              .catchError((e) {
                            print('Error playing button_click.mp3: $e');
                          });
                        }
                      },
                      bottomColor: Colors.blue.shade900,
                      darkColor: Colors.cyan.shade700,
                      lightColor: Colors.cyan.shade300,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                  child: Row(
                    children: [
                      Icon(Icons.vibration,
                          color: Colors.white, size: size.width * 0.06),
                      Expanded(
                        child: Semantics(
                          label: 'Effects volume',
                          child: Slider(
                            value: soundProvider.effectsVolume,
                            onChanged: (value) {
                              soundProvider.setEffectsVolume(value);
                              if (soundProvider.isEffectsOn) {
                                FlameAudio.play('button_click.mp3',
                                        volume: value)
                                    .catchError((e) {
                                  print('Error playing button_click.mp3: $e');
                                });
                              }
                            },
                            onChangeEnd: (value) {
                              HapticFeedback.selectionClick();
                            },
                            min: 0.0,
                            max: 1.0,
                            activeColor: Colors.cyanAccent,
                            inactiveColor: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.03),
                AnimatedScale(
                  scale: 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: SizedBox(
                    width: size.width * 0.5,
                    child: CustomButton(
                      text: 'Back',
                      icon: Icons.arrow_back,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        if (soundProvider.isEffectsOn) {
                          FlameAudio.play('button_click.mp3',
                                  volume: soundProvider.effectsVolume)
                              .catchError((e) {
                            print('Error playing button_click.mp3: $e');
                          });
                        }
                        moveToNextScreen(context, const EntryScreen());
                      },
                      bottomColor: Colors.blue.shade900,
                      darkColor: Colors.cyan.shade700,
                      lightColor: Colors.cyan.shade300,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _onBackPressed(BuildContext context) async {
    return await ExitDialog.showExitConfirmationDialog(context) ?? false;
  }
}

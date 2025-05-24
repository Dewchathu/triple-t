import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:triple_t/actions/moveto_next_screen.dart';
import 'package:triple_t/screens/entry_screen.dart';
import 'package:triple_t/widgets/custom_button.dart';
import 'package:triple_t/widgets/exit_dialog.dart';

import '../providers/sound_provider.dart';
import '../widgets/wavy_gradient_painter.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late bool isMusicOn;
  late bool isEffectsOn;
  late AnimationController _titleController;
  late Animation<double> _titleAnimation;
  late AnimationController _waveController;
  double _tempMusicVolume = 0.5; // Temporary value for smooth slider updates
  double _tempEffectsVolume = 0.7;

  @override
  void initState() {
    super.initState();
    final soundProvider = Provider.of<SoundProvider>(context, listen: false);
    isMusicOn = soundProvider.isMusicOn;
    isEffectsOn = soundProvider.isEffectsOn;
    _tempMusicVolume = soundProvider.musicVolume;
    _tempEffectsVolume = soundProvider.effectsVolume;

    // Title animation
    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _titleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeInOut),
    );

    // Wave animation
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
            // Wavy Gradient Background
            AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: WavyGradientPainter(_waveController.value),
                );
              },
            ),
            // Content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Title
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
                // Music Toggle
                AnimatedScale(
                  scale: isMusicOn ? 1.0 : 0.95,
                  duration: const Duration(milliseconds: 200),
                  child: SizedBox(
                    width: size.width * 0.5,
                    child: CustomButton(
                      text: isMusicOn ? 'Music Off' : 'Music On',
                      icon: isMusicOn ? Icons.music_note : Icons.music_off,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        soundProvider.toggleMusic();
                        setState(() {
                          isMusicOn = soundProvider.isMusicOn;
                        });
                        if (soundProvider.isEffectsOn) {
                          FlameAudio.play('button_click.mp3',
                                  volume: soundProvider.effectsVolume)
                              .catchError((e) {
                            print('Error playing button_click.mp3: $e');
                          });
                        }
                        if (isMusicOn) {
                          FlameAudio.bgm.resume();
                        } else {
                          FlameAudio.bgm.pause();
                        }
                      },
                      bottomColor: Colors.blue.shade900,
                      darkColor: Colors.cyan.shade700,
                      lightColor: Colors.cyan.shade300,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                // Music Volume Slider
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
                            value: _tempMusicVolume,
                            onChanged: (value) {
                              setState(() {
                                _tempMusicVolume = value;
                              });
                              soundProvider.setMusicVolume(value);
                              if (isMusicOn) {
                                FlameAudio.bgm
                                    .play('theme.mp3', volume: value)
                                    .catchError((e) {
                                  print('Error playing theme.mp3: $e');
                                  FlameAudio.bgm.resume();
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
                SizedBox(height: size.height * 0.02),
                // Effects Toggle
                AnimatedScale(
                  scale: isEffectsOn ? 1.0 : 0.95,
                  duration: const Duration(milliseconds: 200),
                  child: SizedBox(
                    width: size.width * 0.5,
                    child: CustomButton(
                      text: isEffectsOn ? 'Effects Off' : 'Effects On',
                      icon: isEffectsOn
                          ? Icons.vibration
                          : Icons.highlight_off_rounded,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        soundProvider.toggleEffects();
                        setState(() {
                          isEffectsOn = soundProvider.isEffectsOn;
                        });
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
                // Effects Volume Slider
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
                            value: _tempEffectsVolume,
                            onChanged: (value) {
                              setState(() {
                                _tempEffectsVolume = value;
                              });
                              soundProvider.setEffectsVolume(value);
                              if (isEffectsOn) {
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
                // Back Button
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

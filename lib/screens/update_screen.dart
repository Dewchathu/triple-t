import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:provider/provider.dart';
import 'package:triple_t/providers/sound_provider.dart';
import 'package:triple_t/providers/game_provider.dart';
import 'package:triple_t/screens/entry_screen.dart';
import 'package:triple_t/widgets/custom_button.dart';
import 'package:triple_t/widgets/wavy_gradient_painter.dart';

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({Key? key}) : super(key: key);

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _textController;
  late Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();
    // Wave animation
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    // Text animation
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
    _textAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _performUpdate() async {
    try {
      await InAppUpdate.performImmediateUpdate();
    } catch (e) {
      print('Error performing update: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final soundProvider = Provider.of<SoundProvider>(context, listen: false);
    final gameProvider = Provider.of<GameProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Wavy Gradient Background
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: WavyGradientPainter(_waveController.value, theme: gameProvider.theme),
              );
            },
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Title
                AnimatedBuilder(
                  animation: _textAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _textAnimation.value,
                      child: Column(
                        children: [
                          Text(
                            'Update Available!',
                            style: GoogleFonts.lemon(
                              fontSize: size.width * 0.09,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 15.0,
                                  color: Colors.cyanAccent.withOpacity(0.8),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: size.height * 0.02),
                          Text(
                            'Get the latest Triple-T features',
                            style: GoogleFonts.lemon(
                              fontSize: size.width * 0.045,
                              color: Colors.cyanAccent,
                              shadows: [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.white.withOpacity(0.6),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: size.height * 0.06),
                // Update Button
                CustomButton(
                  text: 'Update Now',
                  icon: Icons.system_update,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    if (soundProvider.isEffectsOn) {
                      FlameAudio.play('button_click.mp3',
                              volume: soundProvider.effectsVolume)
                          .catchError((e) {
                        print('Error playing button_click.mp3: $e');
                      });
                    }
                    _performUpdate();
                  },
                  bottomColor: Colors.blue.shade900,
                  darkColor: Colors.cyan.shade700,
                  lightColor: Colors.cyan.shade300,
                ),
                SizedBox(height: size.height * 0.04),
                // Skip Button
                CustomButton(
                  text: 'Skip',
                  icon: Icons.skip_next,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    if (soundProvider.isEffectsOn) {
                      FlameAudio.play('button_click.mp3',
                              volume: soundProvider.effectsVolume)
                          .catchError((e) {
                        print('Error playing button_click.mp3: $e');
                      });
                    }
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EntryScreen()),
                    );
                  },
                  bottomColor: Colors.blue.shade900,
                  darkColor: Colors.cyan.shade700,
                  lightColor: Colors.cyan.shade300,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

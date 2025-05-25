import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:triple_t/providers/sound_provider.dart';
import 'package:triple_t/screens/play_type_screen.dart';
import 'package:triple_t/screens/settings_screen.dart';
import 'package:triple_t/widgets/custom_button.dart';
import 'package:triple_t/widgets/exit_dialog.dart';
import 'package:triple_t/widgets/wavy_gradient_painter.dart';

class EntryScreen extends StatefulWidget {
  const EntryScreen({Key? key}) : super(key: key);

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen>
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
    final soundProvider = Provider.of<SoundProvider>(context, listen: false);

    return Scaffold(
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
          Container(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Title
                AnimatedBuilder(
                  animation: _titleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _titleAnimation.value,
                      child: Text(
                        'Triple T',
                        style: GoogleFonts.lemon(
                          fontSize: size.width * 0.12,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 15.0,
                              color: Colors.cyanAccent.withOpacity(0.8),
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: size.height * 0.06),
                // Play Button
                CustomButton(
                  text: 'Play',
                  icon: Icons.play_arrow,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    if (soundProvider.isEffectsOn) {
                      FlameAudio.play('button_click.mp3',
                              volume: soundProvider.effectsVolume)
                          .catchError((e) {
                        print('Error playing button_click.mp3: $e');
                      });
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const PlayTypeScreen()),
                    );
                  },
                  bottomColor: Colors.blue.shade900,
                  darkColor: Colors.cyan.shade700,
                  lightColor: Colors.cyan.shade300,
                ),
                SizedBox(height: size.height * 0.04),
                // Settings Button
                CustomButton(
                  text: 'Settings',
                  icon: Icons.settings,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    if (soundProvider.isEffectsOn) {
                      FlameAudio.play('button_click.mp3',
                              volume: soundProvider.effectsVolume)
                          .catchError((e) {
                        print('Error playing button_click.mp3: $e');
                      });
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const SettingsScreen()),
                    );
                  },
                  bottomColor: Colors.blue.shade900,
                  darkColor: Colors.cyan.shade700,
                  lightColor: Colors.cyan.shade300,
                ),
                SizedBox(height: size.height * 0.04),
                // Exit Button
                CustomButton(
                  text: 'Exit',
                  icon: Icons.exit_to_app,
                  onPressed: () async {
                    HapticFeedback.lightImpact();
                    if (soundProvider.isEffectsOn) {
                      FlameAudio.play('button_click.mp3',
                              volume: soundProvider.effectsVolume)
                          .catchError((e) {
                        print('Error playing button_click.mp3: $e');
                      });
                    }
                    final shouldExit = await _onBackPressed(context);
                    if (shouldExit && context.mounted) {
                      Navigator.of(context).pop();
                    }
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

  Future<bool> _onBackPressed(BuildContext context) async {
    return await ExitDialog.showExitConfirmationDialog(context) ?? false;
  }
}

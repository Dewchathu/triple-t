import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triple_t/actions/moveto_next_screen.dart';
import 'package:triple_t/providers/sound_provider.dart';
import 'package:triple_t/screens/entry_screen.dart';
import 'package:triple_t/screens/update_screen.dart';
import 'package:triple_t/widgets/wavy_gradient_painter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _textController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _iconController;
  late Animation<double> _iconScaleAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    final soundProvider = Provider.of<SoundProvider>(context, listen: false);

    // Text animation (fade, scale, slide)
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..forward();
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutBack),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );

    // Icon animation (scale)
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();
    _iconScaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.bounceOut),
    );

    // Glow animation for text
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 10.0, end: 20.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Wave animation
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    // Play intro sound
    if (soundProvider.isEffectsOn) {
      _playIntroSound(soundProvider);
    }

    // Check for updates and navigate
    _checkForUpdates();
  }

  Future<void> _playIntroSound(SoundProvider soundProvider) async {
    try {
      await FlameAudio.play('select.mp3', volume: soundProvider.effectsVolume);
      print('Played transition.mp3');
    } catch (e) {
      print('Failed to play transition.mp3: $e');
    }
  }

  Future<void> _checkForUpdates() async {
    final prefs = await SharedPreferences.getInstance();
    final lastPrompt = prefs.getInt('lastUpdatePrompt') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    const oneDay = 24 * 60 * 60 * 1000; // 24 hours in milliseconds

    // Only prompt once per day
    if (now - lastPrompt < oneDay) {
      _navigateToEntryScreen();
      return;
    }

    try {
      final updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        await prefs.setInt('lastUpdatePrompt', now);
        if (mounted) {
          moveToNextScreen(context, const UpdateScreen());
        }
      } else {
        _navigateToEntryScreen();
      }
    } catch (e) {
      print('Error checking for updates: $e');
      _navigateToEntryScreen();
    }
  }

  void _navigateToEntryScreen() {
    if (mounted) {
      try {
        HapticFeedback.lightImpact();
        moveToNextScreen(context, const EntryScreen());
        print('Navigating to EntryScreen');
      } catch (e) {
        print('Error navigating to EntryScreen: $e');
      }
    }
  }

  @override
  void dispose() {
    // Only pause music if exiting the app
    if (!Navigator.of(context).canPop()) {
      FlameAudio.bgm.pause();
    }
    _textController.dispose();
    _iconController.dispose();
    _glowController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

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
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Tic-Tac-Toe Icon
                AnimatedBuilder(
                  animation: _iconScaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _iconScaleAnimation.value,
                      child: Icon(
                        Icons.grid_3x3,
                        size: size.width * 0.18,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 15.0,
                            color: Colors.cyanAccent.withOpacity(0.8),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: size.height * 0.04),
                // Animated Text with Subtitle
                AnimatedBuilder(
                  animation:
                      Listenable.merge([_textController, _glowController]),
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.translate(
                        offset: _slideAnimation.value * size.height,
                        child: Transform.scale(
                          scale: _scaleAnimation.value,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 1000),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.cyanAccent.withOpacity(0.9),
                                  blurRadius: _glowAnimation.value,
                                  spreadRadius: 2.0,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Triple-T',
                                  style: GoogleFonts.lemon(
                                    fontSize: size.width * 0.10,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        blurRadius: _glowAnimation.value,
                                        color:
                                            Colors.cyanAccent.withOpacity(0.9),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'Neon Tic-Tac-Toe',
                                  style: GoogleFonts.lemon(
                                    fontSize: size.width * 0.045,
                                    color: Colors.cyanAccent,
                                    shadows: [
                                      Shadow(
                                        blurRadius: _glowAnimation.value / 2,
                                        color: Colors.white.withOpacity(0.6),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

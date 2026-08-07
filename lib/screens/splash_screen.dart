import 'dart:ui';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triple_t/actions/moveto_next_screen.dart';
import 'package:triple_t/providers/sound_provider.dart';
import 'package:triple_t/providers/game_provider.dart';
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
  late Animation<double> _iconRotationAnimation;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  late AnimationController _waveController;

  // Loading bar animation
  late AnimationController _loadingController;
  late Animation<double> _loadingProgress;

  @override
  void initState() {
    super.initState();
    final soundProvider = Provider.of<SoundProvider>(context, listen: false);

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutBack),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );

    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();
    _iconScaleAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: const Interval(0.0, 0.7, curve: Curves.elasticOut)),
    );
    _iconRotationAnimation = Tween<double>(begin: -0.5, end: 0.0).animate(
      CurvedAnimation(parent: _iconController, curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack)),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 8.0, end: 24.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();
    _loadingProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOut),
    );

    if (soundProvider.isEffectsOn) {
      _playIntroSound(soundProvider);
    }

    _checkForUpdates();
  }

  Future<void> _playIntroSound(SoundProvider soundProvider) async {
    try {
      await FlameAudio.play('transition.mp3',
          volume: soundProvider.effectsVolume);
    } catch (e) {
      print('Failed to play transition.mp3: $e');
    }
  }

  Future<void> _checkForUpdates() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _finishLoadingAndNavigate(const EntryScreen());
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final lastPrompt = prefs.getInt('lastUpdatePrompt') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    const oneDay = 24 * 60 * 60 * 1000;

    if (now - lastPrompt < oneDay) {
      _finishLoadingAndNavigate(const EntryScreen());
      return;
    }

    try {
      final updateInfo = await InAppUpdate.checkForUpdate().timeout(
        const Duration(seconds: 4),
        onTimeout: () {
          throw Exception('Timeout');
        },
      );
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        await prefs.setInt('lastUpdatePrompt', now);
        _finishLoadingAndNavigate(const UpdateScreen());
      } else {
        _finishLoadingAndNavigate(const EntryScreen());
      }
    } catch (e) {
      _finishLoadingAndNavigate(const EntryScreen());
    }
  }

  void _finishLoadingAndNavigate(Widget targetScreen) {
    _loadingController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          HapticFeedback.lightImpact();
          moveToNextScreen(context, targetScreen);
        }
      }
    });
    if (_loadingController.isCompleted && mounted) {
      HapticFeedback.lightImpact();
      moveToNextScreen(context, targetScreen);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _iconController.dispose();
    _glowController.dispose();
    _waveController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final gameProvider = Provider.of<GameProvider>(context);

    // Apply specific theme color cues to the splash screen
    Color splashAccent = Colors.cyanAccent;
    switch (gameProvider.theme) {
      case GameTheme.classic:
        splashAccent = Colors.cyanAccent;
        break;
      case GameTheme.neon:
        splashAccent = Colors.pinkAccent;
        break;
      case GameTheme.chalkboard:
        splashAccent = Colors.white70;
        break;
      case GameTheme.retro:
        splashAccent = Colors.amber;
        break;
      case GameTheme.glassmorphism:
        splashAccent = Colors.white.withOpacity(0.6);
        break;
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background waves
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: WavyGradientPainter(_waveController.value, theme: gameProvider.theme),
              );
            },
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Glassmorphic Premium Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                        width: size.width * 0.85,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: splashAccent.withOpacity(0.25),
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: splashAccent.withOpacity(0.1),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Animated rotating and scaling logo
                            AnimatedBuilder(
                              animation: _iconController,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _iconRotationAnimation.value * 2 * pi,
                                  child: Transform.scale(
                                    scale: _iconScaleAnimation.value,
                                    child: Icon(
                                      Icons.grid_3x3,
                                      size: size.width * 0.22,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          blurRadius: _glowAnimation.value,
                                          color: splashAccent.withOpacity(0.8),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 25),

                            // Fading and scaling Title
                            AnimatedBuilder(
                              animation: Listenable.merge([_textController, _glowController]),
                              builder: (context, child) {
                                return Opacity(
                                  opacity: _fadeAnimation.value,
                                  child: Transform.scale(
                                    scale: _scaleAnimation.value,
                                    child: Column(
                                      children: [
                                        Text(
                                          'Triple-T',
                                          style: GoogleFonts.lemon(
                                            fontSize: size.width * 0.11,
                                            color: Colors.white,
                                            shadows: [
                                              Shadow(
                                                blurRadius: _glowAnimation.value,
                                                color: splashAccent.withOpacity(0.9),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          'THE ULTIMATE TIC-TAC-TOE',
                                          style: GoogleFonts.lemon(
                                            fontSize: size.width * 0.03,
                                            color: splashAccent,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Premium Smooth Loading Bar
                  SizedBox(
                    width: size.width * 0.6,
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: _loadingProgress,
                          builder: (context, child) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: _loadingProgress.value,
                                minHeight: 6,
                                backgroundColor: Colors.white10,
                                valueColor: AlwaysStoppedAnimation<Color>(splashAccent),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        Text(
                          gameProvider.t('prep_arena'),
                          style: GoogleFonts.lemon(
                            color: Colors.white60,
                            fontSize: size.width * 0.03,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

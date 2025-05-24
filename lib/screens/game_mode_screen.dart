import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:triple_t/actions/moveto_next_screen.dart';
import 'package:triple_t/providers/sound_provider.dart';
import 'package:triple_t/screens/difficulty_selection_screen.dart';
import 'package:triple_t/screens/player_selection.dart';
import 'package:triple_t/widgets/custom_button.dart';
import 'package:triple_t/widgets/wavy_gradient_painter.dart';

class GameModeScreen extends StatefulWidget {
  final String playType;
  final String playerOne;
  final String playerTwo;
  const GameModeScreen({
    Key? key,
    required this.playerOne,
    required this.playerTwo,
    required this.playType,
  }) : super(key: key);

  @override
  State<GameModeScreen> createState() => _GameModeScreenState();
}

class _GameModeScreenState extends State<GameModeScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  late AnimationController _titleController;
  late Animation<double> _titleAnimation;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    if (Provider.of<SoundProvider>(context, listen: false).isMusicOn) {
      FlameAudio.bgm.resume();
    }
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

    // Simulate loading
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _waveController.dispose();
    if (Navigator.of(context).canPop()) {
      FlameAudio.bgm.pause();
    }
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
            child: _isLoading
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
                        strokeWidth: 4,
                      ),
                      SizedBox(height: size.height * 0.02),
                      Text(
                        'Loading...',
                        style: GoogleFonts.lemon(
                          fontSize: size.width * 0.05,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.cyanAccent.withOpacity(0.8),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Title
                      AnimatedBuilder(
                        animation: _titleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _titleAnimation.value,
                            child: Text(
                              'Triple-T',
                              style: GoogleFonts.lemon(
                                fontSize: size.width * 0.12,
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
                      SizedBox(height: size.height * 0.06),
                      // Player Names
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                'Player 1',
                                style: GoogleFonts.lemon(
                                  fontSize: size.width * 0.05,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                widget.playerOne,
                                style: GoogleFonts.lemon(
                                  fontSize: size.width * 0.045,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 10.0,
                                      color: Colors.cyanAccent.withOpacity(0.6),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                'Player 2',
                                style: GoogleFonts.lemon(
                                  fontSize: size.width * 0.05,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                widget.playType == 'single'
                                    ? 'Triple T'
                                    : widget.playerTwo,
                                style: GoogleFonts.lemon(
                                  fontSize: size.width * 0.045,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 10.0,
                                      color: Colors.cyanAccent.withOpacity(0.6),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.06),
                      // Board Size Buttons
                      CustomButton(
                        text: '3x3',
                        icon: Icons.grid_3x3,
                        onPressed: () {
                          moveToNextScreen(
                            context,
                            DifficultySelectionScreen(
                              playType: widget.playType,
                              playerOne: widget.playerOne,
                              playerTwo: widget.playerTwo,
                              boardSize: '3x3',
                            ),
                          );
                        },
                        bottomColor: Colors.blue.shade900,
                        darkColor: Colors.cyan.shade700,
                        lightColor: Colors.cyan.shade300,
                      ),
                      SizedBox(height: size.height * 0.04),
                      CustomButton(
                        text: '4x4',
                        icon: Icons.grid_4x4,
                        onPressed: () {
                          moveToNextScreen(
                            context,
                            DifficultySelectionScreen(
                              playType: widget.playType,
                              playerOne: widget.playerOne,
                              playerTwo: widget.playerTwo,
                              boardSize: '4x4',
                            ),
                          );
                        },
                        bottomColor: Colors.blue.shade900,
                        darkColor: Colors.cyan.shade700,
                        lightColor: Colors.cyan.shade300,
                      ),
                      SizedBox(height: size.height * 0.04),
                      CustomButton(
                        text: '5x5',
                        icon: Icons.grid_on,
                        onPressed: () {
                          moveToNextScreen(
                            context,
                            DifficultySelectionScreen(
                              playType: widget.playType,
                              playerOne: widget.playerOne,
                              playerTwo: widget.playerTwo,
                              boardSize: '5x5',
                            ),
                          );
                        },
                        bottomColor: Colors.blue.shade900,
                        darkColor: Colors.cyan.shade700,
                        lightColor: Colors.cyan.shade300,
                      ),
                      SizedBox(height: size.height * 0.06),
                      CustomButton(
                        text: 'Back',
                        icon: Icons.arrow_back,
                        onPressed: () {
                          moveToNextScreen(
                            context,
                            PlayerSelection(playType: widget.playType),
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

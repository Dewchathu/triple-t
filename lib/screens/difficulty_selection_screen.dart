import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:triple_t/actions/moveto_next_screen.dart';
import 'package:triple_t/providers/sound_provider.dart';
import 'package:triple_t/providers/game_provider.dart';
import 'package:triple_t/screens/single_player_screen.dart' as single;
import 'package:triple_t/screens/two_player_screen.dart' as doubal;
import 'package:triple_t/screens/entry_screen.dart';
import 'package:triple_t/widgets/custom_button.dart';
import 'package:triple_t/widgets/wavy_gradient_painter.dart';

class DifficultySelectionScreen extends StatefulWidget {
  final String playType;
  final String playerOne;
  final String playerTwo;
  final String boardSize; // 3x3, 4x4, 5x5

  const DifficultySelectionScreen({
    Key? key,
    required this.playType,
    required this.playerOne,
    required this.playerTwo,
    required this.boardSize,
  }) : super(key: key);

  @override
  State<DifficultySelectionScreen> createState() =>
      _DifficultySelectionScreenState();
}

class _DifficultySelectionScreenState extends State<DifficultySelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _titleController;
  late Animation<double> _titleAnimation;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    // Title animation
    if (Provider.of<SoundProvider>(context, listen: false).isMusicOn) {
      FlameAudio.bgm.resume();
    }
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

    // Play background music
    if (Provider.of<SoundProvider>(context, listen: false).isMusicOn) {
      FlameAudio.bgm.play('background_music.mp3', volume: 0.5);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _waveController.dispose();
    FlameAudio.bgm.pause();
    super.dispose();
  }

  void startGame(String difficultyLevel) {
    final int crossAxisCount = widget.boardSize == '3x3'
        ? 3
        : widget.boardSize == '4x4'
            ? 4
            : 5;
    final int itemCount = widget.boardSize == '3x3'
        ? 9
        : widget.boardSize == '4x4'
            ? 16
            : 25;

    if (widget.playType == 'double') {
      final difficultyD = doubal.Difficulty(
        name: widget.boardSize,
        itemCount: itemCount,
        crossAxisCount: crossAxisCount,
        playerOne: widget.playerOne,
        playerTwo: widget.playerTwo,
        difficultyLevel: 'N/A', // Two-player mode doesn't use difficulty
      );
      moveToNextScreen(
          context, doubal.TwoPlayerScreen(difficulty: difficultyD));
    } else {
      final difficulty = single.Difficulty(
        name: widget.boardSize,
        itemCount: itemCount,
        crossAxisCount: crossAxisCount,
        playerOne: widget.playerOne,
        playerTwo: widget.playType == 'single' ? 'Triple T' : widget.playerTwo,
        difficultyLevel: difficultyLevel,
      );
      moveToNextScreen(
          context, single.SinglePlayerScreen(difficulty: difficulty));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final gameProvider = Provider.of<GameProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const EntryScreen()),
                (route) => false,
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
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
                Text(
                  widget.playType == 'single'
                      ? 'Select Difficulty'
                      : 'Start Game',
                  style: GoogleFonts.lemon(
                    fontSize: size.width * 0.06,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.cyanAccent.withOpacity(0.6),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.06),
                if (widget.playType == 'single') ...[
                  CustomButton(
                    text: 'Easy',
                    icon: Icons.star_border,
                    onPressed: () => startGame('Easy'),
                    bottomColor: Colors.blue.shade900,
                    darkColor: Colors.cyan.shade700,
                    lightColor: Colors.cyan.shade300,
                  ),
                  SizedBox(height: size.height * 0.04),
                  CustomButton(
                    text: 'Medium',
                    icon: Icons.star_half,
                    onPressed: () => startGame('Medium'),
                    bottomColor: Colors.blue.shade900,
                    darkColor: Colors.cyan.shade700,
                    lightColor: Colors.cyan.shade300,
                  ),
                  SizedBox(height: size.height * 0.04),
                  CustomButton(
                    text: 'Hard',
                    icon: Icons.star,
                    onPressed: () => startGame('Hard'),
                    bottomColor: Colors.blue.shade900,
                    darkColor: Colors.cyan.shade700,
                    lightColor: Colors.cyan.shade300,
                  ),
                ] else ...[
                  CustomButton(
                    text: 'Start',
                    icon: Icons.play_arrow,
                    onPressed: () => startGame('N/A'),
                    bottomColor: Colors.blue.shade900,
                    darkColor: Colors.cyan.shade700,
                    lightColor: Colors.cyan.shade300,
                  ),
                ],
                SizedBox(height: size.height * 0.06),
                CustomButton(
                  text: 'Back',
                  icon: Icons.arrow_back,
                  onPressed: () {
                    Navigator.pop(context);
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

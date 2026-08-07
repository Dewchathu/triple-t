import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:triple_t/actions/moveto_next_screen.dart';
import 'package:triple_t/providers/sound_provider.dart';
import 'package:triple_t/providers/game_provider.dart';
import 'package:triple_t/screens/entry_screen.dart';
import 'package:triple_t/screens/player_selection.dart';
import 'package:triple_t/widgets/custom_button.dart';
import 'package:triple_t/widgets/wavy_gradient_painter.dart';

class PlayTypeScreen extends StatefulWidget {
  const PlayTypeScreen({Key? key}) : super(key: key);

  @override
  State<PlayTypeScreen> createState() => _PlayTypeScreenState();
}

class _PlayTypeScreenState extends State<PlayTypeScreen>
    with TickerProviderStateMixin {
  String playType = '';
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
  }

  @override
  void dispose() {
    _titleController.dispose();
    _waveController.dispose();
    FlameAudio.bgm.pause();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final gameProvider = Provider.of<GameProvider>(context);

    return PopScope(
      canPop: true,
      child: Scaffold(
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
                  CustomButton(
                    text: gameProvider.t('single_play'),
                    icon: Icons.person,
                    onPressed: () {
                      moveToNextScreen(
                          context, const PlayerSelection(playType: 'single'));
                    },
                  ),
                  SizedBox(height: size.height * 0.04),
                  CustomButton(
                    text: gameProvider.t('play_with_friend'),
                    icon: Icons.group,
                    onPressed: () {
                      moveToNextScreen(
                          context, const PlayerSelection(playType: 'double'));
                    },
                  ),
                  SizedBox(height: size.height * 0.06),
                  CustomButton(
                    text: gameProvider.t('back'),
                    icon: Icons.arrow_back,
                    onPressed: () {
                      moveToNextScreen(context, const EntryScreen());
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

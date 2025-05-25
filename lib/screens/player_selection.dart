import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:triple_t/actions/moveto_next_screen.dart';
import 'package:triple_t/providers/sound_provider.dart';
import 'package:triple_t/screens/play_type_screen.dart';
import 'package:triple_t/widgets/custom_button.dart';
import 'package:triple_t/widgets/custom_form_field.dart';
import 'package:triple_t/widgets/wavy_gradient_painter.dart';

import 'game_mode_screen.dart';

class PlayerSelection extends StatefulWidget {
  final String playType;
  const PlayerSelection({Key? key, required this.playType}) : super(key: key);

  @override
  State<PlayerSelection> createState() => _PlayerSelectionState();
}

class _PlayerSelectionState extends State<PlayerSelection>
    with TickerProviderStateMixin {
  late TextEditingController playerOneController;
  late TextEditingController playerTwoController;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late AnimationController _titleController;
  late Animation<double> _titleAnimation;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    playerOneController = TextEditingController();
    playerTwoController = TextEditingController();

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

    // Play background music
    if (Provider.of<SoundProvider>(context, listen: false).isMusicOn) {
      FlameAudio.bgm.play('background_music.mp3', volume: 0.5);
    }
  }

  @override
  void dispose() {
    playerOneController.dispose();
    playerTwoController.dispose();
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
          Padding(
            padding: EdgeInsets.all(size.width * 0.05),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height * 0.1),
                    // Animated Title
                    Center(
                      child: AnimatedBuilder(
                        animation: _titleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _titleAnimation.value,
                            child: Text(
                              'Triple-T',
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
                    ),
                    SizedBox(height: size.height * 0.05),
                    Text(
                      'Enter Your Name:',
                      style: GoogleFonts.lemon(
                        fontSize: size.width * 0.05,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    CustomFormField(
                      hintText: 'Your name',
                      controller: playerOneController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: size.height * 0.05),
                    if (widget.playType == 'double') ...[
                      Text(
                        'Enter Your Friend\'s Name:',
                        style: GoogleFonts.lemon(
                          fontSize: size.width * 0.05,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      CustomFormField(
                        hintText: 'Friend\'s name',
                        controller: playerTwoController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter friend\'s name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: size.height * 0.1),
                    ],
                    Center(
                      child: CustomButton(
                        text: 'Start',
                        icon: Icons.play_arrow,
                        onPressed: () {
                          if (formKey.currentState?.validate() ?? false) {
                            moveToNextScreen(
                              context,
                              GameModeScreen(
                                playerOne: playerOneController.text,
                                playerTwo: widget.playType == 'double'
                                    ? playerTwoController.text
                                    : '',
                                playType: widget.playType,
                              ),
                            );
                          }
                        },
                        bottomColor: Colors.blue.shade900,
                        darkColor: Colors.cyan.shade700,
                        lightColor: Colors.cyan.shade300,
                      ),
                    ),
                    SizedBox(height: size.height * 0.05),
                    Center(
                      child: CustomButton(
                        text: 'Back',
                        icon: Icons.arrow_back,
                        onPressed: () {
                          moveToNextScreen(context, const PlayTypeScreen());
                        },
                        bottomColor: Colors.blue.shade900,
                        darkColor: Colors.cyan.shade700,
                        lightColor: Colors.cyan.shade300,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

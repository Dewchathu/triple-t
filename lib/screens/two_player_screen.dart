import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:triple_t/providers/sound_provider.dart';
import 'package:triple_t/widgets/custom_button.dart';
import 'package:triple_t/widgets/wavy_gradient_painter.dart';

import '../widgets/game_logic.dart';

class Difficulty {
  final String playerOne;
  final String playerTwo;
  final String name;
  final int itemCount;
  final int crossAxisCount;
  final String difficultyLevel;

  const Difficulty({
    required this.playerOne,
    required this.playerTwo,
    required this.name,
    required this.itemCount,
    required this.crossAxisCount,
    required this.difficultyLevel,
  });
}

class TwoPlayerScreen extends StatefulWidget {
  final Difficulty difficulty;

  const TwoPlayerScreen({Key? key, required this.difficulty}) : super(key: key);

  @override
  State<TwoPlayerScreen> createState() => _TwoPlayerScreenState();
}

class _TwoPlayerScreenState extends State<TwoPlayerScreen>
    with TickerProviderStateMixin {
  List<bool> isSelected = [];
  List<String> playerSelection = [];
  int currentPlayer = 1;
  bool hasWinner = false;
  int tapCount = 0;
  late AnimationController _titleController;
  late Animation<double> _titleAnimation;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    resetGame();
    final soundProvider = Provider.of<SoundProvider>(context, listen: false);
    if (soundProvider.isMusicOn && !FlameAudio.bgm.isPlaying) {
      FlameAudio.bgm
          .play('music.ogg', volume: soundProvider.musicVolume)
          .catchError((e) {
        print('Error playing theme.mp3: $e');
      });
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
    // Only pause music if exiting the app, not on navigation
    if (Navigator.of(context).canPop()) {
      FlameAudio.bgm.pause();
    }
    super.dispose();
  }

  void resetGame() {
    setState(() {
      isSelected = List.filled(widget.difficulty.itemCount, false);
      playerSelection = List.filled(widget.difficulty.itemCount, '');
      currentPlayer = 1;
      hasWinner = false;
      tapCount = 0;
    });
  }

  void _checkGameState() {
    final soundProvider = Provider.of<SoundProvider>(context, listen: false);
    if (GameLogic.checkWinner(playerSelection, widget.difficulty.crossAxisCount,
        marksToWin: 3)) {
      setState(() {
        hasWinner = true;
      });
      if (soundProvider.isEffectsOn) {
        FlameAudio.play('win.mp3', volume: soundProvider.effectsVolume)
            .catchError((e) {
          print('Error playing win.mp3: $e');
        });
      }
    } else if (GameLogic.checkDraw(playerSelection)) {
      if (soundProvider.isEffectsOn) {
        FlameAudio.play('draw.mp3', volume: soundProvider.effectsVolume)
            .catchError((e) {
          print('Error playing draw.mp3: $e');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Text(
              widget.difficulty.name,
              style: GoogleFonts.lemon(
                fontSize: size.width * 0.06,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.cyanAccent.withOpacity(0.8),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Text(
              currentPlayer == 1
                  ? 'Next: ${widget.difficulty.playerOne}'
                  : 'Next: ${widget.difficulty.playerTwo}',
              style: GoogleFonts.lemon(
                fontSize: size.width * 0.05,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 5.0,
                    color: Colors.cyanAccent.withOpacity(0.6),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      extendBodyBehindAppBar: true,
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
            children: [
              SizedBox(height: size.height * 0.12),
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
              SizedBox(height: size.height * 0.04),
              // Game Board
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(size.width * 0.05),
                  child: GridView.builder(
                    itemCount: widget.difficulty.itemCount,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: widget.difficulty.crossAxisCount,
                      crossAxisSpacing: size.width * 0.02,
                      mainAxisSpacing: size.height * 0.02,
                    ),
                    itemBuilder: (context, int index) {
                      return _GridTile(
                        index: index,
                        isSelected: isSelected[index],
                        playerSelection: playerSelection[index],
                        onTap: isSelected[index] || hasWinner
                            ? null
                            : () {
                                HapticFeedback.lightImpact();
                                setState(() {
                                  isSelected[index] = true;
                                  playerSelection[index] =
                                      currentPlayer == 1 ? 'O' : 'X';
                                  currentPlayer = currentPlayer == 1 ? 2 : 1;
                                  tapCount++;
                                });
                                final soundProvider =
                                    Provider.of<SoundProvider>(context,
                                        listen: false);
                                if (soundProvider.isEffectsOn) {
                                  FlameAudio.play('move.mp3',
                                          volume: soundProvider.effectsVolume)
                                      .catchError((e) {
                                    print('Error playing move.mp3: $e');
                                  });
                                }
                                _checkGameState();
                              },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          // Winner/Draw Dialog
          if (hasWinner || GameLogic.checkDraw(playerSelection))
            WinnerDialog(
              message: hasWinner
                  ? '${currentPlayer == 1 ? widget.difficulty.playerTwo : widget.difficulty.playerOne} Wins!'
                  : 'It\'s a Draw',
              isDraw: !hasWinner && GameLogic.checkDraw(playerSelection),
              image: hasWinner
                  ? 'assets/images/win.png'
                  : 'assets/images/refresh.png',
              onReplay: () {
                HapticFeedback.lightImpact();
                final soundProvider =
                    Provider.of<SoundProvider>(context, listen: false);
                resetGame();
                if (soundProvider.isEffectsOn) {
                  FlameAudio.play('button_click.mp3',
                          volume: soundProvider.effectsVolume)
                      .catchError((e) {
                    print('Error playing button_click.mp3: $e');
                  });
                }
              },
              onExit: () {
                HapticFeedback.lightImpact();
                final soundProvider =
                    Provider.of<SoundProvider>(context, listen: false);
                if (soundProvider.isEffectsOn) {
                  FlameAudio.play('button_click.mp3',
                          volume: soundProvider.effectsVolume)
                      .catchError((e) {
                    print('Error playing button_click.mp3: $e');
                  });
                }
                Navigator.pop(context);
              },
            ),
        ],
      ),
    );
  }
}

class _GridTile extends StatefulWidget {
  final int index;
  final bool isSelected;
  final String playerSelection;
  final VoidCallback? onTap;

  const _GridTile({
    required this.index,
    required this.isSelected,
    required this.playerSelection,
    this.onTap,
  });

  @override
  _GridTileState createState() => _GridTileState();
}

class _GridTileState extends State<_GridTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => _controller.forward() : null,
      onTapUp: widget.onTap != null ? (_) => _controller.reverse() : null,
      onTapCancel: widget.onTap != null ? () => _controller.reverse() : null,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade900.withOpacity(0.3),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.cyanAccent.withOpacity(0.8),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.playerSelection,
                  style: GoogleFonts.lemon(
                    fontSize: size.width * 0.08,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 5.0,
                        color: Colors.cyanAccent.withOpacity(0.6),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class WinnerDialog extends StatelessWidget {
  final String message;
  final bool isDraw;
  final String image;
  final VoidCallback onReplay;
  final VoidCallback onExit;

  const WinnerDialog({
    Key? key,
    required this.message,
    required this.isDraw,
    required this.image,
    required this.onReplay,
    required this.onExit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(size.width * 0.04),
        decoration: BoxDecoration(
          color: Colors.blue.shade900.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.cyanAccent.withOpacity(0.8),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.cyanAccent.withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isDraw ? 'Try Again' : 'Winner! 🎉',
              style: GoogleFonts.lemon(
                fontSize: size.width * 0.07,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.cyanAccent.withOpacity(0.8),
                  ),
                ],
              ),
            ),
            SizedBox(height: size.height * 0.02),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              transform: Matrix4.identity()..scale(isDraw ? 1.0 : 1.1),
              child: Image.asset(
                image,
                width: size.width * 0.25,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              message,
              style: GoogleFonts.lemon(
                fontSize: size.width * 0.05,
                color: Colors.white,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: size.width * 0.02,
              runSpacing: size.height * 0.01,
              children: [
                SizedBox(
                  width: size.width * 0.25,
                  child: CustomButton(
                    text: 'OK',
                    icon: Icons.check,
                    onPressed: onExit,
                    bottomColor: Colors.blue.shade900,
                    darkColor: Colors.cyan.shade700,
                    lightColor: Colors.cyan.shade300,
                  ),
                ),
                SizedBox(
                  width: size.width * 0.40,
                  child: CustomButton(
                    text: 'Replay',
                    icon: Icons.replay,
                    onPressed: onReplay,
                    bottomColor: Colors.blue.shade900,
                    darkColor: Colors.cyan.shade700,
                    lightColor: Colors.cyan.shade300,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:math';

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:triple_t/providers/sound_provider.dart';
import 'package:triple_t/providers/game_provider.dart';
import 'package:triple_t/widgets/custom_button.dart';
import 'package:triple_t/widgets/wavy_gradient_painter.dart';

import 'package:triple_t/screens/entry_screen.dart';
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

  // Blitz mode timer
  Timer? _blitzTimer;
  int _timeRemaining = 10;

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
    _stopBlitzTimer();
    FlameAudio.bgm.pause();
    super.dispose();
  }

  int get marksToWin => widget.difficulty.crossAxisCount == 3 ? 3 : 4;

  void resetGame() {
    _stopBlitzTimer();
    final gameProvider = Provider.of<GameProvider>(context, listen: false);

    setState(() {
      isSelected = List.filled(widget.difficulty.itemCount, false);
      playerSelection = List.filled(widget.difficulty.itemCount, '');
      currentPlayer = 1;
      hasWinner = false;
      tapCount = 0;

      // Handle Obstacles mode
      if (gameProvider.isObstaclesMode) {
        final rand = Random();
        int obstacleCount = widget.difficulty.crossAxisCount == 3
            ? 1
            : widget.difficulty.crossAxisCount == 4
                ? 2
                : 3;
        int placed = 0;
        while (placed < obstacleCount) {
          int index = rand.nextInt(widget.difficulty.itemCount);
          if (widget.difficulty.crossAxisCount == 3 && index == 4) continue;
          if (playerSelection[index] == '') {
            playerSelection[index] = '#';
            isSelected[index] = true;
            placed++;
            tapCount++;
          }
        }
      }
    });

    if (gameProvider.isBlitzMode) {
      _startBlitzTimer();
    }
  }

  void _startBlitzTimer() {
    _stopBlitzTimer();
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    setState(() {
      _timeRemaining = gameProvider.blitzDurationSeconds;
    });
    _blitzTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
        } else {
          _stopBlitzTimer();
          // Timeout! Toggle current player
          HapticFeedback.heavyImpact();
          currentPlayer = currentPlayer == 1 ? 2 : 1;
          _startBlitzTimer();
        }
      });
    });
  }

  void _stopBlitzTimer() {
    _blitzTimer?.cancel();
    _blitzTimer = null;
  }

  void _checkGameState() {
    final soundProvider = Provider.of<SoundProvider>(context, listen: false);
    final gameProvider = Provider.of<GameProvider>(context, listen: false);

    if (GameLogic.checkWinner(playerSelection, widget.difficulty.crossAxisCount,
        marksToWin: marksToWin)) {
      _stopBlitzTimer();
      setState(() {
        hasWinner = true;
      });
      // The player who just moved is the winner.
      // Since currentPlayer was already toggled in onTap, the winner is the opposite of currentPlayer.
      final winnerId = currentPlayer == 1 ? 'p2' : 'p1';
      gameProvider.recordMultiplayerGame(winnerId);

      if (soundProvider.isEffectsOn) {
        FlameAudio.play('win.mp3', volume: soundProvider.effectsVolume)
            .catchError((e) {
          print('Error playing win.mp3: $e');
        });
      }
    } else if (GameLogic.checkDraw(playerSelection)) {
      _stopBlitzTimer();
      gameProvider.recordMultiplayerGame('draw');
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
    final gameProvider = Provider.of<GameProvider>(context);

    // Apply colors based on theme
    Color tileColor = Colors.blue.shade900.withOpacity(0.3);
    Color borderColor = Colors.cyanAccent.withOpacity(0.8);
    Color textColor = Colors.white;
    List<Shadow> textShadows = [
      Shadow(blurRadius: 5.0, color: Colors.cyanAccent.withOpacity(0.6))
    ];

    switch (gameProvider.theme) {
      case GameTheme.neon:
        tileColor = const Color(0xFF1E0B36).withOpacity(0.4);
        borderColor = Colors.pinkAccent;
        textColor = Colors.greenAccent;
        textShadows = [
          Shadow(blurRadius: 10.0, color: Colors.pinkAccent.withOpacity(0.8))
        ];
        break;
      case GameTheme.chalkboard:
        tileColor = Colors.transparent;
        borderColor = Colors.white70;
        textColor = Colors.white.withOpacity(0.9);
        textShadows = [];
        break;
      case GameTheme.retro:
        tileColor = Colors.orange.shade900.withOpacity(0.2);
        borderColor = Colors.amber;
        textColor = Colors.yellowAccent;
        textShadows = [
          Shadow(blurRadius: 5.0, color: Colors.redAccent.withOpacity(0.8))
        ];
        break;
      case GameTheme.glassmorphism:
        tileColor = Colors.white.withOpacity(0.08);
        borderColor = Colors.white.withOpacity(0.2);
        textColor = Colors.white;
        textShadows = [
          Shadow(blurRadius: 10.0, color: Colors.white.withOpacity(0.4))
        ];
        break;
      default:
        break;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Text(
              widget.difficulty.name,
              style: GoogleFonts.lemon(
                fontSize: size.width * 0.045,
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
                fontSize: size.width * 0.035,
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
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: WavyGradientPainter(_waveController.value, theme: gameProvider.theme),
              );
            },
          ),
          Column(
            children: [
              SizedBox(height: size.height * 0.12),
              AnimatedBuilder(
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
              Text(
                'Align $marksToWin to Win!',
                style: GoogleFonts.lemon(
                  fontSize: 14,
                  color: borderColor.withOpacity(0.9),
                  shadows: textShadows,
                ),
              ),

              // Blitz Mode countdown indicator
              if (gameProvider.isBlitzMode && !hasWinner && !GameLogic.checkDraw(playerSelection))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.timer, color: _timeRemaining < 4 ? Colors.redAccent : Colors.cyanAccent),
                      const SizedBox(width: 8),
                      Text(
                        'Time Left: $_timeRemaining s',
                        style: GoogleFonts.lemon(
                          color: _timeRemaining < 4 ? Colors.redAccent : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

              // Scoreboard Display
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('P1 Wins: ${gameProvider.mpP1Wins}', style: GoogleFonts.lemon(color: Colors.greenAccent, fontSize: 11)),
                      Text('P2 Wins: ${gameProvider.mpP2Wins}', style: GoogleFonts.lemon(color: Colors.cyanAccent, fontSize: 11)),
                      Text('Draws: ${gameProvider.mpDraws}', style: GoogleFonts.lemon(color: Colors.amber, fontSize: 11)),
                    ],
                  ),
                ),
              ),

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
                      final isObstacle = playerSelection[index] == '#';
                      return _GridTile(
                        index: index,
                        isSelected: isSelected[index],
                        playerSelection: playerSelection[index],
                        tileColor: tileColor,
                        borderColor: borderColor,
                        textColor: textColor,
                        textShadows: textShadows,
                        isObstacle: isObstacle,
                        onTap: isSelected[index] || hasWinner || isObstacle
                            ? null
                            : () {
                                _stopBlitzTimer();
                                HapticFeedback.lightImpact();
                                setState(() {
                                  isSelected[index] = true;
                                  playerSelection[index] =
                                      currentPlayer == 1
                                          ? gameProvider.playerOneSymbol
                                          : gameProvider.playerTwoSymbol;
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
                                if (!hasWinner &&
                                    !GameLogic.checkDraw(playerSelection) &&
                                    gameProvider.isBlitzMode) {
                                  _startBlitzTimer();
                                }
                              },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          if (hasWinner || GameLogic.checkDraw(playerSelection))
            WinnerDialog(
              message: hasWinner
                  ? '${currentPlayer == 1 ? widget.difficulty.playerTwo : widget.difficulty.playerOne} Wins!'
                  : 'It\'s a Draw',
              isDraw: !hasWinner && GameLogic.checkDraw(playerSelection),
              image: hasWinner
                  ? 'assets/images/win.png'
                  : 'assets/images/refresh.png',
              borderColor: borderColor,
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
  final Color tileColor;
  final Color borderColor;
  final Color textColor;
  final List<Shadow> textShadows;
  final bool isObstacle;
  final VoidCallback? onTap;

  const _GridTile({
    required this.index,
    required this.isSelected,
    required this.playerSelection,
    required this.tileColor,
    required this.borderColor,
    required this.textColor,
    required this.textShadows,
    required this.isObstacle,
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
                color: widget.isObstacle ? Colors.red.shade900.withOpacity(0.4) : widget.tileColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: widget.isObstacle ? Colors.redAccent : widget.borderColor,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isObstacle ? Colors.redAccent.withOpacity(0.3) : widget.borderColor.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: widget.isObstacle
                    ? Icon(Icons.block, color: Colors.redAccent, size: size.width * 0.08)
                    : Text(
                        widget.playerSelection,
                        style: GoogleFonts.lemon(
                          fontSize: size.width * 0.08,
                          color: widget.textColor,
                          shadows: widget.textShadows,
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
  final Color borderColor;
  final VoidCallback onReplay;
  final VoidCallback onExit;

  const WinnerDialog({
    Key? key,
    required this.message,
    required this.isDraw,
    required this.image,
    required this.borderColor,
    required this.onReplay,
    required this.onExit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final gameProvider = Provider.of<GameProvider>(context);

    // Theme colors
    Color containerColor = Colors.blue.shade900.withOpacity(0.85);
    Color glowColor = borderColor.withOpacity(0.4);
    Color textColor = Colors.white;

    switch (gameProvider.theme) {
      case GameTheme.neon:
        containerColor = const Color(0xFF1E0B36).withOpacity(0.9);
        glowColor = Colors.pinkAccent.withOpacity(0.4);
        textColor = Colors.greenAccent;
        break;
      case GameTheme.chalkboard:
        containerColor = const Color(0xFF1E352F).withOpacity(0.95);
        glowColor = Colors.white10;
        textColor = Colors.white.withOpacity(0.9);
        break;
      case GameTheme.retro:
        containerColor = const Color(0xFF220044).withOpacity(0.9);
        glowColor = Colors.orange.withOpacity(0.4);
        textColor = Colors.yellowAccent;
        break;
      case GameTheme.glassmorphism:
        containerColor = Colors.white.withOpacity(0.12);
        glowColor = Colors.white.withOpacity(0.15);
        textColor = Colors.white;
        break;
      default:
        break;
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(size.width * 0.04),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: glowColor,
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
                color: textColor,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: borderColor,
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

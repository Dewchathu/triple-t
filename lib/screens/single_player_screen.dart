import 'dart:async';
import 'dart:math';

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:triple_t/providers/sound_provider.dart';
import 'package:triple_t/providers/game_provider.dart';
import 'package:triple_t/widgets/custom_button.dart';
import 'package:triple_t/widgets/game_logic.dart';
import 'package:triple_t/screens/entry_screen.dart';
import 'package:triple_t/widgets/wavy_gradient_painter.dart';

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

class SinglePlayerScreen extends StatefulWidget {
  final Difficulty difficulty;

  const SinglePlayerScreen({Key? key, required this.difficulty})
      : super(key: key);

  @override
  State<SinglePlayerScreen> createState() => _SinglePlayerScreenState();
}

class _SinglePlayerScreenState extends State<SinglePlayerScreen>
    with TickerProviderStateMixin {
  List<bool> isSelected = [];
  List<String> playerSelection = [];
  int currentPlayer = 1; // 1 for player, 2 for computer
  String? winner; // Track winner: 'player', 'computer', or null
  int tapCount = 0;
  bool isComputing = false;

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
    _stopBlitzTimer();
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
      winner = null;
      tapCount = 0;
      isComputing = false;

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
          // Don't block the exact center of 3x3 to keep it playable, and avoid duplicate block placements
          if (widget.difficulty.crossAxisCount == 3 && index == 4) continue;
          if (playerSelection[index] == '') {
            playerSelection[index] = '#'; // block cell
            isSelected[index] = true;
            placed++;
            tapCount++;
          }
        }
      }
    });

    GameLogic.validateBoard(playerSelection, widget.difficulty.crossAxisCount);
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
          // Timeout! Forfeit turn to computer
          HapticFeedback.heavyImpact();
          currentPlayer = 2;
          computerMove();
        }
      });
    });
  }

  void _stopBlitzTimer() {
    _blitzTimer?.cancel();
    _blitzTimer = null;
  }

  Future<void> computerMove() async {
    _stopBlitzTimer();
    if (winner != null ||
        tapCount >= widget.difficulty.itemCount ||
        isComputing) return;

    setState(() {
      isComputing = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    int move = -1;
    switch (widget.difficulty.difficultyLevel) {
      case 'Easy':
        move = _randomMove();
        break;
      case 'Medium':
        move = _mediumMove();
        break;
      case 'Hard':
        try {
          move = await compute(_computeHardMove, {
            'board': List<String>.from(playerSelection),
            'crossAxisCount': widget.difficulty.crossAxisCount,
            'marksToWin': marksToWin,
            'p1': gameProvider.playerOneSymbol,
            'p2': gameProvider.playerTwoSymbol,
          }).timeout(const Duration(seconds: 2), onTimeout: () {
            print('Hard move timed out, falling back to Medium move');
            return _mediumMove();
          });
        } catch (e) {
          print('Error computing Hard move: $e');
          move = _mediumMove();
        }
        break;
    }

    if (move != -1 && mounted) {
      setState(() {
        isSelected[move] = true;
        playerSelection[move] = gameProvider.playerTwoSymbol;
        currentPlayer = 1;
        tapCount++;
        isComputing = false;
      });
      final soundProvider = Provider.of<SoundProvider>(context, listen: false);
      if (soundProvider.isEffectsOn) {
        FlameAudio.play('move.mp3', volume: soundProvider.effectsVolume)
            .catchError((e) {
          print('Error playing move.mp3: $e');
        });
      }
      _checkGameState();
      if (winner == null && gameProvider.isBlitzMode) {
        _startBlitzTimer();
      }
    } else {
      setState(() {
        isComputing = false;
      });
    }
  }

  void _checkGameState() {
    final soundProvider = Provider.of<SoundProvider>(context, listen: false);
    final gameProvider = Provider.of<GameProvider>(context, listen: false);

    if (GameLogic.checkWinner(playerSelection, widget.difficulty.crossAxisCount,
        marksToWin: marksToWin)) {
      _stopBlitzTimer();
      setState(() {
        winner = currentPlayer == 1 ? 'computer' : 'player';
      });
      gameProvider.recordSinglePlayerGame(winner!, widget.difficulty.difficultyLevel);
      if (soundProvider.isEffectsOn) {
        FlameAudio.play(winner == 'player' ? 'win.mp3' : 'lost.mp3',
                volume: soundProvider.effectsVolume)
            .catchError((e) {
          print(
              'Error playing ${winner == 'player' ? 'win.mp3' : 'lost.mp3'}: $e');
        });
      }
    } else if (GameLogic.checkDraw(playerSelection)) {
      _stopBlitzTimer();
      gameProvider.recordSinglePlayerGame('draw', widget.difficulty.difficultyLevel);
      if (soundProvider.isEffectsOn) {
        FlameAudio.play('draw.mp3', volume: soundProvider.effectsVolume)
            .catchError((e) {
          print('Error playing draw.mp3: $e');
        });
      }
    }
  }

  int _randomMove() {
    final random = Random();
    List<int> availableMoves = [];
    for (int i = 0; i < playerSelection.length; i++) {
      if (playerSelection[i] == '') {
        availableMoves.add(i);
      }
    }
    return availableMoves.isNotEmpty
        ? availableMoves[random.nextInt(availableMoves.length)]
        : -1;
  }

  int _mediumMove() {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    for (int i = 0; i < playerSelection.length; i++) {
      if (playerSelection[i] == '') {
        playerSelection[i] = gameProvider.playerTwoSymbol;
        if (GameLogic.checkWinner(
            playerSelection, widget.difficulty.crossAxisCount,
            marksToWin: marksToWin)) {
          playerSelection[i] = '';
          return i;
        }
        playerSelection[i] = '';
      }
    }
    for (int i = 0; i < playerSelection.length; i++) {
      if (playerSelection[i] == '') {
        playerSelection[i] = gameProvider.playerOneSymbol;
        if (GameLogic.checkWinner(
            playerSelection, widget.difficulty.crossAxisCount,
            marksToWin: marksToWin)) {
          playerSelection[i] = '';
          return i;
        }
        playerSelection[i] = '';
      }
    }
    return _randomMove();
  }

  static int _computeHardMove(Map<String, dynamic> params) {
    final List<String> board = params['board'];
    final int crossAxisCount = params['crossAxisCount'];
    final int marksToWin = params['marksToWin'];
    final String p1 = params['p1'];
    final String p2 = params['p2'];
    final stopwatch = Stopwatch()..start();

    int bestScore = -10000;
    List<int> bestMoves = [];
    List<int> moves = [];

    List<int> winningMoves = [];
    List<int> blockingMoves = [];
    int size = crossAxisCount;
    int center = (size * size) ~/ 2;
    List<int> corners = [0, size - 1, size * (size - 1), size * size - 1];
    List<int> others = [];

    for (int i = 0; i < board.length; i++) {
      if (board[i] == '') {
        board[i] = p2;
        if (GameLogic.checkWinner(board, crossAxisCount,
            marksToWin: marksToWin)) {
          board[i] = '';
          winningMoves.add(i);
          continue;
        }
        board[i] = '';
        board[i] = p1;
        if (GameLogic.checkWinner(board, crossAxisCount,
            marksToWin: marksToWin)) {
          board[i] = '';
          blockingMoves.add(i);
          continue;
        }
        board[i] = '';
        if (i == center) {
          moves.add(i);
        } else if (corners.contains(i)) {
          moves.add(i);
        } else {
          others.add(i);
        }
      }
    }

    moves = [...winningMoves, ...blockingMoves, ...moves, ...others];

    int maxDepth = crossAxisCount == 3
        ? 10
        : crossAxisCount == 4
            ? 5
            : 3;

    for (int i in moves) {
      board[i] = p2;
      int score = _minimax(
          board, 0, false, -10000, 10000, maxDepth, crossAxisCount, marksToWin, p1, p2);
      board[i] = '';
      if (score > bestScore) {
        bestScore = score;
        bestMoves = [i];
      } else if (score == bestScore) {
        bestMoves.add(i);
      }
    }

    print(
        'Hard move computed in ${stopwatch.elapsedMilliseconds}ms, best score: $bestScore, move: ${bestMoves.isNotEmpty ? bestMoves : -1}');
    final random = Random();
    return bestMoves.isNotEmpty
        ? bestMoves[random.nextInt(bestMoves.length)]
        : -1;
  }

  static int _minimax(List<String> board, int depth, bool isMaximizing,
      int alpha, int beta, int maxDepth, int crossAxisCount, int marksToWin, String p1, String p2) {
    if (depth >= maxDepth) {
      return 0;
    }

    if (GameLogic.checkWinner(board, crossAxisCount, marksToWin: marksToWin)) {
      return isMaximizing ? -10 + depth : 10 - depth;
    } else if (GameLogic.checkDraw(board)) {
      return 0;
    }

    if (isMaximizing) {
      int bestScore = -10000;
      for (int i = 0; i < board.length; i++) {
        if (board[i] == '') {
          board[i] = p2;
          int score = _minimax(board, depth + 1, false, alpha, beta, maxDepth,
              crossAxisCount, marksToWin, p1, p2);
          board[i] = '';
          bestScore = max(score, bestScore);
          alpha = max(alpha, bestScore);
          if (beta <= alpha) {
            break;
          }
        }
      }
      return bestScore;
    } else {
      int bestScore = 10000;
      for (int i = 0; i < board.length; i++) {
        if (board[i] == '') {
          board[i] = p1;
          int score = _minimax(board, depth + 1, true, alpha, beta, maxDepth,
              crossAxisCount, marksToWin, p1, p2);
          board[i] = '';
          bestScore = min(score, bestScore);
          beta = min(beta, bestScore);
          if (beta <= alpha) {
            break;
          }
        }
      }
      return bestScore;
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
                  : isComputing
                      ? 'Thinking...'
                      : 'Next: AI',
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
              if (gameProvider.isBlitzMode && currentPlayer == 1 && winner == null)
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
                      Text('Wins: ${gameProvider.spWins}', style: GoogleFonts.lemon(color: Colors.greenAccent, fontSize: 11)),
                      Text('Losses: ${gameProvider.spLosses}', style: GoogleFonts.lemon(color: Colors.redAccent, fontSize: 11)),
                      Text('Streak: ${gameProvider.spCurrentStreak}', style: GoogleFonts.lemon(color: Colors.amber, fontSize: 11)),
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
                        onTap: isComputing ||
                                isSelected[index] ||
                                currentPlayer != 1 ||
                                winner != null ||
                                isObstacle
                            ? null
                            : () {
                                _stopBlitzTimer();
                                HapticFeedback.lightImpact();
                                setState(() {
                                  isSelected[index] = true;
                                  playerSelection[index] = gameProvider.playerOneSymbol;
                                  currentPlayer = 2;
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
                                if (winner == null &&
                                    tapCount < widget.difficulty.itemCount) {
                                  computerMove();
                                }
                              },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          if (winner != null || GameLogic.checkDraw(playerSelection))
            WinnerDialog(
              outcome: winner == 'player'
                  ? GameOutcome.win
                  : winner == 'computer'
                      ? GameOutcome.lose
                      : GameOutcome.draw,
              playerName: widget.difficulty.playerOne,
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

enum GameOutcome { win, lose, draw }

class WinnerDialog extends StatelessWidget {
  final GameOutcome outcome;
  final String playerName;
  final Color borderColor;
  final VoidCallback onReplay;
  final VoidCallback onExit;

  const WinnerDialog({
    Key? key,
    required this.outcome,
    required this.playerName,
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

    String title;
    String message;
    String image;
    switch (outcome) {
      case GameOutcome.win:
        title = 'Winner! 🎉';
        message = '$playerName Wins!';
        image = 'assets/images/win.png';
        break;
      case GameOutcome.lose:
        title = 'You Lost!';
        message = 'Triple T Wins!';
        image = 'assets/images/lost.png';
        break;
      case GameOutcome.draw:
        title = 'Try Again';
        message = 'It\'s a Draw';
        image = 'assets/images/refresh.png';
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
              title,
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
              transform: Matrix4.identity()
                ..scale(outcome == GameOutcome.draw ? 1.0 : 1.1),
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

import 'package:flutter/material.dart';

import '../widgets/game_logic.dart';

class Difficulty {
  final String playerOne;
  final String playerTwo;
  final String name;
  final int itemCount;
  final int crossAxisCount;

  const Difficulty({
    required this.playerOne,
    required this.playerTwo,
    required this.name,
    required this.itemCount,
    required this.crossAxisCount,
  });
}

class TwoPlayerScreen extends StatefulWidget {
  final Difficulty difficulty;

  const TwoPlayerScreen({Key? key, required this.difficulty}) : super(key: key);

  @override
  State<TwoPlayerScreen> createState() => _TwoPlayerScreenState();
}

class _TwoPlayerScreenState extends State<TwoPlayerScreen> {
  final List<bool> isSelected = [];
  final List<String> playerSelection = [];
  int currentPlayer = 1;
  bool hasWinner = false;
  int tapCount = 0;

  @override
  void initState() {
    super.initState();
    isSelected.addAll(List.filled(widget.difficulty.itemCount, false));
    playerSelection.addAll(List.filled(widget.difficulty.itemCount, ''));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.difficulty.name),
            const Spacer(),
            currentPlayer == 1
                ? Text('Next Move: ${widget.difficulty.playerOne}', style: const TextStyle(fontSize: 22))
                : Text('Next Move: ${widget.difficulty.playerTwo}', style: const TextStyle(fontSize: 22)),
          ],
        ),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.blue,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.blue, Colors.purple],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft)),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Stack(
              children: [
                GridView.builder(
                    itemCount: widget.difficulty.itemCount,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: widget.difficulty.crossAxisCount),
                    itemBuilder: (context, int index) {
                      return Padding(
                        padding: const EdgeInsets.all(4),
                        child: GestureDetector(
                          onTap: () {
                            if (!isSelected[index]) {
                              setState(() {
                                isSelected[index] = true;
                                playerSelection[index] = currentPlayer == 1 ? 'O' : 'X';
                                currentPlayer = currentPlayer == 1 ? 2 : 1;
                                tapCount++;
                              });
                            }
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFF303030),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.2),
                                  blurRadius: 1,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                playerSelection[index],
                                style: const TextStyle(fontSize: 25),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                if (checkWinner(playerSelection, widget.difficulty.crossAxisCount))
                  Center(
                    child: WinnerDialog(
                      message: '${currentPlayer == 1 ? widget.difficulty.playerTwo : widget.difficulty.playerOne} Wins!',
                      isDraw: false,
                      image: 'assets/images/win.png',
                    ),
                  ),
                if (!checkWinner(playerSelection, widget.difficulty.crossAxisCount) &&
                    tapCount == (widget.difficulty.itemCount - 1))
                  const Center(
                    child: WinnerDialog(
                      message: 'It\'s Draw',
                      isDraw: true,
                      image: 'assets/images/refresh.png',
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WinnerDialog extends StatelessWidget {
  final String message;
  final bool isDraw;
  final String image;

  const WinnerDialog({Key? key, required this.message, required this.isDraw, required this.image})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return AlertDialog(
      title: Center(child: Text(isDraw ? 'Try Again' : 'Winner!🎉')), // Title based on draw flag
      content: SizedBox(
        height: size.height / 5,
        child: Column(
          children: [
            Image.asset(image, width: 100),
            const SizedBox(height: 20),
            Text(message, style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close the dialog
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

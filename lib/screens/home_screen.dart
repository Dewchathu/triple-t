import 'package:flutter/material.dart';

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

class HomeScreen extends StatefulWidget {
  final Difficulty difficulty;

  const HomeScreen({Key? key, required this.difficulty}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
                ? Text('Current Player: ${widget.difficulty.playerOne}', style: const TextStyle(fontSize: 22),)
                :Text('Current Player: ${widget.difficulty.playerTwo}',style: const TextStyle(fontSize: 22),),
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
                end: Alignment.bottomLeft
            )
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Stack(
              children: [
                GridView.builder(
                    itemCount: widget.difficulty.itemCount,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: widget.difficulty.crossAxisCount
                    ),
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
                                  offset: const Offset(0,0),
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
                if (checkWinner())
                  Center(child: WinnerDialog(message: '${currentPlayer == 1 ? widget.difficulty.playerTwo : widget.difficulty.playerOne} Wins!', isDraw: false, image: 'assets/images/win.png',),),
                if(!checkWinner() && tapCount == (widget.difficulty.itemCount-1))
                  const Center(child: WinnerDialog(message: 'It\'s Draw', isDraw: true, image: 'assets/images/refresh.png',),),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool checkWinner() {
    final List<List<int>> winningConditions;
    switch (widget.difficulty.itemCount) {
      case 9: // Easy (3x3)
        winningConditions = [
          [0, 1, 2], // Row 1
          [3, 4, 5], // Row 2
          [6, 7, 8], // Row 3
          [0, 3, 6], // Column 1
          [1, 4, 7], // Column 2
          [2, 5, 8], // Column 3
          [0, 4, 8], // Diagonal 1
          [2, 4, 6], // Diagonal 2
        ];
        break;
      case 16: // Medium (4x4)
        winningConditions = [
          [0, 1, 2, 3], // Row 1
          [4, 5, 6, 7], // Row 2
          [8, 9, 10, 11], // Row 3
          [12, 13, 14, 15], // Row 4
          [0, 4, 8, 12], // Column 1
          [1, 5, 9, 13], // Column 2
          [2, 6, 10, 14], // Column 3
          [3, 7, 11, 15], // Column 4
          [0, 5, 10, 15], // Diagonal 1
          [3, 6, 9, 12], // Diagonal 2
        ];
        break;
      case 25: // Hard (5x5)
        winningConditions = [
          [0, 1, 2, 3, 4], // Row 1
          [5, 6, 7, 8, 9], // Row 2
          [10, 11, 12, 13, 14], // Row 3
          [15, 16, 17, 18, 19], // Row 4
          [20, 21, 22, 23, 24], // Row 5
          [0, 5, 10, 15, 20], // Column 1
          [1, 6, 11, 16, 21], // Column 2
          [2, 7, 12, 17, 22], // Column 3
          [3, 8, 13, 18, 23], // Column 4
          [4, 9, 14, 19, 24], // Column 5
          [0, 6, 12, 18, 24], // Diagonal 1
          [4, 8, 12, 16, 20], // Diagonal 2
        ];
        break;
      default:
        throw Exception('Unsupported difficulty');
    }

    for (var condition in winningConditions) {
      final player = playerSelection[condition[0]];
      if (player.isNotEmpty &&
          condition.every((index) => playerSelection[index] == player)) {
        return true;
      }
    }

    bool isDraw = true;
    for (var selection in playerSelection) {
      if (selection.isEmpty) {
        isDraw = false;
        break;
      }
    }
    return isDraw;
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
        height: size.height/5,
          child: Column(
              children: [
                Image.asset(image, width: 100,),
                const SizedBox(height: 20),
                Text(message, style: const TextStyle(fontSize: 15),),
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

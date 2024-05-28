class WinningConditions {
  static List<List<int>> getWinningConditions(int crossAxisCount) {
    switch (crossAxisCount) {
      case 3: // Easy (3x3)
        return [
          [0, 1, 2], // Row 1
          [3, 4, 5], // Row 2
          [6, 7, 8], // Row 3
          [0, 3, 6], // Column 1
          [1, 4, 7], // Column 2
          [2, 5, 8], // Column 3
          [0, 4, 8], // Diagonal 1
          [2, 4, 6], // Diagonal 2
        ];
      case 4: // Medium (4x4)
        return [
          [0, 1, 2], [1, 2, 3], // Row 1
          [4, 5, 6], [5, 6, 7], // Row 2
          [8, 9, 10], [9, 10, 11], // Row 3
          [12, 13, 14], [13, 14, 15], // Row 4
          [0, 4, 8], [4, 8, 12], // Column 1
          [1, 5, 9], [5, 9, 13], // Column 2
          [2, 6, 10], [6, 10, 14], // Column 3
          [3, 7, 11], [7, 11, 15], // Column 4
          [0, 5, 10], [1, 6, 11], [4, 9, 14], [5, 10, 15], // Diagonals
          [3, 6, 9], [2, 5, 8], [7, 10, 13], [6, 9, 12], // Diagonals
        ];
      case 5: // Hard (5x5)
        return [
          [0, 1, 2], [1, 2, 3], [2, 3, 4], // Row 1
          [5, 6, 7], [6, 7, 8], [7, 8, 9], // Row 2
          [10, 11, 12], [11, 12, 13], [12, 13, 14], // Row 3
          [15, 16, 17], [16, 17, 18], [17, 18, 19], // Row 4
          [20, 21, 22], [21, 22, 23], [22, 23, 24], // Row 5
          [0, 5, 10], [5, 10, 15], [10, 15, 20], // Column 1
          [1, 6, 11], [6, 11, 16], [11, 16, 21], // Column 2
          [2, 7, 12], [7, 12, 17], [12, 17, 22], // Column 3
          [3, 8, 13], [8, 13, 18], [13, 18, 23], // Column 4
          [4, 9, 14], [9, 14, 19], [14, 19, 24], // Column 5
          [0, 6, 12], [6, 12, 18], [12, 18, 24], // Diagonals
          [4, 8, 12], [8, 12, 16], [12, 16, 20], // Diagonals
        ];
      default:
        throw Exception('Unsupported difficulty');
    }
  }
}

bool checkWinner(List<String> playerSelection, int crossAxisCount) {
  final List<List<int>> winningConditions = WinningConditions.getWinningConditions(crossAxisCount);

  for (var condition in winningConditions) {
    final player = playerSelection[condition[0]];
    if (player.isNotEmpty && condition.every((index) => playerSelection[index] == player)) {
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

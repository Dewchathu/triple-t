/// Provides game logic utilities for Tic-Tac-Toe, including winning conditions and draw checks.
class GameLogic {
  /// Generates winning conditions for a Tic-Tac-Toe board of the given size.
  /// [crossAxisCount] is the number of cells per row/column (e.g., 3 for 3x3, 4 for 4x4).
  /// [marksToWin] specifies how many consecutive marks are needed to win.
  static List<List<int>> getWinningConditions(int crossAxisCount,
      {int? marksToWin}) {
    // Default to requiring a full row/column/diagonal unless specified
    marksToWin ??= crossAxisCount;
    if (marksToWin > crossAxisCount) {
      throw Exception('marksToWin cannot be greater than crossAxisCount');
    }

    List<List<int>> conditions = [];

    // Helper to generate consecutive indices
    void addConsecutiveConditions(int start, int step, int count) {
      for (int i = 0; i <= count - marksToWin!; i++) {
        List<int> condition = [];
        for (int j = 0; j < marksToWin; j++) {
          condition.add(start + i * step + j * step);
        }
        conditions.add(condition);
      }
    }

    // Rows
    for (int row = 0; row < crossAxisCount; row++) {
      addConsecutiveConditions(row * crossAxisCount, 1, crossAxisCount);
    }

    // Columns
    for (int col = 0; col < crossAxisCount; col++) {
      addConsecutiveConditions(col, crossAxisCount, crossAxisCount);
    }

    // Main diagonal (top-left to bottom-right)
    if (marksToWin <= crossAxisCount) {
      for (int i = 0; i <= crossAxisCount - marksToWin; i++) {
        for (int j = 0; j <= crossAxisCount - marksToWin; j++) {
          List<int> condition = [];
          for (int k = 0; k < marksToWin; k++) {
            condition.add((i + k) * crossAxisCount + (j + k));
          }
          conditions.add(condition);
        }
      }
    }

    // Anti-diagonal (top-right to bottom-left)
    if (marksToWin <= crossAxisCount) {
      for (int i = 0; i <= crossAxisCount - marksToWin; i++) {
        for (int j = marksToWin - 1; j < crossAxisCount; j++) {
          List<int> condition = [];
          for (int k = 0; k < marksToWin; k++) {
            condition.add((i + k) * crossAxisCount + (j - k));
          }
          conditions.add(condition);
        }
      }
    }

    return conditions;
  }

  /// Checks if there is a winner on the board.
  /// [playerSelection] is the list of board cell states ('', 'X', or 'O').
  /// [crossAxisCount] is the number of cells per row/column.
  /// [marksToWin] specifies how many consecutive marks are needed to win.
  /// Returns true if a player has won, false otherwise.
  static bool checkWinner(List<String> playerSelection, int crossAxisCount,
      {int? marksToWin}) {
    final conditions =
        getWinningConditions(crossAxisCount, marksToWin: marksToWin);

    for (var condition in conditions) {
      final player = playerSelection[condition[0]];
      if (player.isNotEmpty &&
          condition.every((index) => playerSelection[index] == player)) {
        return true;
      }
    }
    return false;
  }

  /// Checks if the game is a draw (board is full with no winner).
  /// [playerSelection] is the list of board cell states.
  /// Returns true if the game is a draw, false otherwise.
  static bool checkDraw(List<String> playerSelection) {
    return playerSelection.every((cell) => cell.isNotEmpty);
  }

  /// Validates the board configuration.
  /// Ensures the board size matches the expected size for the given [crossAxisCount].
  /// Throws an exception if the board is invalid.
  static void validateBoard(List<String> playerSelection, int crossAxisCount) {
    final expectedSize = crossAxisCount * crossAxisCount;
    if (playerSelection.length != expectedSize) {
      throw Exception(
          'Board size (${playerSelection.length}) does not match expected size ($expectedSize)');
    }
  }
}

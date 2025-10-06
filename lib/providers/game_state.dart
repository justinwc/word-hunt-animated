import 'dart:math';

class BoardState {

  late List<List<String>> board;
  final int boardDimensions = 4;

  BoardState() {
    setBoard();
  }

  void setBoard() {
    final random = Random();
    board = List.generate(boardDimensions, (_) {
      return List.generate(boardDimensions, (_) {
        // ASCII A–Z
        return String.fromCharCode(65 + random.nextInt(26));
      });
    });
  }
}
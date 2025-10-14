import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:word_hunt/services/word_list_service.dart';

// Helper class for tile positions
class TilePos {
  final int row;
  final int col;
  TilePos(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      other is TilePos && other.row == row && other.col == col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;
}

class GameState extends ChangeNotifier {
  // Board configuration
  late List<List<String>> board;
  final int boardDimensions = 4;

  // Tile Selection States
  final List<TilePos> selectedTiles = [];
  final Set<TilePos> selectedTilesSet = {};

  final Set<String> scoredWords = {};

  // Game state
  int score = 0;
  int timeRemaining = 120;
  bool isGameOver = false;
  Timer? _timer;

  GameState() {
    _initializeBoard();
  }

  // Board methods
  void _initializeBoard() {
    final random = Random();
    board = List.generate(boardDimensions, (_) {
      return List.generate(boardDimensions, (_) {
        return String.fromCharCode(65 + random.nextInt(26));
      });
    });
  }

  void resetBoard() {
    _initializeBoard();
    notifyListeners();
  }

  // Selection methods
  void selectTile(TilePos pos) {
    if (!selectedTilesSet.contains(pos)) {
      selectedTiles.add(pos);
      selectedTilesSet.add(pos);
      notifyListeners();
    }
  }

  bool isTileSelected(TilePos pos) {
    return selectedTilesSet.contains(pos);
  }

  String getCurrentWord() {
    return selectedTiles.map((p) => board[p.row][p.col]).join();
  }

  void endSelection() {
    if (selectedTiles.isNotEmpty) {
      final word = getCurrentWord();

      if(scoredWords.contains(word)) {
        debugPrint('Word already scored: $word');
      }
      else if (WordListService.isValidWord(word)) {
        debugPrint('Valid word: $word');
        scoredWords.add(word);
        _addScore(word);
      } else {
        debugPrint('Invalid word: $word');
      }
    }

    clearSelection();
  }

  void clearSelection() {
    selectedTiles.clear();
    selectedTilesSet.clear();
    notifyListeners();
  }

  // Score calculation
  void _addScore(String word) {
    int points;
    switch (word.length) {
      case 3:
        points = 100;
        break;
      case 4:
        points = 400;
        break;
      case 5:
        points = 800;
        break;
      case 6:
        points = 1400;
        break;
      default:
        points = (word.length - 6) * 400 + 1400;
        break;
    }
    score += points;
    notifyListeners();
  }

  // Timer methods
  void startTimer() {
    timeRemaining = 20;
    isGameOver = false;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeRemaining > 0) {
        timeRemaining--;
        notifyListeners();
      } else {
        timer.cancel();
        _onTimeUp();
      }
    });
  }

  void _onTimeUp() {
    isGameOver = true;
    notifyListeners();
  }

  void stopTimer() {
    _timer?.cancel();
  }

  // Game restart
  void restartGame() {
    score = 0;
    scoredWords.clear();
    clearSelection();
    resetBoard();
    startTimer();
  }

  // Cleanup
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Getters for UI
  String get formattedTime {
    final minutes = (timeRemaining ~/ 60).toString().padLeft(1, '0');
    final seconds = (timeRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

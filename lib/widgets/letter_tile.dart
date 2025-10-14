import 'package:flutter/material.dart';
import 'package:word_hunt/providers/game_state.dart';

class LetterTile extends StatelessWidget {
  final String letter;
  final bool isSelected;
  final WordState wordState;
  final int row;
  final int col;
  final void Function(int row, int col)? onTapDown;
  final VoidCallback? onTap;

  const LetterTile({
    super.key,
    required this.letter,
    required this.row,
    required this.col,
    this.isSelected = false,
    this.wordState = WordState.invalid,
    this.onTapDown,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (onTapDown != null) onTapDown!(row, col);
      },

      onTap: onTap,

      behavior: HitTestBehavior.translucent,

      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? switch (wordState) {
                  WordState.valid => Colors.green[400],
                  WordState.alreadyScored => Colors.orange[300],
                  WordState.invalid => Colors.white12,
                }
              : Colors.brown[400],
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(2, 2),
              blurRadius: 3,
            ),
          ],
        ),
        child: Center(
          child: Text(
            letter,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

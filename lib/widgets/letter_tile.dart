import 'package:flutter/material.dart';

class LetterTile extends StatelessWidget {
  final String letter;
  final bool isSelected;
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
          color: isSelected ? Colors.orange[300] : Colors.brown[400],
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

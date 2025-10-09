import 'package:flutter/material.dart';
import 'package:word_hunt/widgets/letter_tile.dart';
import 'package:word_hunt/providers/game_state.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late BoardState boardState;
  final GlobalKey _gridKey = GlobalKey();
  final List<TilePos> _selectedList = [];
  final Set<TilePos> _selectedSet = {};

  static const double _gridPadding = 20.0;
  static const double _crossAxisSpacing = 10.0;
  static const double _mainAxisSpacing = 10.0;

  @override
  void initState() {
    super.initState();
    boardState = BoardState();
  }

  // void _onTileDown(int row, int col) {
  //   final pos = TilePos(row, col);
  //   if (!_selectedSet.contains(pos)) {
  //     setState(() {
  //       _selectedList.add(pos);
  //       _selectedSet.add(pos);
  //     });
  //   }
  // }

  void _onTileDown(int row, int col) {
  }

  void _handlePanStart(DragStartDetails details) {
    _processPointer(details.globalPosition);
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    _processPointer(details.globalPosition);
  }

  void _handlePanEnd(DragEndDetails details) {
    _endSelection();
  }

  void _processPointer(Offset globalPosition) {
    final ctx = _gridKey.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null) return;

    final local = box.globalToLocal(globalPosition);

    final rows = boardState.board.length;
    final cols = boardState.board[0].length;

    // Calculate the content area (exclude padding)
    final contentWidth = box.size.width - 2 * _gridPadding;
    final contentHeight = box.size.height - 2 * _gridPadding;

    if (contentWidth <= 0 || contentHeight <= 0) return;

    // tile dimension accounting for spacing between tiles
    final tileWidth = (contentWidth - (cols - 1) * _crossAxisSpacing) / cols;
    final tileHeight = (contentHeight - (rows - 1) * _mainAxisSpacing) / rows;

    // Convert the local coordinate into coordinates inside the content area
    final dx = local.dx - _gridPadding;
    final dy = local.dy - _gridPadding;

    if (dx < 0 || dy < 0) return;

    final periodX = tileWidth + _crossAxisSpacing;
    final periodY = tileHeight + _mainAxisSpacing;

    // Remainders tell where inside each tile+spacing cycle we are
    final withinPeriodX = dx % periodX;
    final withinPeriodY = dy % periodY;

    // If pointer is inside a gap horizontally or vertically, ignore
    if (withinPeriodX > tileWidth || withinPeriodY > tileHeight) {
      return; // inside the spacing gap → don't select a tile
    }

    final col = (dx / periodX).floor();
    final row = (dy / periodY).floor();

    if (row < 0 || row >= rows || col < 0 || col >= cols) return;

    _updateSelectionAt(row, col);
  }

  // Try to add a tile to the current selection while dragging
  void _updateSelectionAt(int row, int col) {
    final pos = TilePos(row, col);

    // If already selected, ignore
    if (_selectedSet.contains(pos)) return;

    setState(() {
      _selectedList.add(pos);
      _selectedSet.add(pos);
    });
  }

  void _endSelection() {
    if (_selectedList.isNotEmpty) {
      final word = _selectedList.map((p) => boardState.board[p.row][p.col]).join();
      debugPrint('Formed word: $word');

      // TODO: validate word against your WordListService and update score if valid
    }

    // Always clear selection after finishing (whether it was a single tap or drag)
    setState(() {
      _selectedList.clear();
      _selectedSet.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final rows = boardState.board.length;
    final cols = boardState.board[0].length;

    return Scaffold(
      backgroundColor: const Color(0xFFA3B18A),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Word Hunt',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            GestureDetector(
              onPanStart: _handlePanStart,
              onPanUpdate: _handlePanUpdate,
              onPanEnd: _handlePanEnd,

              child: GridView.builder(
                key: _gridKey,
                primary: false,
                shrinkWrap: true,
                padding: const EdgeInsets.all(_gridPadding),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  mainAxisSpacing: _mainAxisSpacing,
                  crossAxisSpacing: _crossAxisSpacing,
                ),
                itemCount: rows * cols,
                itemBuilder: (context, index) {
                  final row = index ~/ cols;
                  final col = index % cols;
                  final letter = boardState.board[row][col];
                  final isSelected = _selectedSet.contains(TilePos(row, col));

                  return LetterTile(
                    letter: letter,
                    row: row,
                    col: col,
                    isSelected: isSelected,
                    onTapDown: (int row, int col) => _onTileDown(row, col),
                    onTap: () {
                      // Handle tile tap
                      print('Tapped letter: $letter at ($row, $col)');
                      _endSelection();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:word_hunt/widgets/letter_tile.dart';
import 'package:word_hunt/providers/game_state.dart';

/// Small helper value class for tile positions.
class TilePos {
  final int row;
  final int col;
  const TilePos(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      other is TilePos && other.row == row && other.col == col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late BoardState boardState;

  // Selection state (ordered list + set for quick contains)
  final List<TilePos> _selected = [];
  final Set<TilePos> _selectedSet = {};

  // Key for the container that holds the grid so we can map global -> local coords
  final GlobalKey _gridKey = GlobalKey();

  // Constants used in layout (match these with your GridView settings)
  static const double _gridPadding = 20.0;
  static const double _crossAxisSpacing = 10.0;
  static const double _mainAxisSpacing = 10.0;

  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    boardState = BoardState();
  }

  // Start a fresh selection with the first touched tile
  void _startSelectionAt(int row, int col) {
    final pos = TilePos(row, col);
    setState(() {
      _selected.clear();
      _selectedSet.clear();
      _selected.add(pos);
      _selectedSet.add(pos);
      _isDragging = true;
    });
  }

  // Try to add a tile to the current selection while dragging
  void _updateSelectionAt(int row, int col) {
    final pos = TilePos(row, col);

    // If already selected, ignore
    if (_selectedSet.contains(pos)) return;

    // If there's a previous selected tile, ensure adjacency
    if (_selected.isNotEmpty) {
      final last = _selected.last;
      if (!_isAdjacent(last, pos)) {
        return; // not adjacent → ignore
      }
    }

    setState(() {
      _selected.add(pos);
      _selectedSet.add(pos);
    });
  }

  bool _isAdjacent(TilePos a, TilePos b) {
    return ( (a.row - b.row).abs() <= 1 && (a.col - b.col).abs() <= 1 );
  }

  // End the drag — form the word and clear selection
  void _endSelection() {
    if (_selected.isNotEmpty) {
      final word = _selected.map((p) => boardState.board[p.row][p.col]).join();
      debugPrint('Formed word: $word');

      // TODO: validate word against your WordListService and update score if valid

      // For now, clear selection after finishing
      setState(() {
        _selected.clear();
        _selectedSet.clear();
        _isDragging = false;
      });
    } else {
      _isDragging = false;
    }
  }

  // -------------------------
  // Gesture -> coordinate mapping
  // -------------------------

  void _handlePanStart(DragStartDetails details) {
    _isDragging = true;
    _processPointer(details.globalPosition);
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    _processPointer(details.globalPosition);
  }

  void _handlePanEnd(DragEndDetails details) {
    _endSelection();
  }

  // Map a global pointer position to a (row, col) tile coordinate and update selection
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

    final col = (dx / (tileWidth + _crossAxisSpacing)).floor();
    final row = (dy / (tileHeight + _mainAxisSpacing)).floor();

    if (row < 0 || row >= rows || col < 0 || col >= cols) return;

    _updateSelectionAt(row, col);
  }

  // Called from a tile's onTapDown (immediate press)
  void _handleTileDown(int row, int col) {
    // If not currently dragging, start new selection. If already dragging, treat similarly.
    if (!_isDragging) {
      _startSelectionAt(row, col);
    } else {
      _updateSelectionAt(row, col);
    }
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
          children: [
            const SizedBox(height: 40),
            const Text('Word Hunt',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Stack so we can put a transparent GestureDetector on top of the grid
            Stack(
              children: [
                // Grid container with padding (we use this container's size to map pointer coord)
                Container(
                  key: _gridKey,
                  padding: const EdgeInsets.all(_gridPadding),
                  child: GridView.builder(
                    primary: false,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero, // padding moved to outer container
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
                        onTapDown: (r, c) => _handleTileDown(r, c),
                        onTap: () {
                          // optional: single-tap behavior
                          debugPrint('Tapped letter: $letter at ($row, $col)');
                        },
                      );
                    },
                  ),
                ),

                // Top layer: capture pan events across the entire grid area
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onPanStart: _handlePanStart,
                    onPanUpdate: _handlePanUpdate,
                    onPanEnd: _handlePanEnd,
                    onTapUp: (_) {
                      // also finalize on quick taps that may not trigger panEnd
                      _endSelection();
                    },
                    child: Container(
                      color: Colors.transparent, // ensures this layer captures touches
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick debug info: current selected word
            Text(
              'Selected: ${_selected.map((p) => boardState.board[p.row][p.col]).join()}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
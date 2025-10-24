import 'package:flutter/material.dart';
import 'package:word_hunt/widgets/letter_tile.dart';
import 'package:word_hunt/providers/game_state.dart';
import 'package:word_hunt/screens/results_screen.dart';
import 'package:rive/rive.dart' as rive;

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameState gameState;
  final GlobalKey _gridKey = GlobalKey();
  bool _hasNavigatedToResults = false;

  // Rive controller & trigger for bunny animation
  // ignore: unused_field
  rive.StateMachineController? _riveController;
  rive.SMITrigger? _loginSuccess;

  static const double _gridPadding = 20.0;
  static const double _crossAxisSpacing = 10.0;
  static const double _mainAxisSpacing = 10.0;

  @override
  void initState() {
    super.initState();
    gameState = GameState();
    gameState.addListener(_onGameStateChanged);
    // Trigger bunny animation when a valid word is scored
    gameState.onValidWordScored = _triggerBunnySuccess;
    gameState.startTimer();
  }

  @override
  void dispose() {
    gameState.stopTimer();
    gameState.removeListener(_onGameStateChanged);
    gameState.onValidWordScored = null;
    gameState.dispose();
    super.dispose();
  }

  void _onRiveInit(rive.Artboard artboard) {
    final controller = rive.StateMachineController.fromArtboard(
      artboard,
      'State Machine 1',
    );
    if (controller != null) {
      _riveController = controller;
      artboard.addController(controller);
      _loginSuccess = controller.findSMI('login_success') as rive.SMITrigger?;
    }
  }

  void _triggerBunnySuccess() {
    _loginSuccess?.fire();
  }

  void _onGameStateChanged() {
    setState(() {});
    
    // Show results screen when time is up (only once)
    if (gameState.isGameOver && !_hasNavigatedToResults) {
      _hasNavigatedToResults = true;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ResultsScreen(
            gameState: gameState,
          ),
        ),
      ).then((_) {
        // Reset flag when returning from results screen
        _hasNavigatedToResults = false;
      });
    }
  }

  void _onTileDown(int row, int col) {
    if (!gameState.isGameOver) {
      gameState.selectTile(TilePos(row, col));
    }
  }

  void _handlePanStart(DragStartDetails details) {
    if (!gameState.isGameOver) {
      _processPointer(details.globalPosition);
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!gameState.isGameOver) {
      _processPointer(details.globalPosition);
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (!gameState.isGameOver) {
      gameState.endSelection();
    }
  }

  void _processPointer(Offset globalPosition) {
    final ctx = _gridKey.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null) return;

    final local = box.globalToLocal(globalPosition);

    final rows = gameState.board.length;
    final cols = gameState.board[0].length;

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
      return; 
    }

    final col = (dx / periodX).floor();
    final row = (dy / periodY).floor();

    if (row < 0 || row >= rows || col < 0 || col >= cols) return;

    gameState.selectTile(TilePos(row, col));
  }

  @override
  Widget build(BuildContext context) {
    final rows = gameState.board.length;
    final cols = gameState.board[0].length;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/background.png'),
            fit: BoxFit.cover,
            scale: 0.8,
          ),
        ),
        child: Column(
          children: [
            // White box at the top
            Padding(
              padding: const EdgeInsets.only(top: 80.0, left: 20.0, right: 20.0),
              child: Container(
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Time Left: ${gameState.formattedTime}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    //const SizedBox(height: 8),

                    Text(
                      'Words: ${gameState.scoredWords.length}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),

                    //const SizedBox(height: 8),

                    Text(
                      'Score: ${gameState.score}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 110),

            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  SizedBox(
                    height: 48,
                    child: gameState.selectedTiles.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(left: 80.0), // Move to the right
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              decoration: BoxDecoration(
                                color: switch (gameState.getCurrentWordState()) {
                                  WordState.valid => Colors.green[300],
                                  WordState.alreadyScored => Colors.orange[300],
                                  WordState.invalid => Colors.white,
                                },
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Text(
                                gameState.getCurrentWord().toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 16),

                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF7D8F69), // Darker shade of green
                            border: Border.all(
                              color: const Color(0xFFA3D9A5), // Light green border
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                offset: const Offset(0, 4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: GestureDetector(
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
                              final letter = gameState.board[row][col];
                              final isSelected = gameState.isTileSelected(TilePos(row, col));
                              final wordState = isSelected ? gameState.getCurrentWordState() : WordState.invalid;

                              return LetterTile(
                                letter: letter,
                                row: row,
                                col: col,
                                isSelected: isSelected,
                                wordState: wordState,
                                onTapDown: (int row, int col) => _onTileDown(row, col),
                                onTap: () {
                                  if (!gameState.isGameOver) {
                                    gameState.endSelection();
                                  }
                                },
                              );
                            },
                            ),
                          ),
                        ),
                      ),
                      
                      Positioned(
                        top: -167,
                        right: 180,
                        child: SizedBox(
                          width: 200,
                          height: 200,
                          child: rive.RiveAnimation.asset(
                            'lib/assets/bunny.riv',
                            fit: BoxFit.contain,
                            onInit: _onRiveInit,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
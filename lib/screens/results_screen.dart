import 'package:flutter/material.dart';
import 'package:word_hunt/providers/game_state.dart';

class ResultsScreen extends StatefulWidget {
  final GameState gameState;

  const ResultsScreen({super.key, required this.gameState});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late List<String> sortedWords;

  @override
  void initState() {
    super.initState();
    sortedWords = widget.gameState.scoredWords.toList();
    sortedWords.sort((a, b) => b.length.compareTo(a.length));
  }

  int _calculateWordPoints(String word) {
    switch (word.length) {
      case 3:
        return 100;
      case 4:
        return 400;
      case 5:
        return 800;
      case 6:
        return 1400;
      default:
        return (word.length - 6) * 400 + 1400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/background.png'),
            fit: BoxFit.cover,
            scale: 0.8,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Total Score: ${widget.gameState.score}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Words count
                Text(
                  'Words Found: ${sortedWords.length}',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Words list container
                Container(
                  height: 400,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7D8F69), // Darker shade of green
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        offset: const Offset(0, 4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Words list
                      Flexible(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            // Calculate how many items can fit
                            const itemHeight = 48.0;
                            final maxItems = (constraints.maxHeight / itemHeight).floor();
                            final displayCount = sortedWords.length > maxItems 
                                ? maxItems - 1 
                                : sortedWords.length;
                            final hasMore = sortedWords.length > displayCount;
                            
                            return ListView.builder(
                              padding: const EdgeInsets.only(top: 8),
                              shrinkWrap: true,
                              itemCount: displayCount + (hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (hasMore && index == displayCount) {
                                  // Show "..." indicator
                                  return Container(
                                    height: itemHeight,
                                    alignment: Alignment.center,
                                    child: const Text(
                                      '...',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  );
                                }
                                
                                final word = sortedWords[index];
                                final points = _calculateWordPoints(word);
                                
                                return Container(
                                  height: itemHeight,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        word.toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        '$points',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Play Again button
                ElevatedButton(
                  onPressed: () {
                    widget.gameState.restartGame();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF588157),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Play Again',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

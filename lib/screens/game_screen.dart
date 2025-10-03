import 'package:flutter/material.dart';
import 'package:word_hunt/widgets/letter_tile.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFA3B18A),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Word Hunt', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            //SizedBox(height: 20),
            GridView.count(
              primary: false,
              shrinkWrap: true,
              padding: const EdgeInsets.all(20),
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              
              children: List.generate(16, (index) => LetterTile(letter: 'A', isSelected: false, onTap: () {})),
            ),
          ],
        ),
      ),
    );
  }
}
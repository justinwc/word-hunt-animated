import 'package:flutter/material.dart';
import 'package:word_hunt/screens/intro_screen.dart';
import 'package:word_hunt/services/word_list_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  WordListService.loadWords();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Hunt',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: IntroScreen(),
    );
  }
}

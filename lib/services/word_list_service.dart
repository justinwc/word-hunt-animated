import 'package:flutter/services.dart' show rootBundle;

class WordListService {
  static Set<String>? _words;

  static Future<Set<String>> loadWords() async {
    if (_words != null) return _words!;

    final raw = await rootBundle.loadString('lib/assets/enable1.txt');
    _words = raw
        .split('\n')
        .map((w) => w.trim().toLowerCase())
        .where((w) => w.length >= 3 && w.length <= 16)
        .toSet();

    return _words!;
  }

  static bool isValidWord(String word) {
    return _words?.contains(word.toLowerCase()) ?? false;
  }
}

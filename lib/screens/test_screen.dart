import 'package:flutter/material.dart';
import 'package:word_hunt/services/word_list_service.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final TextEditingController _textController = TextEditingController();
  String _result = '';
  bool _isLoading = false;

  Future<void> _testWord() async {
    if (_textController.text.trim().isEmpty) {
      setState(() {
        _result = 'Please enter a word to test';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      // Ensure words are loaded
      await WordListService.loadWords();
      
      final word = _textController.text.trim();
      final isValid = WordListService.isValidWord(word);
      
      setState(() {
        _result = isValid 
            ? '✅ "$word" is a valid word!'
            : '❌ "$word" is not a valid word.';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Test Word Validity',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Enter a word to test',
                hintText: 'Type a word here...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _testWord(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _testWord,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Test Word',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
            const SizedBox(height: 20),
            if (_result.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _result.contains('✅') 
                      ? Colors.green.shade50
                      : _result.contains('❌')
                          ? Colors.red.shade50
                          : Colors.grey.shade50,
                  border: Border.all(
                    color: _result.contains('✅')
                        ? Colors.green
                        : _result.contains('❌')
                            ? Colors.red
                            : Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _result,
                  style: TextStyle(
                    fontSize: 16,
                    color: _result.contains('✅')
                        ? Colors.green.shade800
                        : _result.contains('❌')
                            ? Colors.red.shade800
                            : Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const Spacer(),
            const Text(
              'This tool tests whether a word exists in the enable1 word list.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

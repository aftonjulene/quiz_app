import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/api_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> _questions = [];

  int _currentIndex = 0;

  // user score
  int _score = 0;

  // basic loading + state flags
  bool _loading = true;
  bool _error = false;
  bool _answered = false;

  // store selected answer + feedback text
  String _selectedAnswer = '';
  String _feedbackText = '';

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _loading = true;
      _error = false;
      _questions = [];
      _currentIndex = 0;
      _score = 0;
      _answered = false;
      _selectedAnswer = '';
      _feedbackText = '';
    });

    try {
      final questions = await ApiService.fetchQuestions();
      setState(() {
        _questions = questions;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  // handle when the user taps an answer
  void _submitAnswer(String answer) {
    if (_answered) return;

    final Question current = _questions[_currentIndex];
    final bool isCorrect = answer == current.correctAnswer;

    setState(() {
      _answered = true;
      _selectedAnswer = answer;

      if (isCorrect) {
        _score++;
        _feedbackText = 'Correct! The answer is ${current.correctAnswer}.';
      } else {
        _feedbackText =
            'Incorrect. The correct answer is ${current.correctAnswer}.';
      }
    });
  }

  // move to the next question or finish the quiz
  void _nextQuestion() {
    if (_currentIndex + 1 < _questions.length) {
      setState(() {
        _currentIndex++;
        _answered = false;
        _selectedAnswer = '';
        _feedbackText = '';
      });
    } else {
      // end of quiz
      setState(() {
        _answered = false;
      });
      _showResultDialog();
    }
  }

  // simple dialog to show final score and option to restart
  void _showResultDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text('Quiz Finished'),
          content: Text('Your score: $_score / ${_questions.length}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _loadQuestions();
              },
              child: const Text('Play again'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // one button for each option
  Widget _buildOptionButton(String option) {
    final Question current = _questions[_currentIndex];
    final bool isCorrectOption = option == current.correctAnswer;
    final bool isSelected = option == _selectedAnswer;

    Color? background;

    if (_answered && isSelected) {
      background = isCorrectOption ? Colors.green : Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ElevatedButton(
        onPressed: _answered ? null : () => _submitAnswer(option),
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: const Color.fromARGB(255, 162, 25, 70),
        ),
        child: Text(option, textAlign: TextAlign.center),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Failed to load questions.'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loadQuestions,
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    final Question current = _questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('Trivia Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // top row: progress + score
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_currentIndex + 1} / ${_questions.length}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text('Score: $_score', style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 20),
            // question text
            Text(
              current.question,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            // all answer buttons
            ...current.options.map(_buildOptionButton).toList(),
            const SizedBox(height: 20),
            // feedback text after answering
            if (_answered)
              Text(
                _feedbackText,
                style: TextStyle(
                  fontSize: 16,
                  color: _selectedAnswer == current.correctAnswer
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            const Spacer(),
            // next button only when question is answered
            if (_answered)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  child: const Text('Next'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

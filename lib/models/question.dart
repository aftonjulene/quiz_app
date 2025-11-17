import 'package:html_unescape/html_unescape.dart';

class Question {
  // question text from the api
  final String question;

  // all options shown to the user
  final List<String> options;

  // correct answer from the api
  final String correctAnswer;

  Question({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  // build a Question object from api json
  factory Question.fromJson(Map<String, dynamic> json) {
    final unescape = HtmlUnescape();

    // decode question and correct answer text
    final q = unescape.convert(json['question'] as String);
    final correct = unescape.convert(json['correct_answer'] as String);

    // decode each incorrect answer
    final List<String> options = (json['incorrect_answers'] as List<dynamic>)
        .map((item) => unescape.convert(item as String))
        .toList();

    // add the correct answer and shuffle
    options.add(correct);
    options.shuffle();

    return Question(question: q, options: options, correctAnswer: correct);
  }
}

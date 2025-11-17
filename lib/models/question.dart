class Question {
  final String question;
  final List<String> options;
  final String correctAnswer;

  Question({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    // Decode options by combining incorrect answers with the correct answer and shuffling them.
    final options = List<String>.from(json['incorrect_answers'] as List);
    options.add(json['correct_answer'] as String);
    options.shuffle();
    return Question(
      question: json['question'] as String,
      options: options,
      correctAnswer: json['correct_answer'] as String,
    );
  }
}

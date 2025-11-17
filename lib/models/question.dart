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

  // build a Question from a single json object
  factory Question.fromJson(Map<String, dynamic> json) {
    final List<String> options = List<String>.from(
      json['incorrect_answers'] as List<dynamic>,
    );

    options.add(json['correct_answer'] as String);
    options.shuffle(); // randomize answer order

    return Question(
      question: json['question'] as String,
      options: options,
      correctAnswer: json['correct_answer'] as String,
    );
  }
}

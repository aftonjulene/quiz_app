import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';

class ApiService {
  static Future<List<Question>> fetchQuestions() async {
    final uri = Uri.parse(
      'https://opentdb.com/api.php?amount=10&category=9&difficulty=easy&type=multiple',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      final questions = results
          .map((q) => Question.fromJson(q as Map<String, dynamic>))
          .toList();
      return questions;
    } else {
      throw Exception('Failed to load questions');
    }
  }
}

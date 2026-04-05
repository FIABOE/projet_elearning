class Question {
  int id;
  String questionText;
  List<String> options;
  int correctAnswerIndices;
  String? selectedOption;
  int score;
  

  Question({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndices,
    this.selectedOption,
    required this.score,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      questionText: json['question'],
      options: List<String>.from(json['options'].map((option) => option.toString().replaceAll("'", ''))),
      correctAnswerIndices: json['options'].indexWhere((option) => option == json['correct_option'].toString().replaceAll("'", '')),
      score: json['score'], // Assurez-vous de récupérer le score depuis les données JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionText': questionText,
      'options': options,
      'correctAnswerIndices': correctAnswerIndices,
      'selectedOption': selectedOption,
      'score': score,
    };
  }
}

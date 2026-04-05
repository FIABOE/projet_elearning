class Quiz {
  final int id;
  final String question;
  final String niveau;
  final List<String> options;
  final String correct_option;
  final String filiere;
  final int score; // Ajoutez la propriété "score"

  Quiz({
    required this.id,
    required this.question,
    required this.niveau,
    required this.options,
    required this.correct_option,
    required this.filiere,
    required this.score, // Ajoutez la propriété "score"
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    final List<String> jsonOptions = List<String>.from(json['options'].map((option) => option.toString()));
    final int correctIndex = jsonOptions.indexWhere((option) => option == json['correct_option'].toString());

    return Quiz(
      id: json['id'],
      question: json['question'],
      niveau: json['niveau'],
      options: jsonOptions,
      correct_option: json['correct_option'],
      filiere: json['filiere'],
      score: json['score'], // Assurez-vous que la clé est correcte
    );
  }
}

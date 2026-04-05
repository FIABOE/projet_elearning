import 'package:education/models/question.dart';
import 'package:flutter/material.dart';
import 'package:education/screen/Homepage/accueil_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:percent_indicator/percent_indicator.dart';

import 'screen/Quiz/success.dart' show SuccessPage;

final appThemeStateNotifier = ChangeNotifierProvider(
  create: (ref) => AppThemeState(),
);

class AppThemeState extends ChangeNotifier {
  var isDarkModeEnabled = false;
  void setLightTheme() {
    isDarkModeEnabled = false;
    notifyListeners();
  }
  void setDarkTheme() {
    isDarkModeEnabled = true;
    notifyListeners();
  }
}

class QuizPage extends StatefulWidget {
  final int filiereId;
  final String niveau;

  const QuizPage({super.key, required this.filiereId, required this.niveau});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  Stopwatch stopwatch = Stopwatch()..start();
  int _currentQuestionIndex = 0;
  double _progress = 0.0;
  String? userToken;
  List<Question> _questions = [];
  bool _questionsLoaded = false;
  late SharedPreferences _prefs;
  String _selectedNiveau = '';
  final bool _isCurrentAnswerCorrect = false;
  bool _quizCompleted = false;
  int totalScore = 0;
  String niveau = '';

  void _initializeSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    final savedCurrentQuestionIndex = _prefs.getInt('currentQuestionIndex');
    if (savedCurrentQuestionIndex != null) {
      setState(() {
        _currentQuestionIndex = savedCurrentQuestionIndex;
      });
    }

    void selectNiveau(String niveau) {
      setState(() {
        _selectedNiveau = niveau;
      });
    }

    final completed = _prefs.getBool('quizCompleted') ?? false;
    if (completed) {
      setState(() {
        _quizCompleted = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeSharedPreferences();
    _loadQuizState(); // Chargez l'état du quiz au démarrage
    _fetchQuestions();
  }

  // Sauvegarde de l'état du quiz
  void _saveQuizState() async {
    await _prefs.setInt('currentQuestionIndex', _currentQuestionIndex);
    await _prefs.setBool('quizCompleted', _quizCompleted);
    // Ajoutez d'autres informations si nécessaire
  }

  // Récupération de l'état du quiz au démarrage
  void _loadQuizState() {
    final savedCurrentQuestionIndex = _prefs.getInt('currentQuestionIndex');
    final quizCompleted = _prefs.getBool('quizCompleted') ?? false;

    if (savedCurrentQuestionIndex != null) {
      setState(() {
        _currentQuestionIndex = savedCurrentQuestionIndex;
      });
    }

    if (quizCompleted) {
      _showSuccessMessage();
    }
  }

  Future<void> _fetchQuestions() async {
    final niveau = widget.niveau ?? '';
    print('Fetching questions for filiereId: ${widget.filiereId} and niveau: $niveau');
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.68:8000/api/quiz/${widget.filiereId}/$niveau'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> jsonQuestions = jsonResponse['data'];

        final List<Question> questions = jsonQuestions.map((json) => Question.fromJson(json)).toList();

        setState(() {
          _questions = questions;
          _questionsLoaded = true;
          this.niveau = niveau;
        });
        print("Niveau dans _fetchQuestions: $niveau");
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Erreur de chargement des questions'),
              content: const Text('Une erreur s\'est produite lors du chargement des questions.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Fermer'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Erreur de chargement des questions'),
            content: const Text('Une erreur s\'est produite lors du chargement des questions.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Fermer'),
              ),
            ],
          );
        },
      );
    }
  }

  void _onOptionSelected(String selectedOption) {
    final isCorrect = _questions[_currentQuestionIndex].options.indexOf(selectedOption) ==
        _questions[_currentQuestionIndex].correctAnswerIndices;

    if (isCorrect) {
      _showSuccessMessage();
    } else {
      _showFailureMessage();
    }
    setState(() {
      _questions[_currentQuestionIndex].selectedOption = selectedOption;
    });
    _saveQuizState(); // Appel de la sauvegarde après chaque réponse
  }

  void _nextQuestion() {
    setState(() {
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
        _progress = (_currentQuestionIndex + 1) / _questions.length;
      } else {
        _quizCompleted = true;
        _showSuccessMessage();
      }
    });
    _saveQuizState(); // Appel de la sauvegarde après chaque question
  }

  int calculateTotalScore(List<Question> questions) {
    int totalScore = 0;
    for (var question in questions) {
      final selectedOption = question.selectedOption;
      if (selectedOption != null) {
        final selectedOptionIndex = question.options.indexOf(selectedOption);
        if (selectedOptionIndex == question.correctAnswerIndices) {
          totalScore += question.score.toInt();
        }
      }
    }
    return totalScore;
  }

  void _showSuccessMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Bravo !',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          content: const Text(
            'Bonne réponse !',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                final isLastQuestion = _currentQuestionIndex == _questions.length - 1;
                if (isLastQuestion) {
                  final totalScore = calculateTotalScore(_questions);
                  double average = (totalScore * 20) / (_questions.length * 4);
                  stopwatch.stop();
                  int second = stopwatch.elapsed.inSeconds;
                  final nombreQuestionsReussies = _questions.where((q) => q.selectedOption != null && _questions.indexOf(q) <= _currentQuestionIndex).length;
                  final nombreQuestionsEchouees = _questions.length - nombreQuestionsReussies;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SuccessPage(
                        second: second,
                        totalScore: totalScore,
                        averageScore: average,
                        niveau: niveau,
                        nombreQuestionsRepondues: _questions.length, nombreQuestionsReussies: nombreQuestionsReussies, nombreQuestionsEchouees: nombreQuestionsEchouees,
                      ),
                    ),
                  );
                  return;
                }
                Navigator.of(context).pop();
                _nextQuestion();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showFailureMessage() {
    final correctAnswerIndex = _questions[_currentQuestionIndex].correctAnswerIndices;
    final correctAnswer = _questions[_currentQuestionIndex].options[correctAnswerIndex];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Dommage !',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mauvaise réponse.',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bonne réponse : $correctAnswer',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final isLastQuestion = _currentQuestionIndex == _questions.length - 1;
                if (isLastQuestion) {
                  final totalScore = calculateTotalScore(_questions);
                  double average = (totalScore * 20) / (_questions.length * 4);
                  stopwatch.stop();
                  int second = stopwatch.elapsed.inSeconds;
                  final nombreQuestionsReussies = _questions.where((q) => q.selectedOption != null && _questions.indexOf(q) <= _currentQuestionIndex).length;
                  final nombreQuestionsEchouees = _questions.length - nombreQuestionsReussies;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SuccessPage(
                        second: second,
                        totalScore: totalScore,
                        averageScore: average,
                        niveau: niveau,
                        nombreQuestionsRepondues: _questions.length,
                        nombreQuestionsReussies: nombreQuestionsReussies,
                        nombreQuestionsEchouees: nombreQuestionsEchouees,
                      ),
                    ),
                  );
                  return;
                }
                Navigator.of(context).pop();
                _nextQuestion();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quiz',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF70A19F),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onPressed: () {
              // Gérer le menu de paramètres ici
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LinearPercentIndicator(
                    percent: _progress,
                    lineHeight: 10,
                    linearStrokeCap: LinearStrokeCap.roundAll,
                    backgroundColor: Colors.grey[300],
                    progressColor: const Color(0xFF70A19F),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_currentQuestionIndex + 1} / ${_questions.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _questionsLoaded
                ? Column(
                    children: [
                      Text(
                        _currentQuestionIndex < _questions.length
                            ? _questions[_currentQuestionIndex].questionText
                            : 'Toutes les questions ont été répondues',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Column(
                        children: _questions[_currentQuestionIndex].options.map((option) {
                          final isCorrect = _questions[_currentQuestionIndex].options.indexOf(option) ==
                              _questions[_currentQuestionIndex].correctAnswerIndices;

                          final isSelected = option == _questions[_currentQuestionIndex].selectedOption;

                          final backgroundColor =
                              isSelected ? (isCorrect ? Colors.green : Colors.red) : const Color(0xFF70A19F);

                          return GestureDetector(
                            onTap: () {
                              _onOptionSelected(option);
                            },
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              color: backgroundColor,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    option,
                                    style: const TextStyle(color: Colors.white, fontSize: 18),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          ],
        ),
      ),
    );
  }
}

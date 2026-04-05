import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:education/models/question.dart';
import 'package:education/screen/Homepage/accueil_page.dart';
import 'package:education/screen/Quiz/success.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:education/utils/constances.dart';

class QuizPage extends StatefulWidget {
  final int filiereId;
  final String niveau;

  const QuizPage({super.key, required this.filiereId, required this.niveau});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  Stopwatch stopwatch = Stopwatch()..start();
  List<Question> _questions = [];
  List<int> scoresList = []; 
  double _progress = 0.0;
  String? userToken;
  String niveau = '';
  String _selectedNiveau = '';
  bool _questionsLoaded = false;
  final bool _isCurrentAnswerCorrect = false;
  bool _quizCompleted = false;
  int totalScore = 0;
  int nombreQuestionsReussies = 0;
  int nombreQuestionsEchouees = 0;
  int _currentQuestionIndex = 0;
  late SharedPreferences _prefs; 
 
  //////
  void _initializeSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    final savedCurrentQuestionIndex = _prefs.getInt('currentQuestionIndex');
    if (savedCurrentQuestionIndex != null) {
      setState(() {
        _currentQuestionIndex = savedCurrentQuestionIndex;
      });
    }

    ///
    void selectNiveau(String niveau) {
      setState(() {
        _selectedNiveau = niveau;
      });
    }
    // Vérifiez si l'utilisateur a terminé tous les quiz
    final completed = _prefs.getBool('quizCompleted') ?? false;
      if (completed) {
        // Redirigez l'utilisateur vers une autre page si tous les quiz sont terminés
        setState(() {
          _quizCompleted = true;
        });
        // Vous pouvez utiliser Navigator.push pour naviguer vers une autre page
      // par exemple : Navigator.push(context, MaterialPageRoute(builder: (context) => AnotherPage()));
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeSharedPreferences();
    _fetchQuestions();
    _initializeSharedPreferences();
  }

  //fonction interaction avec BD pour récupérer les quiz
  Future<void> _fetchQuestions() async {
    final niveau = widget.niveau ?? ''; 
    //print('Fetching questions for filiereId: ${widget.filiereId} and niveau: $niveau');
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/api/quiz/${widget.filiereId}/$niveau'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );
      //print('API Response: ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> jsonQuestions = jsonResponse['data'];

        final List<Question> questions = jsonQuestions.map((json) => Question.fromJson(json)).toList();

        setState(() {
          _questions = questions;
          _questionsLoaded = true;
          this.niveau = niveau;
        });
        // print("Niveau dans _fetchQuestions: $niveau");
        //print('Questions loaded successfully');
      } else {
        //print('Failed to load questions: ${response.statusCode}');
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
      //print('Error fetching questions: $e');
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

  setState(() {
    _questions[_currentQuestionIndex].selectedOption = selectedOption;
  });

  if (isCorrect) {
    _showSuccessMessage();
    setState(() {
      nombreQuestionsReussies++; // Mettez à jour le nombre de questions réussies
    });
  } else {
    _showFailureMessage();
    setState(() {
      nombreQuestionsEchouees++; // Mettez à jour le nombre de questions échouées
    });
  }
}

  //affichage du déroulement des questionnaires
  void _nextQuestion() {
    setState(() {
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
        _progress = (_currentQuestionIndex + 1) / _questions.length;
      } else {
    }
  });
}

//pour le calcule du score
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

//calcul de la moyenne
double calculateAverage(List<int> scores) {
  if (scores.isEmpty) {
    return 0.0; // Si la liste est vide, la moyenne est zéro.
  }
  int total = 0;
  int questionsAnswered = scores.length;
 
  for (int score in scores) {
    total += score;
  }

  double average = total / (questionsAnswered * 20); 
  return average;
}

/*double calculateAverage(int totalScore) {
  if (_questions.isEmpty) {
    return 0.0;
  }
  int totalPossibleScore = _questions.length * 20;
  double average = (totalScore / totalPossibleScore) * 100;
  return average;
}*/

  //Rafraîchissement
  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _progress = 0.0;
      _quizCompleted = false;
      for (var question in _questions) {
        question.selectedOption = null; // Réinitialisez les réponses de l'utilisateur
      }
    });
  }

  //Boite succès
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
                double average = (totalScore*20) / (_questions.length*4);
                stopwatch.stop();
                int second = stopwatch.elapsed.inSeconds;
                //print(second);
                //print("Niveau dan onPressed: $niveau");
                //print(_questions.length);
                Navigator.push(context, MaterialPageRoute(builder: (context) => SuccessPage(
                  second:second,
                  totalScore:totalScore, 
                  averageScore:average, 
                  niveau: niveau,
                  nombreQuestionsRepondues: _questions.length,
                  nombreQuestionsReussies: nombreQuestionsReussies,
                  nombreQuestionsEchouees: nombreQuestionsEchouees,
                )));
                return;
            }
              Navigator.of(context).pop(); 
              _nextQuestion(); // Passez à la question suivante
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

//Boite Echec
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
                  double average = (totalScore*20) /  (_questions.length*4); 
                                  stopwatch.stop();
                int second = stopwatch.elapsed.inSeconds;
                Navigator.push(context, MaterialPageRoute(builder: (context) => SuccessPage(
                  second:second,
                  totalScore:totalScore, 
                  averageScore:average, 
                  niveau: niveau,
                  nombreQuestionsRepondues: _questions.length,
                  nombreQuestionsReussies: nombreQuestionsReussies,
                  nombreQuestionsEchouees: nombreQuestionsEchouees,
                )));
                return;
              }
              Navigator.of(context).pop(); 
              _nextQuestion(); // Passez à la question suivante 
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

//l'interface proprement dite
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

                        // Déterminez la couleur de fond en fonction de la réponse sélectionnée
                        final backgroundColor = isSelected
                            ? isCorrect ? Colors.green : Colors.red
                            : const Color(0xFF70A19F);
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
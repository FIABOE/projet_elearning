import 'package:flutter/material.dart';
import 'package:education/screenAdmin/AddQuiz_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:education/models/quiz.dart';
import 'package:education/models/filiere.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:education/screen/Info/list_filière.dart';
import 'package:education/utils/constances.dart';
import 'package:education/screenAdmin/Add_Mod_quiz.dart';
import 'package:education/screen/ScreenMod%C3%A9rateur/accueilMod%C3%A9rateur.dart';

class ListeQuiz extends StatefulWidget {
  const ListeQuiz({super.key});

  @override
  _ListeQuizState createState() => _ListeQuizState();
}

class _ListeQuizState extends State<ListeQuiz> {
  TextEditingController filiereController = TextEditingController();
  List<Quiz> quizs = [];
  List<Quiz> filteredQuizs = [];
  String? userToken;
  String? selectedFiliere;
  List<String> filieres = [];
  List<String> filteredFilieres = [];
  bool isLoading = false;
  
  @override
  void initState() {
    super.initState();
    fetchQuizs();
    _getUserToken();
  }

  //Récupération du token
  Future<void> _getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
    //print('Token d\'authentification récupéré depuis les préférences : $userToken');
  }

   //fonction pour afficher les details de la question du quiz
  void showQuizDetails(Quiz quiz) {
  showDialog(
    context: context,
    builder: (context) {
      return SingleChildScrollView(
        child: AlertDialog(
          title: const Text(
            'Détails de la question',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.blueGrey,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filière: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                quiz.filiere,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Niveau: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                quiz.niveau,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Option de réponse: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                quiz.options.join(", "),
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Correcte réponse: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                quiz.correct_option,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Score: ', // Champ de texte pour le score
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                quiz.score.toString(), // Affichez le score ici
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Fermer',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 19,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

   //Affichage de la liste des quizs
 Future<void> fetchQuizs() async {
  final prefs = await SharedPreferences.getInstance();
  userToken = prefs.getString('userToken');

  try {
    setState(() {
      isLoading = true;
    });
    final response = await http.get(
      Uri.parse('$BASE_URL/api/quizzes'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $userToken',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('data') && data['data'] is List<dynamic>) {
        final List<dynamic> jsonData = data['data'];
        final List<Quiz> fetchedQuizs = jsonData.map((item) {
          final id = item['id'];
          final List<String> options =
              List<String>.from(item['options'].map((option) => option.toString()));
          return Quiz(
            id: (id is int) ? id : int.tryParse(id.toString()) ?? 0,
            question: item['question'],
            niveau: item['niveau'],
            options: options,
            correct_option: item['correct_option'].toString(),
            filiere: item['filiere'] ?? '', // Gérer le cas où filiere est null
            score: item['score'], 
          );
        }).toList();

        setState(() {
          quizs.clear();
          quizs.addAll(fetchedQuizs.reversed);
          filteredQuizs = List.from(quizs);
        });
      } else {
        throw Exception('Failed to load Quiz');
      }
    } else {
      throw Exception('Failed to load Quiz');
    }
  } catch (error) {
    print('Error fetching Quiz: $error');
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}


  //Pour permettre la navigation vers la liste de filière
  Future<String?> navigateToFiliereSelection() async {
    final selected = await Navigator.push<String?>(
      context,
      MaterialPageRoute(
        builder: (context) => ListFiliere(selectedFiliere: selectedFiliere),
      ),
    );
    return selected;
  }

 //Le corps
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            'Liste des quiz',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF70A19F),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AccueilMod()),
            );
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.blueGrey, // Couleur du rectangle d'ajout
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Add_ModQuiz(), // Redirige vers AddQuiz
                  ),
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color: Colors.white, // Couleur de l'icône d'ajout
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Ajouter',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Couleur du texte d'ajout
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16), // Espace entre le rectangle d'ajout et la liste
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(), // Afficher le CircularProgressIndicator lorsque isLoading est true
                  )
                : ListView.builder(
              itemCount: quizs.length,
              itemBuilder: (context, index) {
                final quiz = quizs[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    title: Text(
                      quiz.question,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.remove_red_eye,
                            color: Colors.green,
                          ),
                          onPressed: () {
                            showQuizDetails(quiz);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

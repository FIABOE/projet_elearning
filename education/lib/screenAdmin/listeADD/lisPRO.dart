import 'package:flutter/material.dart';
import 'package:education/screen/Info/list_filière.dart';
import 'package:education/screenAdmin/listeADD/ListQuiz.dart';
import 'package:education/screenAdmin/listeADD/ListeFill.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:education/utils/constances.dart';

class AddQuiz extends StatefulWidget {
  const AddQuiz({super.key});

  @override
  _AddQuizState createState() => _AddQuizState();
}

class _AddQuizState extends State<AddQuiz> {
  TextEditingController questionController = TextEditingController();
  TextEditingController niveauController = TextEditingController();
  TextEditingController optionController = TextEditingController();
  TextEditingController correctAnswerController = TextEditingController();
  TextEditingController scoreController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //String selectedQuestionType = 'QCM'; // Par défaut, QCM est sélectionné
  String selectedFiliere = 'Filière '; // Remplacez par votre logique de sélection de filière
  bool isValiderButtonEnabled = false;
  String? userToken;
  bool isQuizSubmitted = false;
  
  //Pour permettre de selection une filiere dans la liste filiere
  void navigateToFiliereSelection() async {
    final selectedFiliere = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListFiliere(selectedFiliere: this.selectedFiliere),
      ),
    );
    if (selectedFiliere != null) {
      setState(() {
        this.selectedFiliere = selectedFiliere;
      });
    }
  }

   @override
    void initState() {
    super.initState();
     _getUserToken();
  }

   Future<void> _getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
    //print('Token d\'authentification récupéré depuis les préférences : $userToken');
  }
  
 Future<void> ajouterQuiz() async {
  const String apiUrl = '$BASE_URL:8000/api/quizzes';
  final List<String> options = optionController.text.split(',');
  final String correctOption = correctAnswerController.text;
  final int score = int.parse(scoreController.text); // Récupérez le score depuis le champ de texte

  final Map<String, dynamic> formData = {
    'filiere_libelle': selectedFiliere,
    'question': questionController.text,
    'niveau': niveauController.text,
    'options': options,
    'correct_option': correctOption,
    'score': score, // Ajoutez le champ "score"
  };

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      body: jsonEncode(formData),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $userToken',
      },
    );

    if (response.statusCode == 201) {
      setState(() {
        isQuizSubmitted = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Quiz ajouté avec succès.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Color(0xFF70A19F),
        ),
      );

      // Réinitialisez les champs après l'ajout réussi.
      questionController.clear();
      optionController.clear();
      correctAnswerController.clear();
      niveauController.clear();
      scoreController.clear(); // Réinitialisez le champ "score"
    } else {
      setState(() {
        isQuizSubmitted = false;
      });

      print('Échec de l\'ajout du quiz.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Échec de l\'ajout du quiz.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Color(0xFFF5804E),
        ),
      );
    }
  } catch (error) {
    setState(() {
      isQuizSubmitted = false;
    });

    print('Une erreur s\'est produite : $error');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Une erreur s\'est produite : $error',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFFC6161),
      ),
    );
  }
}

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Text(
          'Ajouter un quiz',
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
          Navigator.pop(context);
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ListQuiz(),
              ),
            );
          },
          child: const Row(
            children: [
              Icon(
                Icons.list,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ],
    ),
    body: SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: navigateToFiliereSelection,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color.fromARGB(255, 204, 203, 203),
                      width: 2.0,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filière',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(255, 17, 15, 15),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            selectedFiliere ?? 'Sélection',
                            style: TextStyle(
                              fontSize: 16,
                              color: selectedFiliere != null ? const Color(0xFF087B95) : Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: niveauController,
                onChanged: (text) {
                  setState(() {
                    isValiderButtonEnabled = text.isNotEmpty;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le niveau est requis.';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Niveau',
                  labelStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 17, 15, 15),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: questionController,
                onChanged: (text) {
                  setState(() {
                    isValiderButtonEnabled = text.isNotEmpty;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La question est requise.';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Question',
                  labelStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 17, 15, 15),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: optionController,
                onChanged: (text) {
                  setState(() {
                    isValiderButtonEnabled = text.isNotEmpty;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'L\'option de réponse est requise.';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Option de réponse',
                  labelStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 17, 15, 15),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: correctAnswerController,
                onChanged: (text) {
                  setState(() {
                    isValiderButtonEnabled = text.isNotEmpty;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La réponse correcte est requise.';
                  }
                  final List<String> options = optionController.text.split(',');
                  if (!options.contains(value)) {
                    return 'La réponse correcte doit être l\'une des options fournies.';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Réponse correcte',
                  labelStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 17, 15, 15),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: scoreController,
                onChanged: (text) {
                  setState(() {
                    isValiderButtonEnabled = text.isNotEmpty;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le score est requis.';
                  }
                  // Utilisez le try-catch pour vérifier si le score est un nombre
                  try {
                    double.parse(value);
                  } catch (e) {
                    return 'Le score doit être un nombre.';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Score',
                  labelStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 17, 15, 15),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 80),
              ElevatedButton(
        onPressed: isValiderButtonEnabled && !isQuizSubmitted
            ? () {
                if (_formKey.currentState!.validate()) {
                  ajouterQuiz();
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF70A19F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Soumettre',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    backgroundColor: const Color(0xFFF0F0F0),
  );
}
}
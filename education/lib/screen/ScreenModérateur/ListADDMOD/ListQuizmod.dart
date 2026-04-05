import 'package:flutter/material.dart';
import 'package:education/screenAdmin/AddQuiz_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:education/models/quiz.dart';
import 'package:education/models/filiere.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:education/screen/Info/list_filière.dart';
import 'package:education/utils/constances.dart';
import 'package:education/screenAdmin/adAccueil_page.dart';

class ListQuiz extends StatefulWidget {
  const ListQuiz({super.key});

  @override
  _ListQuizState createState() => _ListQuizState();
}

class _ListQuizState extends State<ListQuiz> {
  TextEditingController filiereController = TextEditingController();
  List<Quiz> quizs = [];
  List<Quiz> filteredQuizs = [];
  List<String> filieres = [];
  List<String> filteredFilieres = [];
  String? userToken;
  String? selectedFiliere;
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
            'Détails de la  question',
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
                'Module: ',
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
      Uri.parse('$BASE_URL/$Quizzes_PATH'),
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
  //Fonction pour affiché la boite de dialogue pour permettre la modification d'un quiz donné
  Future<void> _showEditDialog(Quiz quiz) async {
    final questionController = TextEditingController(text: quiz.question);
    final niveauController = TextEditingController(text: quiz.niveau);
    final optionsController = TextEditingController(text: quiz.options.join(", "));
    final correctOptionController = TextEditingController(text: quiz.correct_option);
    final scoreController = TextEditingController(text: quiz.score.toString()); // Ajoutez un contrôleur pour le score
    String? selectedFiliere = quiz.filiere;
    filiereController.text = quiz.filiere;
    bool isValiderButtonEnabled = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
              'Modifier les informations',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.blueGrey,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: questionController,
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
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 204, 203, 203),
                          width: 2.0,
                        ),
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      //color: (questionController.text.isNotEmpty) ? Color(0xFF087B95) : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: niveauController,
                    validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le niveau est requis.';
                  } else if (value.contains(' ')) {
                    return 'Le niveau ne doit pas contenir d\'espaces.';
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
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 204, 203, 203),
                          width: 2.0,
                        ),
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      //color: (niveauController.text.isNotEmpty) ? Color(0xFF087B95) : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: optionsController,
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
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 204, 203, 203),
                          width: 2.0,
                        ),
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      //color: (optionsController.text.isNotEmpty) ? Color(0xFF087B95) : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: correctOptionController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                    return 'La réponse correcte est requise.';
                  }
                  final List<String> options = optionsController.text.split(',');
                  if (!options.contains(value)) {
                    return 'La réponse correcte doit être l\'une des options fournies.';
                  }
                  return null;
                },
                    decoration: InputDecoration(
                      labelText: 'Correcte réponse',
                      labelStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(255, 17, 15, 15),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 204, 203, 203),
                          width: 2.0,
                        ),
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      //color: (correctOptionController.text.isNotEmpty) ? Color(0xFF087B95) : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: scoreController, 
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
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 204, 203, 203),
                          width: 2.0,
                        ),
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () async {
                      final selected = await navigateToFiliereSelection();
                      if (selected != null) {
                        setState(() {
                          selectedFiliere = selected;
                        });
                      }
                    },
                    child: Container(
                      width: double.maxFinite, // Définir une largeur maximale
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
                            'Module',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Color.fromARGB(255, 17, 15, 15),
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  const SizedBox(width: 8),  // Ajouter un espace ici
                                  Text(
                                    selectedFiliere ?? 'Sélection',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Icon(Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.red,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: const Color(0xFF70A19F),
                ),
                onPressed: () async {
                  List<String> newOptions = optionsController.text.split(", ");
                  final updatedQuiz = Quiz(
                    id: quiz.id,
                    question: questionController.text,
                    niveau: niveauController.text,
                    options: newOptions,
                    correct_option: correctOptionController.text,
                    filiere: selectedFiliere ?? '',
                    score: int.tryParse(scoreController.text) ?? 0, // Ajoutez le champ score
                  );
                  try {
                    await updateQuiz(
                      updatedQuiz.id,
                      updatedQuiz.question,
                      updatedQuiz.niveau,
                      updatedQuiz.options,
                      updatedQuiz.correct_option,
                      updatedQuiz.filiere ?? '',
                      updatedQuiz.score, // Passez le score à la fonction updateQuiz
                    );
                    final updatedQuizIndex = quizs.indexWhere((q) => q.id == updatedQuiz.id);
                    if (updatedQuizIndex != -1) {
                      setState(() {
                        quizs[updatedQuizIndex] = updatedQuiz;
                        filteredQuizs = List.from(quizs);
                      });
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "La modification a réussi.",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: Color(0xFF70A19F),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Échec de la mise à jour du quz.",
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
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Échec de la mise à jour : $e",
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
                },
                child: const Text('Enregistrer'),
              ),
            ],
          );
        },
      );
    },
  );
}

  //fonction de update appel à l'api
  Future<void> updateQuiz(int id, String newQuestion, String newNiveau, List<String> newOptions, String newCorrectOption, String selectedFiliere, int newScore) async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
    if (userToken == null) {
      //print('userToken est null. Impossible de mettre à jour le Quiz.');
      return;
    }
    if (newQuestion.isEmpty || newNiveau.isEmpty || newOptions.isEmpty || newCorrectOption.isEmpty || selectedFiliere.isEmpty) {
      //print('Les nouvelles informations du quiz sont nulles ou vides. Impossible de mettre à jour le quiz.');
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('$BASE_URL/api/quizzes/$id'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: jsonEncode({
          'question': newQuestion,
          'niveau': newNiveau,
          'options': newOptions,
          'correct_option': newCorrectOption,
          'filiere_libelle': selectedFiliere,
          'score': newScore, // Inclure le champ score dans le corps de la requête
        }),
      );

      //print('Réponse de la requête HTTP : ${response.body}');
      //print('Code de statut de la réponse : ${response.statusCode}');

      if (response.statusCode == 200) {
        //print('Mise à jour réussie.');

      // Créez un nouvel objet Quiz avec les nouvelles valeurs, y compris le score
        final updatedQuiz = Quiz(
          id: id,
          question: newQuestion,
          niveau: newNiveau,
          options: newOptions,
          correct_option: newCorrectOption,
          filiere: selectedFiliere,
          score: newScore, // Assurez-vous que le modèle Quiz inclut un champ score
        );

        // Remplacez l'ancien objet dans la liste par le nouvel objet
        final updatedQuizIndex = quizs.indexWhere((q) => q.id == id);
        if (updatedQuizIndex != -1) {
          setState(() {
            quizs[updatedQuizIndex] = updatedQuiz;
            filteredQuizs = List.from(quizs);
          });
        }
      } else {
        //print('Échec de la mise à jour.');
      }
    } catch (e) {
      print('Échec de la mise à jour : $e');
    }
     finally {
      setState(() {
        isLoading = false; // Définir l'état de chargement sur false à la fin de la requête
      });
    }
  }

//fonction pour gérer la supression appel de l'api
Future<void> deleteQuiz(int id) async {
  final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
  if (userToken == null) {
    //print('userToken est null. Impossible de supprimer le Quiz.');
    return;
  }
  try {
    final response = await http.delete(
      Uri.parse('$BASE_URL/api/quizzes/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $userToken',
      },
    );

    if (response.statusCode == 200) {
      // Suppression réussie, vous pouvez mettre à jour votre liste de quizs
      setState(() {
        quizs.removeWhere((quiz) => quiz.id == id);
        filteredQuizs = List.from(quizs);
      });
    } else {
      //print('Erreur de suppression du quiz: ${response.statusCode}');
    }
  } catch (e) {
    print('Une erreur s\'est produite lors de la suppression du quiz: $e');
  }
  finally {
      setState(() {
        isLoading = false; // Définir l'état de chargement sur false à la fin de la requête
      });
    }
}

//fonction  pour afficher la boite de dialogue de suppression
Future<void> _showDeleteDialog(int id) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Êtes-vous sûr de vouloir supprimer cette question ?',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: const Color(0xFF70A19F),
            ),
            onPressed: () {
              deleteQuiz(id);
              Navigator.of(context).pop();
            },
            child: const Text('Supprimer'),
          ),
        ],
      );
    },
  );
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
              MaterialPageRoute(builder: (context) => const AdAccueilPage()),
            );
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.blueGrey,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddQuiz(),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 30, // Ajustez la taille selon vos préférences
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Ajouter',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher un questionnaire...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.white, // Couleur de l'icône de recherche
                    ),
                    hintStyle: const TextStyle(color: Colors.white), // Couleur du texte d'indice
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white), // Couleur de la bordure
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white), // Couleur de la bordure lorsque la barre de recherche est active
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (query) {
                    setState(() {
                       filteredQuizs = quizs
                      .where((quiz) =>
                      quiz.question.toLowerCase().contains(query.toLowerCase()))
                      .toList();
                    });
                  },
                  style: const TextStyle(color: Colors.white), // Couleur du texte de saisie
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(), // Afficher le CircularProgressIndicator lorsque isLoading est true
                  )
                : ListView.builder(
              itemCount: filteredQuizs.length,
              itemBuilder: (context, index) {
                final quiz = filteredQuizs[index];
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
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.orange, // Couleur de l'icône d'édition
                          ),
                          onPressed: () {
                            _showEditDialog(quiz);
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red, // Couleur de l'icône de suppression
                          ),
                          onPressed: () {
                           _showDeleteDialog(quiz.id);
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

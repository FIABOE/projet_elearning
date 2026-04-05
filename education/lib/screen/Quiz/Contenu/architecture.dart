import 'package:flutter/material.dart';
import 'package:education/screen/Quiz/quiz_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:education/utils/constances.dart';
import 'package:education/screen/Homepage/accueil_page.dart';
import 'package:advance_pdf_viewer_fork/advance_pdf_viewer_fork.dart';
import 'package:education/models/exercice.dart';
import 'dart:io';
import 'package:flutter_easyloading/flutter_easyloading.dart';


class Architecture extends StatefulWidget {
  final double averageScore; 

  const Architecture({super.key,required this.averageScore,});

  @override
  _ArchitectureState createState() => _ArchitectureState();
}

class _ArchitectureState extends State<Architecture> {
  Map<String, dynamic> userData = {};
  String? userToken;
  late List<String> quizList = [];
  late List<Exercices> exercicesList = [];
  //late List<String> reponseList = [];
  late List<Exercices> reponseList = [];
  int? filiereId;
  final int _selectedIndex = 1;
  double averageScore = 0.0;
  bool isLoading = true;

  
  // Pour récupérer la filière choisie
  Widget buildFiliereWidget() {
    if (userData['Module'] != null) {
      return Text(
        userData['Module'],
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      );
    } else {
      return const Column(
        children: [
          CircularProgressIndicator(), 
          SizedBox(height: 10), 
          Text(
            '',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      );
    }
  }


  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchUserDat();
    fetchNiveaux();
    if (filiereId != null) {
      fetchExercicesList(filiereId!);
    }
    if (filiereId != null) {
      fetchReponseList(filiereId!);
    }
  }

  //Récupérer libelle filiere
  Future<void> fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');

    final response = await http.get(
      Uri.parse('$BASE_URL/$USER_PATH'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $userToken',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final user = data['user'];
      
      if (user.containsKey('Module')) {
        setState(() {
          userData = {
            'Module': user['Module'],
          };
        });
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Erreur de chargement des données',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Une erreur s\'est produite lors du chargement des données de l\'utilisateur.',
              style: TextStyle(fontSize: 18),
            ),
            backgroundColor: const Color(0xFFF5804E),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Fermer',
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  //Recupérer id filliere
  Future<void> fetchUserDat() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
     /*await EasyLoading.show(
    status: 'veuillez patientez...',
    maskType: EasyLoadingMaskType.black,
  );*/
    final response = await http.get(
      Uri.parse('$BASE_URL/$USER_PATH'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $userToken',
      },
    );
    // Exemple de délai simulé pour les besoins de démonstration
      //await Future.delayed(Duration(seconds: 2));
      // Masquer l'indicateur de chargement
      //EasyLoading.dismiss();
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final user = data['user'];
      
      if (user.containsKey('filiere_id')) { 
        //print('ID de la filière : ${user['filiere_id']}');
        setState(() {
          userData['FiliereId'] = user['filiere_id'];
        });
        fetchExercicesList(user['filiere_id']); // Appelez fetchCoursList avec l'ID de la filière
      }

    } else {
      // Gérez l'erreur en conséquence
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Erreur de chargement des données',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Une erreur s\'est produite lors du chargement des données de l\'utilisateur.',
              style: TextStyle(fontSize: 18),
            ),
            backgroundColor: const Color(0xFFF5804E),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Fermer',
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            ],
          );
        },
      );
      //EasyLoading.dismiss();
    }
  }

  //fonction pour afficher la liste des niveaux
  Future<void> fetchNiveaux() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userToken = prefs.getString('userToken');

      final response = await http.get(
        Uri.parse('$BASE_URL/$NIVEAUX_PATH'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );
      if (response.statusCode == 200) {
        final List<String> niveaux = json.decode(response.body)["data"].cast<String>();
        setState(() {
          quizList = niveaux;
        });
      } else {
        throw Exception('Impossible de récupérer les niveaux depuis l\'API');
      }
    } catch (error) {
      // Gérez l'erreur ici si nécessaire
      print('Erreur lors de la récupération des niveaux : $error');
    }
  }

  //fonction pour afficher la liste des Exercices
   Future<void> fetchExercicesList(int filiereId) async {
    try {
      
      final prefs = await SharedPreferences.getInstance();
      userToken = prefs.getString('userToken');

      final apiUrl = Uri.parse('$BASE_URL/api/list_exercices/$filiereId');
      final response = await http.get(
        apiUrl,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)["data"];
        final List<Exercices> fetchexercices = data.map((item) {
          final id = item['id'];
          final filiereId = item['filiere_id'].toString();
          final pdfFile = item['pdf_file'];
          final pdfFileName = item['pdf_file_name'];
          final filiere = item['filiere'].toString();
          final reponse = item['reponse'];

          return Exercices(
            id: id,
            pdf_file: pdfFile,
            pdf_file_name: pdfFileName,
            filiere_id: filiereId,
            filiere: filiere,
            reponse: reponse,
          );
        }).toList();

        setState(() {
          exercicesList = fetchexercices; // Utilisez fetchexercices au lieu de exercices
        });
      } else {
        throw Exception(
          'Impossible de récupérer la liste des exercices depuis l\'API. Code de statut : ${response.statusCode}');
      }
    } catch (error) {
      print('Une erreur s\'est produite lors de la récupération des exercices : $error');
    } 
  }

  _openPDF(String pdfFile) async {
  try {
    final pdfUrl = '$BASE_URL/storage/$pdfFile';
    final pdfViewer = await PDFDocument.fromURL(pdfUrl);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewer(document: pdfViewer),
      ),
    );
  } catch (error) {
    _showErrorDialog('Impossible de lire le fichier PDF.');
  }
}
void _showErrorDialog(String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'Erreur',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 18),
        ),
        backgroundColor: const Color(0xFFF5804E),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Fermer',
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
          ),
        ],
      );
    },
  );
}


  Future<void> fetchReponseList(int filiereId) async {
    //print('ID de la filièreExercices : $filiereId'); // Affiche l'ID de la filière avant la requête
    try {
      
      final prefs = await SharedPreferences.getInstance();
      userToken = prefs.getString('userToken');
      final apiUrl = Uri.parse('$BASE_URL/api/list_exercices/$filiereId');
      //print('URL de l\'API : $apiUrl');
      final response = await http.get(
        apiUrl,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)["data"];
        final List<Exercices> fetchexercices = data.map((item) {
          final id = item['id'];
          final filiereId = item['filiere_id'].toString();
          final pdfFile = item['pdf_file'];
          final pdfFileName = item['pdf_file_name'];
          final filiere = item['filiere'].toString();
          final reponse = item['reponse'];

          return Exercices(
            id: id,
            pdf_file: pdfFile,
            pdf_file_name: pdfFileName,
            filiere_id: filiereId,
            filiere: filiere,
            reponse: reponse,
          );
        }).toList();

        setState(() {
          reponseList  = fetchexercices; // Utilisez fetchexercices au lieu de exercices
        });
      } else {
        throw Exception(
          'Impossible de récupérer la liste des exercices depuis l\'API. Code de statut : ${response.statusCode}');
      }
    } catch (error) {
      print('Une erreur s\'est produite lors de la récupération des exercices : $error');
    }
  }

  _openRES(String reponse) async {
    try {
      final pdfUrl = '$BASE_URL/storage/$reponse';
      final pdfViewer = await PDFDocument.fromURL(pdfUrl);
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewer(document: pdfViewer),
        ),
      );
    } catch (error) {
      _showErrordialog('Impossible de lire le fichier PDF.');
    }
  }
  void _showErrordialog(String message) {
    showDialog(
    context: context,
      builder: (BuildContext context) {
        return AlertDialog(
           title: const Text(
            'Erreur',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 18),
          ),
          backgroundColor: const Color(0xFFF5804E),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Fermer',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //Pour trier les niveaux par ordres
    quizList.sort((a, b) {
      int levelA = int.tryParse(a.replaceAll('niveau', '')) ?? 0;
      int levelB = int.tryParse(b.replaceAll('niveau', '')) ?? 0;
      return levelA.compareTo(levelB);
    });
    return Scaffold(
     appBar: AppBar(
  title: userData.isNotEmpty ? buildFiliereWidget() : null,
  centerTitle: true,
  backgroundColor: const Color(0xFF70A19F),
  leading: IconButton(
    icon: const Icon(
      Icons.arrow_back,
      color: Colors.white,
    ),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AccueilPage(averageScore: widget.averageScore),
        ),
      );
    },
  ),
),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),
            quizList != null
                ? _buildSectionquiz('Quiz', quizList, Icons.quiz, Colors.blue, Colors.blueAccent)
                : isLoading
                    ? const CircularProgressIndicator()
                    : Container(), 
            const SizedBox(height: 0.0),
            exercicesList != null
                ? _buildSectionexercice('Exercices', exercicesList, Icons.fitness_center, Colors.green, Colors.orangeAccent)
                : isLoading
                    ? const CircularProgressIndicator()
                    : Container(), 
            const SizedBox(height: 0.0),
            reponseList != null
                ? _buildSectionReponse('Corrigés des exercices', reponseList, Icons.check, const Color.fromARGB(255, 255, 165, 0), Colors.orangeAccent)
                : isLoading
                    ? const CircularProgressIndicator()
                    : Container(), 
          ],
        ),
      ),
    );
  }
  //liste quiz
  Widget _buildItemQuiz(String item, Color hoverColor) {
  return Container(
    decoration: const BoxDecoration(
      border: Border(
        bottom: BorderSide(color: Colors.grey),
      ),
    ),
    child: ListTile(
      leading: Icon(
        Icons.arrow_forward, // Icône personnalisée pour les éléments de la liste
        color: hoverColor, // Couleur au survol
        size: 10, 
      ),
      title: Text(
        item,
        style: const TextStyle(
          fontSize: 18, 
          fontWeight: FontWeight.bold,
          color: Colors.black, 
        ),
      ),
      onTap: () {
        // Ajoutez le code pour rediriger vers la page de quiz selon l'élément sélectionné
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizPage(
              filiereId: userData['FiliereId'],
              niveau: item, // Passez le niveau sélectionné
            ),
          ),
        );
      },
    ),
  );
}
  //carte quiz
  Widget _buildSectionquiz(String title, List<String> items, IconData icon, Color color, Color hoverColor) {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    child: ExpansionTile(
      leading: Icon(
        icon,
        color: color,
        size: 40,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      children: items.map((item) => _buildItemQuiz(item, hoverColor)).toList(),
    ),
  );
}

//liste cour
Widget _buildItemExercice(Exercices exercice, Color hoverColor, int index) {
  int exerciseNumber = index + 1;
  return Container(
    decoration: const BoxDecoration(
      border: Border(
        bottom: BorderSide(color: Colors.grey),
      ),
    ),
    child: ListTile(
      leading: Text(
        '$exerciseNumber.', // Affiche le numéro d'exercice
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      title: Text(
        exercice.pdf_file_name,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      onTap: () {
        _openPDF(exercice.pdf_file);
      },
    ),
  );
}

  //carte cour
 Widget _buildSectionexercice(String title, List<Exercices> items, IconData icon, Color color, Color hoverColor) {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    child: ExpansionTile(
      leading: Icon(
        icon,
        color: color,
        size: 40,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      onExpansionChanged: (expanded) {
        if (expanded && items.isEmpty) {
          // Chargez la liste des exercices lorsque la carte "Exercices" est ouverte et que la liste est vide
          // Appelez fetchExercicesList avec l'ID de la filière
          fetchExercicesList(userData['FiliereId']);
        }
      },
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return _buildItemExercice(item, hoverColor, index);
      }).toList(),
    ),
  );
}



Widget _buildSectionReponse(String title, List<Exercices> items, IconData icon, Color color, Color hoverColor) {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    child: ExpansionTile(
      leading: Icon(
        icon,
        color: color,
        size: 40,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      onExpansionChanged: (expanded) {
        if (expanded && reponseList.isEmpty) {
          // Chargez la liste des réponses lorsque la carte "Réponses" est ouverte et que la liste est vide
          // Appelez fetchReponseList avec l'ID de la filière
          fetchReponseList(userData['FiliereId']);
        }
      },
      children: reponseList.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return _buildItemReponse(item, hoverColor, index);
      }).toList(),
    ),
  );
}


Widget _buildItemReponse(Exercices exercice, Color hoverColor, int index) {
  int responseNumber = index + 1; // Numéro de réponse
  return Container(
    decoration: const BoxDecoration(
      border: Border(
        bottom: BorderSide(color: Colors.grey),
      ),
    ),
    child: ListTile(
      leading: Text(
        '$responseNumber.', // Affiche le numéro de réponse
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      title: Text(
        exercice.pdf_file_name,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      onTap: () {
        _openPDF(exercice.reponse);
      },
    ),
  );
}

}
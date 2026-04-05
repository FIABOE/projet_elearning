import 'package:flutter/material.dart';
import 'package:education/screenAdmin/AddExercices_page.dart';
//import 'package:education/screenAdmin/listeADD/EditCours.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:education/models/exercice.dart';
import 'package:education/utils/constances.dart';
import 'package:education/screenAdmin/Add_Mod_Exo.dart';
import 'package:education/screen/ScreenMod%C3%A9rateur/accueilMod%C3%A9rateur.dart';

class ListeExercices extends StatefulWidget {
  const ListeExercices({super.key});

  @override
  _ListeExercicesState createState() => _ListeExercicesState();
}

class _ListeExercicesState extends State<ListeExercices> {
  List<Exercices> exercices = [];
  String? userToken;
  

   @override
   void initState() {
    super.initState();
    fetchexercices();
    _getUserToken();
  }

  //Récupération du token
  Future<void> _getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
    //print('Token d\'authentification récupéré depuis les préférences : $userToken');
  }

  //Fonction pour afficher la liste des exercices
  Future<void> fetchexercices() async {
  try {
    final response = await http.get(
      Uri.parse('$BASE_URL/api/exercices'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $userToken',
      },
    );

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('success') && data['success'] == true) {
        final List<dynamic> exercicesData = data['data'];
        final List<Exercices> fetchexercices = exercicesData.map((item) {
          final id = item['id'];
          final filiereId = item['filiere_id'].toString();
          final pdfFile = item['pdf_file'];
          final pdfFileName = item['pdf_file_name'];
          final filiere = item['filiere'].toString();
          final reponse = item['reponse']; // Ajoutez cette ligne pour récupérer la valeur "reponse"

          //print('reponse: $reponse'); // Ajout de ce débogage

          return Exercices(
            id: id,
            pdf_file: pdfFile,
            pdf_file_name: pdfFileName,
            filiere_id: filiereId,
            filiere: filiere,
            reponse: reponse, // Assurez-vous que votre modèle Exercices prend en charge "reponse"
          );
        }).toList();

        setState(() {
          exercices.clear();
          exercices.addAll(fetchexercices.reversed);
        });
      } else {
        throw Exception('Failed to load exercices');
      }
    } else {
      throw Exception('Failed to load exercices');
    }
  } catch (error) {
    print('Error fetching exercices: $error');
  }
}

//voir exercice 
_openPDF(String pdfFile) async {
    // Construisez l'URL complète du fichier PDF
    final pdfUrl = 'http://:8000/storage/$pdfFile';
    //print('PDF URL : $pdfUrl');
    // Vérifiez si l'URL est valide
    if (await canLaunch(pdfUrl)) {
      await launch('$BASE_URL/storage/$pdfFile');
    } else {
    // Gérez le cas où l'URL ne peut pas être ouverte
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Erreur',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Impossible d\'ouvrir le fichier PDF.',
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
  
  //Voir exercice corrigés
  _openRES(String reponse) async {
    // Construisez l'URL complète du fichier PDF
    final pdfUrl = 'http://:8000/storage/$reponse';
    //print('PDF URL : $pdfUrl');
    // Vérifiez si l'URL est valide
    if (await canLaunch(pdfUrl)) {
      await launch('$BASE_URL/storage/$reponse');
    } else {
    // Gérez le cas où l'URL ne peut pas être ouverte
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Erreur',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Impossible d\'ouvrir le fichier PDF.',
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

 //Affichage de la boite de details des Exercices
  void showExercicesDetails(Exercices exercices) {
  showDialog(
    context: context,
    builder: (context) {
      return SingleChildScrollView(
        child: AlertDialog(
          title: const Text(
            'Détails des exercices',
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
                exercices.filiere, 
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Exercice: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                exercices.pdf_file_name,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Exercice corrigé: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                exercices.reponse, // Ajoutez cette ligne pour afficher la réponse
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _openPDF(exercices.pdf_file);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Couleur du bouton "Voir Exercice"
                    ),
                    child: const Text(
                      'Voir Exercice',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      _openRES(exercices.reponse);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Couleur du bouton "Voir Réponse"
                    ),
                    child: const Text(
                      'Voir Réponse',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
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

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            'Liste des exercices',
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
                    builder: (context) => const Add_ModExercices(),
                  ),
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color: Colors.white, 
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
            child: ListView.builder(
              itemCount: exercices.length,
              itemBuilder: (context, index) {
                final exercice = exercices[index]; // Renommez la variable ici
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    title: Text(
                      exercice.pdf_file_name, 
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
                            Icons.remove_red_eye, // Icône "vue"
                            color: Colors.green, // Couleur de l'icône "vue"
                          ),
                          onPressed: () {
                            showExercicesDetails(exercice);
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

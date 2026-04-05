import 'package:flutter/material.dart';
import 'package:education/screenAdmin/AddCours_page.dart';
import 'package:education/screenAdmin/listeADD/EditCours.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:education/models/cours.dart';
import 'package:education/utils/constances.dart';
import 'package:education/screenAdmin/Add_Mod_cours.dart';
import 'package:education/screen/ScreenMod%C3%A9rateur/accueilMod%C3%A9rateur.dart';

class ListeCours extends StatefulWidget {
  const ListeCours({super.key});

  @override
  _ListeCoursState createState() => _ListeCoursState();
}

class _ListeCoursState extends State<ListeCours> {
  List<Cours> cours = [];
  List<Cours> fetchcours = [];
  String? userToken;
  bool isLoading = false;

  
   @override
   void initState() {
    super.initState();
    fetchdcours();
    _getUserToken();
  }

  //Récupération du token
  Future<void> _getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
    //print('Token d\'authentification récupéré depuis les préférences : $userToken');
  }

  //Fonction pour afficher la liste des cours
  Future<void> fetchdcours() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');

    setState(() {
      isLoading = true; // Définir l'état de chargement sur true au début de la requête
    });

    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/api/cours'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey('success') && data['success'] == true) {
          final List<dynamic> coursData = data['data'];

          // Créer une nouvelle liste
          final List<Cours> fetchedCours = coursData.map((item) {
            final id = item['id'];
            final filiereId = item['filiere_id'].toString();
            final pdfFile = item['pdf_file'];
            final pdfFileName = item['pdf_file_name'];
            final filiere = item['filiere'].toString();

            return Cours(
              id: id,
              pdf_file: pdfFile,
              pdf_file_name: pdfFileName,
              filiere_id: filiereId,
              filiere: filiere,
            );
          }).toList();
          
          setState(() {
            cours.clear();
            cours.addAll(fetchedCours.reversed);
            fetchcours = List.from(cours); // Utiliser List.from pour créer une nouvelle instance
          });
        } else {
          throw Exception('Failed to load cours');
        }
      } else {
        throw Exception('Failed to load cours');
      }
    } catch (error) {
      print('Error fetching cours: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  ///fonction pour afficher le pdf dans un navigateur
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

 //Affichage de la boite de details des cours
  void showCoursDetails(Cours cours) {
  showDialog(
    context: context,
    builder: (context) {
      return SingleChildScrollView(
        child: AlertDialog(
          title: const Text(
            'Détails du cours',
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
                cours.filiere,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Cours: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                cours.pdf_file_name,
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
            TextButton(
              onPressed: () {
                _openPDF(cours.pdf_file);
              },
              child: const Text(
                'Lire le cours',
                style: TextStyle(
                  color: Colors.teal, // Couleur du texte pour voir le PDF
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
            'Liste des cours',
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
                    builder: (context) => const Add_ModCours(), 
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
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(), // Afficher le CircularProgressIndicator lorsque isLoading est true
                  )
                : ListView.builder(
              itemCount: cours.length,
              itemBuilder: (context, index) {
                final cour = cours[index]; // Renommez la variable ici
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    title: Text(
                      cour.pdf_file_name, 
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
                            showCoursDetails(cour);
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

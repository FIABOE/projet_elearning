import 'package:flutter/material.dart';
import 'package:education/screenAdmin/AddCours_page.dart';
import 'package:education/screenAdmin/listeADD/EditCours.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:education/models/cours.dart';
import 'package:education/utils/constances.dart';
import 'package:education/screenAdmin/adAccueil_page.dart';
import 'package:advance_pdf_viewer_fork/advance_pdf_viewer_fork.dart';
import 'dart:io';


class ListCours extends StatefulWidget {
  const ListCours({super.key});

  @override
  _ListCoursState createState() => _ListCoursState();
}

class _ListCoursState extends State<ListCours> {
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
        Uri.parse('$BASE_URL/$Cours_PATH'),
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
                'Module: ',
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

  //fonction pour gérer la supression appel de l'api
  Future<void> deleteCours(int id) async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
    //print('authentification: $userToken');

    if (userToken == null) {
      //print('userToken est null. Impossible de supprimer le Cour.');
      return;
    }
    try {
      final response = await http.delete(
        Uri.parse('$BASE_URL/api/cours/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );

      if (response.statusCode == 200) {
        // Suppression réussie, vous pouvez mettre à jour votre liste de cours
        setState(() {
          cours.removeWhere((cour) => cour.id == id);
          fetchcours = List.from(cours); 
        });
      } else {
       // print('Erreur de suppression du cour: ${response.statusCode}');
      }
    } catch (e) {
      print('Une erreur s\'est produite lors de la suppression du cour: $e');
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
              'Êtes-vous sûr de vouloir supprimer ce cour?',
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
              deleteCours(id);
              Navigator.of(context).pop();
            },
            child: const Text('Supprimer'),
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
                        builder: (context) => const AddCours(),
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
                    hintText: 'Rechercher un cours...',
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
                      fetchcours = cours
                      .where((cour) =>
                      cour.pdf_file_name.toLowerCase().contains(query.toLowerCase()))
                      .toList();
                    });
                  },
                  style: const TextStyle(color: Colors.white), 
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
              itemCount: fetchcours.length,
              itemBuilder: (context, index) {
                final cour = fetchcours[index]; // Renommez la variable ici
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
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red, 
                          ),
                          onPressed: () {
                            _showDeleteDialog(cour.id);
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

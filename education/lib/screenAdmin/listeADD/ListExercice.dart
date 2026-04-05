import 'package:flutter/material.dart';
import 'package:education/screenAdmin/AddExercices_page.dart';
//import 'package:education/screenAdmin/listeADD/EditCours.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:education/models/exercice.dart';
import 'package:education/utils/constances.dart';
import 'package:advance_pdf_viewer_fork/advance_pdf_viewer_fork.dart';
import 'package:education/screenAdmin/adAccueil_page.dart';
import 'dart:io';

class ListExercices extends StatefulWidget {
  const ListExercices({super.key});

  @override
  _ListExercicesState createState() => _ListExercicesState();
}

class _ListExercicesState extends State<ListExercices> {
  List<Exercices> exercices = [];
  List<Exercices> filteredExercices = [];
  String? userToken;
  bool isLoading = false;

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
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');

    setState(() {
    isLoading = true; // Définir l'état de chargement sur true au début de la requête
  });
  try {
    final response = await http.get(
      Uri.parse('$BASE_URL/$Exercice_PATH'),
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
          final reponse = item['reponse']; 

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
          filteredExercices = List.from(exercices);
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
  finally {
    setState(() {
      isLoading = false; 
    });
  }
}

//voir exercice 
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

  
  //Voir exercice corrigés
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
                'Module: ',
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
              /*SizedBox(height: 10),
              Text(
                'Exercice corrigé: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                exercices.reponse, 
                style: TextStyle(
                  fontSize: 18,
                ),
              ),*/
              const SizedBox(height: 20),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _openPDF(exercices.pdf_file);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, 
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

  //fonction pour gérer la supression appel de l'api
  Future<void> deleteExercices(int id) async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
    if (userToken == null) {
      //print('userToken est null. Impossible de supprimer l\'exercice');
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse('$BASE_URL/api/exercices/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );
      if (response.statusCode == 200) {
        // Suppression réussie, vous pouvez mettre à jour votre liste exercice
        setState(() {
          exercices.removeWhere((exercice) => exercice.id == id);
          filteredExercices = List.from(exercices);
        });
      } else {
        //print('Erreur de suppression de l\'exercice: ${response.statusCode}');
      }
    } catch (e) {
      print('Une erreur s\'est produite lors de la suppression de l\'exercice: $e');
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
              'Êtes-vous sûr de vouloir supprimer cet exercice?',
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
              deleteExercices(id);
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
                        builder: (context) => const AddExercices(),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 30, 
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
                    hintText: 'Rechercher un exercice...',
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
                       filteredExercices = exercices
                      .where((exercice) =>
                      exercice.pdf_file_name.toLowerCase().contains(query.toLowerCase()))
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
                    child: CircularProgressIndicator(), 
                  )
                : ListView.builder(
              itemCount: filteredExercices.length,
              itemBuilder: (context, index) {
                final exercice = filteredExercices[index]; 
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
                            Icons.remove_red_eye, 
                            color: Colors.green, 
                          ),
                          onPressed: () {
                            showExercicesDetails(exercice);
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red, 
                          ),
                          onPressed: () {
                            _showDeleteDialog(exercice.id);
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

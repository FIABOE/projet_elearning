import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:education/models/cours.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:education/utils/constances.dart';
import 'package:education/screen/Compte/compte_page.dart';

class ListFavoriPage extends StatefulWidget {

  final double averageScore;
  const ListFavoriPage({super.key, required this.averageScore,});

  @override
  _ListFavoriPageState createState() => _ListFavoriPageState();
}

class _ListFavoriPageState extends State<ListFavoriPage> {
  List<Cours> cours = [];
  List<String> coursList = [];
  List<String> filteredCoursList = [];
  Map<String, dynamic> userData = {};
  String? userToken;
  String searchText = "";
  int? filiereId;
  double averageScore = 0.0;
  bool hasFavoriteCours = false;

 
  @override
  void initState() {
    super.initState();
    _getUserToken();
    fetchFavoriteCours();
  }


  //Récupération du token
  Future<void> _getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
  }
  
 Future<void> fetchFavoriteCours() async {
  try {
    //print('Avant la requête HTTP');
    //print('Token d\'utilisateur : $userToken');
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
    final response = await http.get(
      Uri.parse('$BASE_URL:8000/api/get_favorite_cours'), 

      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $userToken',
      },
    );

    //print('Après la requête HTTP');
    // Ajout d'un print pour le corps de la réponse
    //print('Corps de la réponse : ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['favoriCours'];
       
      setState(() {
        coursList = List<String>.from(data);
        filteredCoursList = List<String>.from(data);
        hasFavoriteCours = coursList.isNotEmpty;
      });
    //print('Cours favoris récupérés avec succès');
      } else {
      //print('Échec de la récupération des cours favoris (status code: ${response.statusCode})');
        throw Exception('Échec de la récupération des cours favoris');
      }
     } catch (error) {
        
        //print('Erreur lors de la récupération des cours favoris : $error');
    }
  }



   ///fonction pour afficher le pdf dans un navigateur
  _openPDF(String pdfFile) async {
    // Construisez l'URL complète du fichier PDF
    final pdfUrl = 'http://:8000/storage/$pdfFile';
    //print('PDF URL : $pdfUrl');
    // Vérifiez si l'URL est valide
    if (await canLaunch(pdfUrl)) {
      await launch('$BASE_URL:8000/storage/$pdfFile');
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
  
   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mes cours favoris',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
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
            Navigator.push(context, 
            MaterialPageRoute(builder: (context) => ComptePage(averageScore: widget.averageScore)));
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  style: const TextStyle(fontSize: 16),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Rechercher un cours',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                      filteredCoursList = coursList
                          .where((cours) =>
                              cours.toLowerCase().contains(searchText.toLowerCase()))
                          .toList();
                    });
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredCoursList.length,
              itemBuilder: (context, index) {
                final coursItem = filteredCoursList[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(
                      coursItem,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    leading: const Icon(
                      Icons.description,
                      color: Color(0xFFF5804E),
                    ),
                    onTap: () {
                      _openPDF(coursItem);
                    },
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
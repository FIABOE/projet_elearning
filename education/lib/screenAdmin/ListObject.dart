import 'package:flutter/material.dart';
import 'package:education/screenAdmin/AddObjectif_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:education/models/filiere.dart';
import 'package:education/models/objectif.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:education/models/moderateur.dart';
import 'package:education/utils/constances.dart'; 
import 'package:education/screenAdmin/Add_Mod_object.dart';
import 'package:education/screen/ScreenMod%C3%A9rateur/accueilMod%C3%A9rateur.dart';

class ListeObjectif extends StatefulWidget {
  const ListeObjectif({super.key});

  @override
  _ListeObjectifState createState() => _ListeObjectifState();
}

class _ListeObjectifState extends State<ListeObjectif> {
  List<Objectif> objectifs = [];
  List<Objectif> filteredObjectifs = [];
  String? userToken;
  bool isLoading = false;


  @override
  void initState() {
    super.initState();
    fetchObjectifs();
     _getUserToken();
  }
  
  Future<void> _getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
    //print('Token d\'authentification récupéré depuis les préférences : $userToken');
  }

  Future<void> fetchObjectifs() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');

    setState(() {
      isLoading = true; // Définir l'état de chargement sur true au début de la requête
    });

    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/api/objectifs'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey('data') && data['data'] is List<dynamic>) {
          final List<dynamic> objectifsData = data['data'];
          final List<Objectif> fetchedObjectifs = objectifsData
            .map((item) => Objectif(id: item['id'], libelle: item['libelle'].toString()))
            .toList();

          setState(() {
            objectifs.clear();
            objectifs.addAll(fetchedObjectifs.reversed); // Inverser l'ordre de la liste
            filteredObjectifs = List.from(objectifs); // Créer une copie pour la recherche
          });
        } else {
          throw Exception('Failed to load objectifs');
        }
      } else {
        throw Exception('Failed to load objectifs');
      }
    } catch (error) {
      print('Error fetching objectifs: $error');
    } finally {
      setState(() {
        isLoading = false; // Définir l'état de chargement sur false à la fin de la requête
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            'Liste des objectifs',
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
                    builder: (context) => const Add_ModObjectif(), // Redirige vers AddQuiz
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
                    child: CircularProgressIndicator(), 
                  )
                : ListView.builder(
              itemCount: objectifs.length,
              itemBuilder: (context, index) {
                final objectif = objectifs[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    title: Text(
                      objectif.libelle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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

import 'package:flutter/material.dart';
import 'package:education/screenAdmin/Add_filiere.dart';
import 'package:education/screenAdmin/Add_Mod_fill.dart';
import 'package:education/screen/ScreenMod%C3%A9rateur/accueilMod%C3%A9rateur.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:education/models/filiere.dart';
import 'package:education/models/moderateur.dart'; 
import 'package:education/utils/constances.dart';

class ListFilieree extends StatefulWidget {
  const ListFilieree({super.key});

  @override
  _ListFiliereeState createState() => _ListFiliereeState();
}

class _ListFiliereeState extends State<ListFilieree> {
  List<Filiere> filieres = [];
  List<Filiere> filteredFilieres = [];
  String? userToken;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchFilieres();
    _getUserToken();
  }

   //fonction pour la recuperation du token
  Future<void> _getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
    //print('Token d\'authentification récupéré depuis les préférences : $userToken');
  }
  
  //Fonction pour afficher la liste des filières
  Future<void> fetchFilieres() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
    //print('authentification: $userToken');
    setState(() {
      isLoading = true; // Définir l'état de chargement sur true au début de la requête
    });
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/api/filieres'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey('data') && data['data'] is List<dynamic>) {
          final List<dynamic> filieresData = data['data'];
          final List<Filiere> fetchedFilieres = filieresData
              .map((item) => Filiere(id: item['id'], libelle: item['libelle'].toString()))
              .toList();
          setState(() {
            filieres.clear();
            filieres.addAll(fetchedFilieres.reversed); // Inverser l'ordre de la liste
            filteredFilieres.addAll(fetchedFilieres.reversed);
          });
        } else {
          throw Exception('Failed to load filieres');
        }
      } else {
        throw Exception('Failed to load filieres');
      }
    } catch (error) {
      print('Error fetching filieres: $error');
    }
    finally {
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
            'Liste des Moduless',
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
            color: Colors.blueGrey,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Add_ModFiliere(),
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
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
           Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(), 
                  )
                : ListView.builder(
              itemCount: filieres.length,
              itemBuilder: (context, index) {
                final filiere = filieres[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    title: Text(
                      filiere.libelle,
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

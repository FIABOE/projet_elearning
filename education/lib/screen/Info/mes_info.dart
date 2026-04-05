// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import '../Homepage/accueil_page.dart';
import '../omboard/onboarding_screen.dart';
import 'package:education/screen/Profil/boite_profil.dart';
import 'package:education/screen/Info/objectif_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:education/utils/constances.dart';

class MesinfoPage extends StatefulWidget {
  const MesinfoPage({super.key});

  @override
  _MesinfoPageState createState() => _MesinfoPageState();
}

class _MesinfoPageState extends State<MesinfoPage> {
  Map<String, dynamic> userData = {}; 
  String? userToken;
  bool isLoading = true;

  TextEditingController emailController = TextEditingController();
  TextEditingController dateNaissanceController = TextEditingController();
  TextEditingController prenomController = TextEditingController();
  TextEditingController nomController = TextEditingController();
  TextEditingController filiereController = TextEditingController();
  TextEditingController objectifHebdomadaireController = TextEditingController();


  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');

    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/api/user'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        // AJOUTE CE PRINT POUR VOIR LA RÉPONSE COMPLÈTE
        print('🔵 RÉPONSE API COMPLÈTE: $data');

        if (data.containsKey('user')) {
          final user = data['user'];
          print('🔵 USER DATA: $user'); 

          setState(() {
            userData = {
              'Nom': user['Nom'] ?? '',
              'Prenom': user['Prenom'] ?? '',
              'Email': user['Email'] ?? '',
              'Date de Naissance': user['Date de Naissance'] ?? '',
              'Module': user['Module'] ?? '',
              'Objectif hebdomadaire': user['Objectif hebdomadaire'] ?? '',
            };

            // Mettez à jour les contrôleurs de texte avec les valeurs des données utilisateur
            emailController.text = userData['Email'];
            dateNaissanceController.text = userData['Date de Naissance'];
            prenomController.text = userData['Prenom'];
            nomController.text = userData['Nom'];
            filiereController.text = userData['Module'];
            objectifHebdomadaireController.text = userData['Objectif hebdomadaire'];
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
    } catch (error) {
      print('Erreur lors de la récupération du profil utilisateur : $error');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            'Tolearnio',
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
            Navigator.push(context, 
            MaterialPageRoute(builder: (context) => const ObjectifPage()));
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Veuillez vérifier vos informations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF087B95),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView.builder(
                itemCount: userData.length,
                itemBuilder: (context, index) {
                  final label = userData.keys.elementAt(index);
                  final value = userData[label];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            label,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              value.toString(),
                              style: const TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                    MaterialPageRoute(builder: (context) => const BoitePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF70A19F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: Colors.black.withOpacity(0.2),
                    width: 1.0,
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16), // Augmenter la hauteur du bouton
              ),
              child: const Text(
                'Valider',
                style: TextStyle(
                  fontSize: 20, // Augmenter la taille du texte
                  color: Colors.white, // Changer la couleur du texte en blanc
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


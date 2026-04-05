import 'package:education/screen/Compte/Avatar_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:education/utils/constances.dart';
import 'package:education/screen/Compte/change_password.dart';

class AdminProfilePage extends StatefulWidget {
   final double averageScore;
  const AdminProfilePage({super.key, required this.averageScore,});
  
  @override
  _AdminProfilePageState createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  TextEditingController emailController = TextEditingController();
  //TextEditingController dateNaissanceController = TextEditingController();
  TextEditingController prenomController = TextEditingController();
  TextEditingController nomController = TextEditingController();
  TextEditingController dateCreationController = TextEditingController();
  //String dateNaissance = '';
  String dateCreation = '';
  String prenom = '';
  String nom = '';
  String email = '';
  String? userToken;

  Map<String, dynamic> userData = {
    'Nom': '',
    'Prenom': '',
    //'Date de Naissance': '',
    'Date de création': '',
    'Email': '',
  };

  @override
  void initState() {
    super.initState(); 
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken'); 
    //print('authentification: $userToken');
    
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
      //print('utilisateur: $user');
      
      if (user.containsKey('Email',)) {
        setState(() {
          userData = {
            'Email': user['Email'],
            //'Date de Naissance': user['Date de Naissance'],
            'Date de création' : user['Date de création'],
            'Prenom': user['Prenom'],
            'Nom': user['Nom'],
          };
          emailController.text = userData['Email'] ?? '';
          //pseudoController.text = userData['Pseudo'] ?? '';
          //dateNaissanceController.text = userData['Date de Naissance'] ?? '';
          dateCreationController.text = userData['Date de création'] ?? '';
          prenomController.text = userData['Prenom'] ?? '';
          nomController.text = userData['Nom'] ?? '';
          //print('Email récupérée avec succès : ${userData['Email']}');
        });
      } else {
       // print("La clé 'Email hebdomadaire' n'est pas présente dans les données de l'utilisateur.");
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
 @override
 Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Text(
          'Profil',
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
          Navigator.pop(context);
        },
      ),
    ),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Cercle de l'avatar
                      const CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 80,
                          color: Color(0xFF70A19F),
                        ),
                      ),

                      // Icône de modification (crayon)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            // Ajoutez ici le code pour gérer le clic sur le bouton d'édition
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.orange,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
              Row(
                children: [ 
                  const Text(
                    'Nom:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    userData['Nom'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ]
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text(
                    'Prénom:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    userData['Prenom'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ]
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text(
                    'Adresse e-mail:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    userData['Email'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ]
              ),
              const SizedBox(height: 10), 
              Row(
                children: [
                  const Text(
                    'Date de création:', 
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    userData['Date de création'] ?? '', 
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ]
          ),
        ),
      ),
    );
  }
}

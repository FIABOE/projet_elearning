import 'package:flutter/material.dart';
import 'package:education/screen/Compte/compte_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:education/models/user.dart';
import 'package:education/screen/omboard/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:education/utils/constances.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class  _SettingsPageState extends State<SettingsPage> {
  //bool isDarkMode = false;
   String? userToken;
   int? userId;

   bool isDarkMode = false;

   //Récupération du token
  Future<void> _getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
  }

  @override
  void initState() {
  super.initState();
  _getUserToken();
  fetchUserData();
  
}

Future<void> fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');

    final response = await http.get(
      Uri.parse('$BASE_URL:8000/api/user'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $userToken',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final user = data['user'];

      if (user.containsKey('id')) {
        userId = user['id']; // Affectez la valeur à userId
        //print('ID de l\'utilisateur : $userId');
      } else {
        print("La clé 'id' n'est pas présente dans les données de l'utilisateur.");
      }
    } else {
      print('Une erreur s\'est produite lors du chargement des données de l\'utilisateur.');
    }
  }


 Future<void> deleteAccount(int id) async {
  final String apiUrl = '$BASE_URL:8000/api/users/$id';

  final prefs = await SharedPreferences.getInstance();
  userToken = prefs.getString('userToken');
  try {
    final response = await http.delete(
      Uri.parse(apiUrl), 
      headers: {
        'Authorization': 'Bearer $userToken', 
      },
    );
    //print('Authorization: Bearer $userToken');
    if (response.statusCode == 200) {
      // La suppression du compte a réussi
      // Vous pouvez ici effectuer des actions supplémentaires (ex. redirection, affichage d'un message, etc.)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compte supprimé avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      // Rediriger l'utilisateur vers la page d'onboarding
      // Utilisez Navigator pour gérer la navigation
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const OnboardingScreen(), // Remplacez par votre page d'onboarding
      ));
    } else {
      // Gérer les erreurs ici (ex. afficher un message d'erreur)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Une erreur s\'est produite lors de la suppression du compte'),
          backgroundColor: Colors.red,
        ),
      );
      // Enregistrez les erreurs du serveur dans la console
      if (response.statusCode >= 400) {
        //print('Erreur du serveur: ${response.statusCode} - ${response.reasonPhrase}');
        //print('Réponse du serveur: ${response.body}');
      }
    }
  } catch (e) {
    // Gérer les erreurs de connexion ici
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Erreur de connexion'),
        backgroundColor: Colors.red,
      ),
    );
    print('Erreur de connexion: $e');
  }
}

 @override
 Widget build(BuildContext context) {
 return Theme(
    data: ThemeData(
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
    ),
    child: Scaffold(
    appBar: AppBar(
      title: const Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Text(
          'Paramètres',
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
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Préférences générales',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Notifications',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
            ),
            trailing: Switch(
              value: true, // Vous pouvez utiliser une variable pour gérer l'état ici
              onChanged: (bool value) {
                // Gérez l'état de la notification ici
              },
              activeTrackColor: Colors.teal, // Couleur de la piste (track) lorsqu'elle est active
              activeColor: Colors.teal, // Couleur du bouton lorsqu'il est activé
            ),
          ),
          ListTile(
          title: const Text(
            'Mode sombre',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: Switch(
            value: isDarkMode,
            onChanged: (bool value) {
              setState(() {
                isDarkMode = value;
              });
            },
            activeTrackColor: Colors.teal,
            activeColor: Colors.teal,
          ),
        ),
          const Divider(), 
        ],
      ),
    ),
  ),
 );
}
}
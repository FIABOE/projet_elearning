// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'Avatar_page.dart';
import 'update_page.dart';
import '../omboard/onboarding_screen.dart';
import 'package:education/screen/Compte/setting.dart';
import 'package:education/screen/Quiz/list_favori.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:education/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:education/utils/constances.dart';
import 'package:education/screen/Homepage/accueil_page.dart';
import 'package:education/screen/Compte/change_password.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ComptePage extends StatefulWidget {
  final double averageScore; 
  const ComptePage({super.key,required this.averageScore,});

  @override
  _ComptePageState createState() => _ComptePageState();
}

class _ComptePageState extends State<ComptePage> {
  Map<String, dynamic> userData = {};
  String pseudo = '';
  String email = '';
  String avatarUrl = ''; 
  String? userToken;
  double userRating = 0.0;
  int? userId;
  double averageScore = 0.0;
  //bool isLoading = true;

  //Modal pour Confirmer la deconnection
  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Déconnexion',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: const Text(
            'Êtes-vous sûr de vouloir vous déconnecter ?',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Annuler',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.red,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                    );
                  },
                  child: const Text(
                    'Déconnecter',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
  //fonction qui traite le profil du user
  Future<void> fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
    await EasyLoading.show(
      status: 'veuillez patientez...',
      maskType: EasyLoadingMaskType.black,
    );
    try {
      print('Début de la requête HTTP');
      final response = await http.get(
        Uri.parse('$BASE_URL/$PROFILE_PATH'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );
      // Exemple de délai simulé pour les besoins de démonstration
      await Future.delayed(const Duration(seconds: 2));
      // Masquer l'indicateur de chargement
      EasyLoading.dismiss();
      //print('Réponse HTTP reçue');
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('success') && data['success'] == true) {
          // Récupérez le pseudo et l'URL de l'avatar depuis les données du profil
          final String userPseudo = data['pseudo'];
          final String userAvatarRelativeUrl = data['avatar'];

          // Remplacez ceci par l'URL de base de votre serveur
          const baseUrl = '$BASE_URL/storage';
          // Construisez l'URL absolue en combinant la base de l'URL et l'URL relative de l'avatar
          final userAvatarUrl = '$baseUrl/$userAvatarRelativeUrl';

          print('Pseudo récupéré : $userPseudo');
          print('URL de l\'avatar récupéré : $userAvatarUrl');
          setState(() {
            pseudo = userPseudo; // Mettez à jour le pseudo dans l'état local
            avatarUrl = userAvatarUrl; // Mettez à jour l'URL de l'avatar dans l'état local
          });
          print('Mise à jour de l\'état local effectuée');
        }
      }
    } catch (error) {
      print('Erreur lors de la récupération du profil utilisateur : $error');
      EasyLoading.dismiss();
    } 
  }

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
    fetchUserData();
    fetchUserDataID();
  }
  //Récupération de la filiere
  Future<void> fetchUserData() async {
    try {
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
        if (user.containsKey('Email')) {
          setState(() {
            userData = {
              'Email': user['Email'],
            };
            //print('Email récupérée avec succès : ${userData['Email']}');
          });
        } else {
        print("La clé 'Email hebdomadaire' n'est pas présente dans les données de l'utilisateur.");
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
    } catch (e) {
      // Gérez les erreurs ici
      print('Une erreur s\'est produite: $e');
    }
  }

 // Fonction pour récupérer l'ID de l'utilisateur
  Future<void> fetchUserDataID() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userToken = prefs.getString('userToken');

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

        if (user.containsKey('id')) {
          userId = user['id']; // Affectez la valeur à userId
          //print('ID de l\'utilisateur : $userId');
        } else {
          print("La clé 'id' n'est pas présente dans les données de l'utilisateur.");
        }
      } else {
        print('Une erreur s\'est produite lors du chargement des données de l\'utilisateur.');
      }
    } catch (e) {
      // Gérez les erreurs ici
      print('Une erreur s\'est produite: $e');
    }
  }

// Fonction pour soumettre la note
  void submitUserRating(int rating) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userToken = prefs.getString('userToken');
      const apiUrl = '$BASE_URL/$SUBMITRATING_PATH';
        //print('URL de la soumission de note : $apiUrl');  // Ajoutez cette ligne pour afficher l'URL
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $userToken',
        },
        body: jsonEncode(<String, dynamic>{
          'rating': rating,
        }),
      );
      //print('Réponse de la soumission de note : ${response.body}');
      if (response.statusCode == 200) {
        //print('Note soumise avec succès');
      } else {
        //print('Erreur lors de la soumission de la note');
      }
    } catch (e) {
      // Gérez les erreurs ici
      print('Une erreur s\'est produite: $e');
    }
  }

  // Fonction pour récupérer la note de l'utilisateur
  Future<void> fetchUserRating(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userToken = prefs.getString('userToken');
      final response = await http.get(
        Uri.parse('$BASE_URL/api/users/$id/rating'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userRating = data['rating'];
        });
      } else {
        print('Erreur lors de la récupération de la note');
      }
    } catch (e) {
      // Gérez les erreurs ici
      print('Une erreur s\'est produite: $e');
    }
  }
  ///Modal qui permet de noter l'app
  void openRatingDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Noter l\'application'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('Veuillez attribuer une note à notre application.'),
              RatingBar.builder(
                initialRating: userRating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 4, // 4 étoiles au lieu de 5
                itemSize: 40.0,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  submitUserRating(rating.toInt()); // Convertissez rating en entier
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Annuler',
                style: TextStyle(
                  color: Colors.red, 
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Enregistrer',
                style: TextStyle(
                  color: Colors.green, 
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                onRatingUpdate: (rating) {
                  submitUserRating(rating.toInt()); // Convertissez rating en entier
                };
                Navigator.of(context).pop();
              },
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
            'Mon compte',
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
          Navigator.push(context, 
          MaterialPageRoute(builder: (context) => AccueilPage(averageScore: widget.averageScore)));
        },
      ),
    ),
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5.0,
                    spreadRadius: 2.0,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(avatarUrl as String? ?? 'b.png'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                      ' $pseudo',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userData['Email'] ?? '',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
                  MenuItem(
                    icon: Icons.edit,
                    title: 'Modifier mon compte',
                    color: Colors.deepOrange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UpdateComptePage(averageScore: widget.averageScore)),
                      );
                    },
                  ),
                  MenuItem(
                    icon: Icons.star,
                    title: 'Noter l\'application',
                    color: Colors.amber,
                    onTap: () {
                      openRatingDialog();
                    },
                  ),
                  MenuItem(
                    icon: Icons.logout,
                    title: 'Se déconnecter',
                    circleIcon: true,
                    color: Colors.orange,
                    onTap: () {
                      _showLogoutConfirmationDialog();
                    },
                  ),
                  MenuItem(
                    icon: Icons.password,
                    title: 'Changer le mot de pass',
                    circleIcon: true,
                    color: Colors.blue,
                    onTap: () async {
                       final prefs = await SharedPreferences.getInstance();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                      );
                    },
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
class MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final bool circleIcon;
  final bool deleteIcon;
  final VoidCallback? onTap;

  const MenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.color = Colors.black,
    this.circleIcon = false,
    this.deleteIcon = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, 
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: circleIcon ? BoxShape.circle : BoxShape.rectangle,
            color: deleteIcon ? Colors.red : color,
            border: deleteIcon ? Border.all(color: Colors.red, width: 2.0) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 3.0,
                spreadRadius: 1.0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: deleteIcon ? const Icon(Icons.close, color: Colors.white, size: 20) : Icon(icon, color: Colors.white, size: 24),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ),
    );
  }
}


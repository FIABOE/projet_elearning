import 'package:education/screenAdmin/ListObject.dart';
import 'package:flutter/material.dart';
import 'package:education/screenAdmin/listeADD/ListObjectif.dart';
import 'package:education/screenAdmin/listeADD/ListeFill.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:education/utils/constances.dart';

class AddObjectif extends StatefulWidget {
  const AddObjectif({super.key});

  @override
  _AddObjectifState createState() => _AddObjectifState();
}

class _AddObjectifState extends State<AddObjectif> {
  TextEditingController objectifController = TextEditingController();
  bool isValiderButtonEnabled = false;
  bool isFormSubmitted = false;
  bool isSubmitting = false;
  String? userToken;
  int totalFilieres = 0;
  int totalObjectifs = 0;
  int totalCours = 0;
  int totalQuiz = 0;
  int totalExercices = 0;
  int totalApprenants = 0;
  int totalModerateurs = 0;

  @override
  void initState() {
    super.initState();
    _getUserToken();
    fetchData();
  }

  Future<void> _getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
    //print('Token d\'authentification récupéré depuis les préférences : $userToken');
  }

  Future<void> ajouterObjectif(String objectif) async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
    //print('authentification: $userToken');
    const String apiUrl = '$BASE_URL/api/objectifs';

    final Map<String, dynamic> formData = {
      'libelle': objectif,
    };

    try {
      setState(() {
        isSubmitting = true;  // Activer le flag de soumission
      });
      final response = await http.post(
        Uri.parse(apiUrl),
        body: formData,
        headers: {
          'Accept': 'application/json', 
          'Authorization': 'Bearer $userToken',
        },
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Objectif ajoutée avec succès.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: Color(0xFF70A19F),
          ),
        );
        // Réinitialisez le champ de l'Objectif après l'ajout réussi.
        //objectifController.clear();
        setState(() {
          objectifController.clear();
          isValiderButtonEnabled = false;
          isFormSubmitted = true;
        });
        await fetchData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'L\'objectif ajouté avec succès.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: Color(0xFFF5804E),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Une erreur s\'est produite : $error',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFFF5804E),
        ),
      );
    }
    finally {
      setState(() {
        isSubmitting = false;  // Désactiver le flag de soumission
      });
    }
  }


  Future<void> fetchData() async {
    final Uri apiUrl = Uri.parse('$BASE_URL/api/get-totals');
    try {
      final response = await http.get(
        apiUrl,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          totalApprenants = data['total_apprenants'];
          totalModerateurs = data['total_moderateurs'];
          totalFilieres = data['total_filiere'];
          totalObjectifs = data['total_objectif'];
          totalCours = data['total_cours'];
          totalQuiz = data['total_quiz'];
          totalExercices = data['total_exercices'];
        });
      } else {
        // Gérer les erreurs ici, par exemple, afficher un message d'erreur
        print('Erreur lors de la récupération des données : ${response.statusCode}');
      }
    } catch (exception) {
      // Gérer les exceptions ici, par exemple, afficher un message d'erreur
      print('Exception lors de la récupération des données : $exception');
    }
  }
  
  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'Ajouter un objectif',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 24,
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
      actions: [
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ListeObjectif(),
              ),
            );
          },
          child: const Row(
            children: [
              Icon(
                Icons.list,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ],
    ),
    body: Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          const SizedBox(height: 30),
          /*_buildObjectifTextField(),
          SizedBox(height: 80),
          _buildSubmitButton(),*/
          _buildObjectifTextField(),
      const SizedBox(height: 80),
      _buildSubmitButton(),
        ],
      ),
    ),
    backgroundColor: const Color(0xFFF0F0F0),
  );
}

Widget _buildObjectifTextField() {
  return TextField(
    controller: objectifController,
    onChanged: (text) {
      setState(() {
          isValiderButtonEnabled = text.isNotEmpty && !isFormSubmitted;
        });
    },
    style: const TextStyle(fontSize: 18),  // Ajustement de la taille du texte
    decoration: InputDecoration(
      labelText: 'Renseigner l\'objectif',
      labelStyle: const TextStyle(color: Color(0xFF70A19F)),  // Couleur de l'étiquette
      hintStyle: TextStyle(color: Colors.grey[600]),  // Couleur du texte d'indication
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF70A19F)),
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}


 Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: isValiderButtonEnabled && !isSubmitting
          ? () {
              ajouterObjectif(objectifController.text);
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF70A19F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Text(
              'Soumettre',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            if (isSubmitting)
              const Positioned(
                right: 16.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
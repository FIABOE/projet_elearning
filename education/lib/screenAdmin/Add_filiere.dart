import 'package:flutter/material.dart';
import 'package:education/screenAdmin/listeADD/ListeFill.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:education/utils/constances.dart';

class AddFiliere extends StatefulWidget {
  const AddFiliere({super.key});

  @override
  _AddFiliereState createState() => _AddFiliereState();
}

class _AddFiliereState extends State<AddFiliere> {
  TextEditingController filiereController = TextEditingController();
  bool isValiderButtonEnabled = false;
  String? userToken;
  String errorMessage = '';
  bool isFormSubmitted = false;
  int totalFilieres = 0;
  int totalObjectifs = 0;
  int totalCours = 0;
  int totalQuiz = 0;
  int totalExercices = 0;
  int totalApprenants = 0;
  int totalModerateurs = 0;
  bool isSubmitting = false;

  Future<void> _getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
    //print('Token d\'authentification récupéré depuis les préférences : $userToken');
  }

  Future<void> ajouterFiliere(String filiere) async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
    //print('authentification: $userToken');
    const String apiUrl = '$BASE_URL/$FILIERE_PATH';
    final Map<String, dynamic> formData = {
      'libelle': filiere,
    };
    try {
      setState(() {
        isSubmitting = true; // Activer le flag de soumission
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
              'Filière ajoutée avec succès.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: Color(0xFF70A19F),
          ),
        );
        // Réinitialisez le champ de filière après l'ajout réussi.
         setState(() {
          filiereController.clear();
          isValiderButtonEnabled = false;
          isFormSubmitted = true;
        });
        // Après avoir ajouté le module, appelez fetchData pour mettre à jour les totaux
        await fetchData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Cette filière existe déjà.',
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
          backgroundColor: const Color(0xFFFC6161),
        ),
      );
    }
    finally {
      setState(() {
        isSubmitting = false; // Désactiver le flag de soumission
      });
    }
  }

  Future<void> fetchData() async {
    final Uri apiUrl = Uri.parse('$BASE_URL/$Total_Get_PATH');

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
       // print('Erreur lors de la récupération des données : ${response.statusCode}');
      }
    } catch (exception) {
      // Gérer les exceptions ici, par exemple, afficher un message d'erreur
      print('Exception lors de la récupération des données : $exception');
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserToken();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ajouter un module',
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
                  builder: (context) => const ListFill(),
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
            _buildFiliereTextField(),
            const SizedBox(height: 8),
            _buildErrorMessage(),
            const SizedBox(height: 80),
            _buildSubmitButton(),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF0F0F0),
    );
  }

  Widget _buildFiliereTextField() {
    return TextField(
      controller: filiereController,
      onChanged: (text) {
        setState(() {
          isValiderButtonEnabled = _isValidInput(text);
          errorMessage = _isValidInput(text) ? '' : 'Veuillez entrer uniquement des lettres.';
        });
      },
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
        labelText: 'Renseigner un module',
        labelStyle: const TextStyle(color: Color(0xFF70A19F)),
        hintStyle: TextStyle(color: Colors.grey[600]),
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

  Widget _buildErrorMessage() {
    return Text(
      errorMessage,
      style: const TextStyle(
        color: Colors.red,
        fontSize: 14,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: isValiderButtonEnabled && !isSubmitting
          ? () {
              ajouterFiliere(filiereController.text);
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
  bool _isValidInput(String input) {
  final RegExp lettersWithAccents = RegExp(r'^[a-zA-ZÀ-ÿ ]+$');
  return lettersWithAccents.hasMatch(input);
}

}
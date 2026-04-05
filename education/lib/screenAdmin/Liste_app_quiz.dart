import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:education/models/user.dart';
import 'package:education/models/apprenant.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:education/screenAdmin/Sta_apprenant.dart';
import 'package:education/screenAdmin/Score_apprenant.dart';
import 'package:education/screenAdmin/temps_Apprenant.dart';
import 'package:education/utils/constances.dart';
import 'package:education/screenAdmin/adAccueil_page.dart';

class ListAppQuiz extends StatefulWidget {
  const ListAppQuiz({super.key});

  @override
  _ListAppQuizState createState() => _ListAppQuizState();
}

class _ListAppQuizState extends State<ListAppQuiz> {
  List<Apprenant> apprenants = [];
  List<Apprenant> filteredApprenants = [];
  String? userToken;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchApprenants();
    _getUserToken();
  }

  // Récupération du token
  Future<void> _getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
  }

   String getCurrentDate() {
    final now = DateTime.now();
    final formattedDate = "${now.day}/${now.month}/${now.year}";
    return formattedDate;
  }

  // Fonction pour afficher la liste des Apprenants
  Future<void> fetchApprenants() async {
    setState(() {
      isLoading = true; // Définir l'état de chargement sur true au début de la requête
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      userToken = prefs.getString('userToken');
      final response = await http.get(
        Uri.parse('$BASE_URL/api/users-who-took-quiz-today'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('Response JSON: $data');
        if (data.containsKey('users')) {
          final List<dynamic>? apprenantsData = data['users'];
          if (apprenantsData != null) {
            final List<Apprenant> fetchedApprenants = apprenantsData.map((item) {
            final id = item['id'];
            return Apprenant(
              id: id is int ? id : int.tryParse(id) ?? 0,
              surname: item['Nom'] ?? '',
              name: item['Prenom'] ?? '',
              email: item['Email'] ?? '',
              dateNais: item['Date de Naissance'] ?? '',
              created_at: item['Date de création'] ?? '',
              filiere: item['Module'] ?? '',
              objectif: item['Objectif hebdomadaire'] ?? '',
              noteApp: item['Note de l\'app'],
            );
          }).toList();
          setState(() {
            apprenants.clear();
            apprenants.addAll(fetchedApprenants.reversed);
            filteredApprenants.clear();
            filteredApprenants.addAll(fetchedApprenants.reversed);
          });
        } else {
          print('No apprenants data found');
        }
        } else {
          throw Exception('Failed to load Apprenants');
        }
      } else {
        throw Exception('Failed to load Apprenants');
      }
    } catch (error) {
      print('Error fetching Apprenants: $error');
    }
     finally {
      setState(() {
        isLoading = false; // Définir l'état de chargement sur false à la fin de la requête
      });
    }
  }

  //fonction pour afficher les details de l'apprenant
 void showApprenantDetails(Apprenant apprenant) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(
          'Détails de l\'apprenant',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.blueGrey,
          ),
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildDetailRow('Prénom', apprenant.name),
                buildDetailRow('Email', apprenant.email),
                buildDetailRow('Date de Naissance', apprenant.dateNais),
                buildDetailRow('Date de création', apprenant.created_at),
                buildDetailRow('Module', apprenant.filiere),
                buildDetailRow('Objectif hebdomadaire', apprenant.objectif),
                buildDetailRow('Note de l\'app', apprenant.noteApp.toString()),
              ],
            ),
          ),
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
      );
    },
  );
}

  Widget buildDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120, // Ajustez la largeur en fonction de vos besoins
          child: Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Liste des apprenants',
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
            size: 30,
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdAccueilPage()),
            );
          },
        ),
        actions: [
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    getCurrentDate(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.blueGrey,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher un apprenant...',
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
                       filteredApprenants = apprenants
                      .where((apprenant) =>
                     apprenant.surname.toLowerCase().contains(query.toLowerCase()))
                      .toList();
                    });
                  },
                  style: const TextStyle(color: Colors.white), // Couleur du texte de saisie
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
              : apprenants.isEmpty
                  ? const Center(
                      child: Text(
                        'Aucun travail n\'a été effectué aujourd\'hui',
                        style: TextStyle(
                          fontSize: 18,
                          //fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : ListView.builder(
              itemCount: filteredApprenants.length,
              itemBuilder: (context, index) {
                final apprenant = filteredApprenants[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    title: Text(
                      apprenant.surname,
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
                            // Action lorsque l'icône "vue" est cliquée
                            showApprenantDetails(apprenant);
                          },
                        ),
                       IconButton(
  icon: const Icon(
    Icons.insert_chart,
    color: Colors.blue,
  ),
  onPressed: () async {
  // Appeler l'API pour récupérer les statistiques
  final response = await http.get(
    Uri.parse('$BASE_URL/api/last-activity-details/apprenants/${apprenant.id}'),
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $userToken',
    },
  );

  if (response.statusCode == 200 && response.body.isNotEmpty) {
    final Map<String, dynamic> data = json.decode(response.body);

    if (data.containsKey('last_activity')) {
      final lastActivity = data['last_activity'];
      final String niveau = lastActivity['niveau'];
      final String dernierScore = lastActivity['total_score'].toString();
      final String derniereMoyenne = lastActivity['moyenne_generale'].toString();
      final String tempsPasse = lastActivity['temps_passe'].toString();
      final String nombreQuestionsReussies = lastActivity['nombre_questions_reussies'].toString();
      final String nombreQuestionsEchouees = lastActivity['nombre_questions_echouees'].toString();

      // Afficher la boîte de dialogue avec les statistiques réelles
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Les statistiques',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CustomDialogBox.buildStatItem(
                      'Dernier Niveau fait',
                      niveau,
                    ),
                    CustomDialogBox.buildStatItem(
                      'Dernier score',
                      '$dernierScore /${(int.parse(nombreQuestionsReussies) + int.parse(nombreQuestionsEchouees)) * 4}',
                    ),
                    CustomDialogBox.buildStatItem(
                      'Dernière moyenne',
                      '$derniereMoyenne /20',
                    ),
                    //CustomDialogBox.buildStatItem(
                      //'Temps passé',
                      //'$tempsPasse min', 
                    //),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Fermer',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            backgroundColor: const Color(0xFFF2F2F2),
          );
        },
      );
    } else {
      // Gérer le cas où les statistiques ne sont pas disponibles
      print('No last activity data found');
    }
  } else {
    // Gérer le cas où la requête a échoué
    print('Failed to load last activity data');
  }
},

),
//analytics
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
class CustomDialogBox {
  static Widget buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              color: Colors.teal,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
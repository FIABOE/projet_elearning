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

class ListApp extends StatefulWidget {
  const ListApp({super.key});

  @override
  _ListAppState createState() => _ListAppState();
}

class _ListAppState extends State<ListApp> {
  List<Apprenant> apprenants = [];
  List<Apprenant> filteredApprenants = [];
  List<bool> isCheckedList = [];
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

  // Fonction pour afficher la liste des Apprenants
  Future<void> fetchApprenants() async {
    setState(() {
    isLoading = true; // Définir l'état de chargement sur true au début de la requête
  });
    try {
      final prefs = await SharedPreferences.getInstance();
      userToken = prefs.getString('userToken');
      final response = await http.get(
        Uri.parse('$BASE_URL/$APPRENANT_PATH'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );
      print(response.statusCode);
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        print(45);
        final Map<String, dynamic> data = json.decode(response.body);
        //print('Response JSON: $data');
      
        if (data.containsKey('success') && data['success'] == true) {
          final List<dynamic>? apprenantsData = data['apprenants'];
          
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
              //filteredApprenants = List.from(apprenants);
              filteredApprenants.addAll(fetchedApprenants.reversed);
              restoreCheckedStates();
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

  // Créez une fonction pour restaurer l'état des cases cochées depuis SharedPreferences
  Future<void> restoreCheckedStates() async {
    final prefs = await SharedPreferences.getInstance();
    // Initialise isCheckedList avec la longueur de apprenants
    isCheckedList = List<bool>.generate(apprenants.length, (index) {
      return prefs.getBool('isChecked_${apprenants[index].id}') ?? false;
    });
    // Si la longueur de isCheckedList est inférieure à la longueur de apprenants,
    // ajoutez des valeurs par défaut (false) pour les éléments manquants
    while (isCheckedList.length < apprenants.length) {
      isCheckedList.add(false);
    }
  }

  // Activation de l'apprenant
  Future<void> activateApprenant(int apprenantId) async {
    if (userToken == null) {
      //print('userToken est null. Impossible d\'activer le modérateur.');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      userToken = prefs.getString('userToken');

      final response = await http.put(
        Uri.parse('$BASE_URL/api/apprenants/{id}/activate'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );
      if (response.statusCode == 200) {
        //print('Apprenant activé avec succès');
        // Mise à jour de l'état dans SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isChecked_$apprenantId', false);

        // Mettez à jour l'état des cases cochées après activation
        await restoreCheckedStates();
      } else {
        //print('Erreur d\'activation de l\'apprenant: ${response.statusCode}');
      }
    } catch (e) {
      print('Une erreur s\'est produite lors de l\'activation de l\'apprenant: $e');
    }
     finally {
      setState(() {
        isLoading = false; // Définir l'état de chargement sur false à la fin de la requête
      });
    }
  }

  // Désactivation du modérateur
  Future<void> deactivateApprenant(int apprenantId) async {
    if (userToken == null) {
      //print('userToken est null. Impossible de désactiver le modérateur.');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      userToken = prefs.getString('userToken');

      final response = await http.put(
        Uri.parse('$BASE_URL/api/apprenants/{id}/deactivate'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );
      if (response.statusCode == 200) {
        //print('Apprenant désactivé avec succès');
        // Mise à jour de l'état dans SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isChecked_$apprenantId', true);

        // Mettez à jour l'état des cases cochées après désactivation
        await restoreCheckedStates();
      } else {
        //print('Erreur de désactivation de l\'apprenant: ${response.statusCode}');
      }
    } catch (e) {
      print('Une erreur s\'est produite lors de la désactivation de l\'apprenant: $e');
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
      ),
      body: Column(
        children: [
          Container(
            color: Colors.blueGrey,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher d\'un apprenant...',
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
                        //Icone DETAILS d'un moderateur
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
                        //LA CASE D'ACTIVATION
                        Checkbox(
                          value: isCheckedList.isNotEmpty && isCheckedList.length > index && isCheckedList[index],
                          onChanged: (newValue) {
                            if (newValue != null) {
                              if (newValue) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: const Text(
                                        'Voulez-vous vraiment désactiver cet apprenant ?',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.white, backgroundColor: Colors.red,
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            setState(() {
                                              isCheckedList[index] = false;
                                            });
                                          },
                                          child: const Text('Annuler'),
                                        ),
                                        TextButton(
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.white, backgroundColor: const Color(0xFF70A19F),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            setState(() {
                                              isCheckedList[index] = true;
                                            });
                                            deactivateApprenant(apprenant.id);
                                          },
                                          child: const Text('Oui'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else {
                                setState(() {
                                  isCheckedList[index] = newValue;
                                });
                                activateApprenant(apprenant.id);
                              }
                            }
                          },
                        ),
                        //icone pour afficher les sta d'un apprenants
                        IconButton(
                          icon: const Icon(
                            Icons.insert_chart,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'Choisir une option',
                                          style: TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 20.0),
                                        ElevatedButton(
                                          onPressed: () {
                                            //Navigator.of(context).pop(); 
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => ScoreApprenant(apprenantId: apprenant.id)),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange,
                                          ),
                                          child: const Text(
                                            'Voir les Scores',
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10.0),
                                        ElevatedButton(
                                          onPressed: () {
                                            //Navigator.of(context).pop(); // Fermer la boîte de dialogue
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => StaApprenant(apprenantId: apprenant.id)),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                          ),
                                          child: const Text(
                                            'Voir les Moyennes',
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10.0),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(); 
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => TempsApprenant(apprenantId: apprenant.id)),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.teal,
                                          ),
                                          child: const Text(
                                            'Voir le temps passé',
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20.0),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(); 
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red, 
                                          ),
                                          child: const Text(
                                            'Annuler',
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),//analytics
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

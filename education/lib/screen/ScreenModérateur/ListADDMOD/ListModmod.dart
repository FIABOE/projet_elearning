import 'package:flutter/material.dart';
import 'package:education/screenAdmin/adAccueil_page.dart';
import 'package:http/http.dart' as http;
import 'package:education/models/user.dart';
import 'package:education/models/moderateur.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:education/utils/constances.dart';
import 'package:intl/intl.dart';
import 'package:education/screenAdmin/adAccueil_page.dart';


class ListMod extends StatefulWidget {
  const ListMod({super.key});

  @override
  _ListModState createState() => _ListModState();
}

class _ListModState extends State<ListMod> {
  List<Moderateur> moderateurs = [];
  List<Moderateur> filteredModerateurs = [];
  List<bool> isCheckedList = [];
  String? userToken;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchModerateurs();
    _getUserToken();
  }

  // Récupération du token
  Future<void> _getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
  }

  // Fonction pour afficher la liste des modérateurs
  Future<void> fetchModerateurs() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');

    setState(() {
      isLoading = true; 
    });
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/$MODERATEUR_PATH'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('success') && data['success'] == true) {
          final List<dynamic> moderateursData = data['moderators'];
          final List<Moderateur> fetchedModerateurs = moderateursData.map((item) {
            final id = item['id'];
            final creationDate = item['Date de création'];

            //print('Received date: $creationDate'); // Add this line to check the received date
            if (id is int) {
              return Moderateur(
                id: id,
                surname: item['Nom'],
                name: item['Prenom'],
                created_at: creationDate != null ? parseDate(creationDate) : null,
                email: item['Email'].toString(),
              );
            } else if (id is String) {
              return Moderateur(
                id: int.tryParse(id) ?? 0,
                surname: item['Nom'],
                name: item['Prenom'],
                created_at: creationDate != null ? parseDate(creationDate) : null,
                email: item['Email'].toString(),
              );
            } else {
              return Moderateur(
                id: 0,
                surname: item['Nom'],
                name: item['Prenom'],
                created_at: creationDate != null ? parseDate(creationDate) : null,
                email: item['Email'].toString(),
              );
            }
          }).toList();

          setState(() {
            moderateurs.clear();
            moderateurs.addAll(fetchedModerateurs.reversed);
            filteredModerateurs = List.from(moderateurs);
            // Restaurer l'état des cases cochées depuis SharedPreferences
            restoreCheckedStates();
          });
        } else {
          throw Exception('Failed to load Mod');
        }
      } else {
        throw Exception('Failed to load fMod');
      }
    } catch (error) {
      print('Error fetching Mod: $error');
    }
    finally {
      setState(() {
        isLoading = false; // Définir l'état de chargement sur false à la fin de la requête
      });
    }
  }

  // Function to parse the date string into a DateTime object
  DateTime? parseDate(String dateString) {
    try {
      final List<String> parts = dateString.split('-');
      if (parts.length == 3) {
        final int day = int.parse(parts[0]);
        final int month = int.parse(parts[1]);
        final int year = int.parse(parts[2]);
        return DateTime(year, month, day);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

 // Function to format DateTime to String
  String formatDate(DateTime? date) {
    if (date != null) {
      return DateFormat('dd-MM-yyyy').format(date);
    } else {
      return 'N/A'; // Replace 'N/A' with your preferred placeholder for null dates
    }
  }

  //fonction pour afficher les details du modérateur
  void showModeratorDetails(Moderateur moderator) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Détails du modérateur',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.blueGrey, // Couleur blueGrey pour le titre
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Prénom: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    moderator.name,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10), 
              Row(
                children: [
                  const Text(
                    'Email: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    moderator.email,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10), 
              Row(
                children: [
                  const Text(
                    'Date de création: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                      formatDate(moderator.created_at),
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],                      
              ),
              const SizedBox(height: 10),
                Card(
                  child: ListTile(
                    title: const Text(
                      'Liste de module',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () async {
                      final moderatorId = moderator.id; 
                      //print('Moderator ID: $moderatorId');
                      try {
                        final response = await http.get(
                          Uri.parse('$BASE_URL/api/moderateurs/$moderatorId/filieres'),
                          headers: {
                            'Accept': 'application/json',
                            'Authorization': 'Bearer $userToken',
                          },
                        );
                        //print('Request URL: ${response.request?.url}');
                       //print('Request headers: ${response.request?.headers}');
                       if (response.statusCode == 200) {
                        final Map<String, dynamic> data = json.decode(response.body);
                        //print('Response body: ${response.body}');
                        if (data.containsKey('success') && data['success'] == true) {
                          final List<dynamic> filieresData = data['filieres'];
                          final List<String> filieres = filieresData.map((item) {
                            return item['libelle'].toString();
                          }).toList();
                          //print('Filières: $filieres');
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text(
                                  'Modules du modérateur',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                                content: SizedBox(
                                  width: 300,
                                  height: 300,
                                  child: ListView(
                                    children: filieres.map((filiere) {
                                      return Column(
                                        children: [
                                          ListTile(
                                            title: Text(
                                              filiere,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const Divider(
                                            color: Colors.grey,
                                            thickness: 1.0,
                                          ),
                                        ],
                                      );
                                    }).toList(),
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
                        } else {
                          //print('Failed to load filières');
                        }
                      } else {
                        //print('Request failed with status: ${response.statusCode}');
                      }
                    } catch (error) {
                      //print('Error fetching filières: $error');
                    }
                  },
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text(
                    'Liste d\'objectif',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () async {
                    final moderatorId = moderator.id; 
                    //print('Moderator ID: $moderatorId');
                    try {
                      final response = await http.get(
                        Uri.parse('$BASE_URL/api/moderateurs/$moderatorId/objectifs'),
                        headers: {
                          'Accept': 'application/json',
                          'Authorization': 'Bearer $userToken',
                        },
                      );
                      //print('Request URL: ${response.request?.url}');
                     //print('Request headers: ${response.request?.headers}');
                      if (response.statusCode == 200) {
                        final Map<String, dynamic> data = json.decode(response.body);
                        //print('Response body: ${response.body}');
                        if (data.containsKey('success') && data['success'] == true) {
                          final List<dynamic> objectifsData = data['objectifs'];
                          final List<String> objectifs = objectifsData.map((item) {
                            return item['libelle'].toString();
                          }).toList();
                          //print('Objectifs: $objectifs');
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text(
                                  'Objectifs du modérateur',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                                content: SizedBox(
                                  width: 300,
                                  height: 300,
                                  child: ListView(
                                    children: objectifs.map((objectif) {
                                      return Column(
                                        children: [
                                          ListTile(
                                            title: Text(
                                              objectif,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const Divider(
                                            color: Colors.grey,
                                            thickness: 1.0,
                                          ),
                                        ],
                                      );
                                    }).toList(),
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
                        } else {
                        //print('Failed to load objectifs');
                        }
                      } else {
                        //print('Request failed with status: ${response.statusCode}');
                      }
                    } catch (error) {
                      //print('Error fetching objectifs: $error');
                    }
                  },
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text(
                    'Liste des cours',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () async {
                    final moderatorId = moderator.id; 
                    //print('Moderator ID: $moderatorId');
                    try {
                      final response = await http.get(
                        Uri.parse('$BASE_URL/api/moderateurs/$moderatorId/cours'),
                        headers: {
                          'Accept': 'application/json',
                          'Authorization': 'Bearer $userToken',
                        },
                      );
                      //print('Request URL: ${response.request?.url}');
                      //print('Request headers: ${response.request?.headers}');
                      if (response.statusCode == 200) {
                        final Map<String, dynamic> data = json.decode(response.body);
                        //print('Response body: ${response.body}');
                        if (data.containsKey('success') && data['success'] == true) {
                          final List<dynamic> coursData = data['cours']; 
                          final List<String> cours = coursData.map((item) {
                            return item['pdf_file_name'].toString();
                          }).toList();
                          showDialog(
                            context: context,
                            builder: (context) {
                            return AlertDialog(
                              title: const Text(
                                'Les cours du modérateur',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              content: SizedBox(
                                width: 300,
                                height: 300,
                                child: ListView(
                                  children: cours.map((cour) {
                                    return Column(
                                    children: [
                                      ListTile(
                                        title: Text(
                                          cour,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const Divider(
                                        color: Colors.grey, 
                                        thickness: 1.0, 
                                      ),
                                    ],
                                  );
                                }).toList(),
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
                                        } else {
                      //print('Failed to load cours');
                    }
                  } else {
                    //print('Request failed with status: ${response.statusCode}');
                  }
                } catch (error) {
                   print('Error fetching cours: $error');
                }
              },
            ),
          ),
          Card(
            child: ListTile(
              title: const Text(
                'Liste des questions',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () async {
                final moderatorId = moderator.id; 
                //print('Moderator ID: $moderatorId');
                try {
                  final response = await http.get(
                    Uri.parse('$BASE_URL/api/moderateurs/$moderatorId/quizzes'),
                    headers: {
                      'Accept': 'application/json',
                      'Authorization': 'Bearer $userToken',
                    },
                  );
                  //print('Request URL: ${response.request?.url}');
                  //print('Request headers: ${response.request?.headers}');
                  if (response.statusCode == 200) {
                    final Map<String, dynamic> data = json.decode(response.body);
                    //print('Response body: ${response.body}');
                    if (data.containsKey('success') && data['success'] == true) {
                      final List<dynamic> quizsData = data['quizzes'];
                      final List<String> quizs = quizsData.map((item) {
                        return item['question'].toString();
                      }).toList();
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text(
                              'Les questions du quiz',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.blueGrey,
                              ),
                            ),
                            content: SizedBox(
                              width: 300,
                              height: 300,
                              child: ListView(
                                children: quizs.map((quiz) {
                                  return Column(
                                    children: [
                                      ListTile(
                                        title: Text(
                                          quiz,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const Divider( 
                                        color: Colors.grey, 
                                        thickness: 1.0,
                                      ),
                                    ],
                                  );
                                }).toList(),
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
                                        } else {
                      //print('Failed to load quizs');
                    }
                  } else {
                    //print('Request failed with status: ${response.statusCode}');
                  }
                } catch (error) {
                  print('Error fetching quizs: $error');
                }
              },
            ),
          ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Fermer',
              style: TextStyle(
                color: Colors.red, // Couleur rouge pour le bouton "Fermer"
                fontSize: 19,
              ),
            ),
          ),
        ],
      );
    },
  );
}

//fonction pour afficher la boite de modification du moderateurs
Future<void> _showEditDialog(Moderateur moderator) async {
  TextEditingController nameController = TextEditingController(text: moderator.name);
  TextEditingController surnameController = TextEditingController(text: moderator.surname);
  TextEditingController emailController = TextEditingController(text: moderator.email);

  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(
          'Modifier les informations',
           style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.blueGrey, 
            ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nom'),
            ),
            TextField(
              controller: surnameController,
              decoration: const InputDecoration(labelText: 'Prénom'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: <Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: Colors.red, 
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: const Color(0xFF70A19F), 
            ),
            onPressed: () {
              // Envoyez la mise à jour du modérateur
              updateModerateur(
                moderator.id,
                nameController.text,
                surnameController.text,
                emailController.text,
              );
              Navigator.of(context).pop();
            },
            child: const Text('Enregistrer'),
          ),
        ],
      );
    },
  );
}


  // fonction de modification du moderateurs appel de l'api
  Future<void> updateModerateur(int id, String newName, String newSurname, String newEmail) async {
  if (userToken == null) {
    return;
  }
  if (newName.isEmpty || newSurname.isEmpty || newEmail.isEmpty) {
    return;
  }
  try {
    final response = await http.put(
      Uri.parse('$BASE_URL/api/moderateurs/$id'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $userToken',
      },
      body: jsonEncode({
        'name': newName,
        'surname': newSurname,
        'email': newEmail,
      }),
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final updatedName = responseData['data']['Nom'];
      if (updatedName != null && updatedName is String) {
        // Récupérez la valeur de created_at de l'objet existant
        final existingModerateur = moderateurs.firstWhere((moderateur) => moderateur.id == id);
        final updatedModerateur = Moderateur(
          id: id,
          name: updatedName,
          surname: newSurname,
          email: newEmail,
          created_at: existingModerateur.created_at,
        );

        setState(() {
          final index = moderateurs.indexWhere((moderateur) => moderateur.id == id);
          if (index >= 0) {
            moderateurs[index] = updatedModerateur;
            filteredModerateurs = List.from(moderateurs);
          } else {
            //print('Modérateur avec l\'ID $id non trouvé dans la liste.');
          }
        });
      } else {
        //print('Le nom mis à jour est invalide.');
      }
    } else {
      //print('Erreur de mise à jour du modérateur: ${response.statusCode}');
    }
  } catch (e) {
    print('Une erreur s\'est produite lors de la mise à jour du modérateur: $e');
  }
  finally {
      setState(() {
        isLoading = false; // Définir l'état de chargement sur false à la fin de la requête
      });
    }
}


  // Activation du modérateur
  Future<void> activateModerateur(int moderatorId) async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
    if (userToken == null) {
      //print('userToken est null. Impossible d\'activer le modérateur.');
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('$BASE_URL/api/moderateurs/$moderatorId/activate'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );
      if (response.statusCode == 200) {
        //print('Modérateur activé avec succès');

        // Mise à jour de l'état dans SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isChecked_$moderatorId', false);

        // Mettez à jour l'état des cases cochées après activation
        restoreCheckedStates();
      } else {
        //print('Erreur d\'activation du modérateur: ${response.statusCode}');
      }
    } catch (e) {
      print('Une erreur s\'est produite lors de l\'activation du modérateur: $e');
    }
    finally {
      setState(() {
        isLoading = false; // Définir l'état de chargement sur false à la fin de la requête
      });
    }
  }

  // Désactivation du modérateur
  Future<void> deactivateModerateur(int moderatorId) async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
    if (userToken == null) {
      //print('userToken est null. Impossible de désactiver le modérateur.');
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('$BASE_URL/api/moderateurs/$moderatorId/deactivate'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );
      if (response.statusCode == 200) {
       // print('Modérateur désactivé avec succès');
        // Mise à jour de l'état dans SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isChecked_$moderatorId', true);
        
        // Mettez à jour l'état des cases cochées après désactivation
        restoreCheckedStates();
      } else {
        //print('Erreur de désactivation du modérateur: ${response.statusCode}');
      }
    } catch (e) {
      print('Une erreur s\'est produite lors de la désactivation du modérateur: $e');
    }
    finally {
      setState(() {
        isLoading = false; // Définir l'état de chargement sur false à la fin de la requête
      });
    }
  }

  // Créez une fonction pour restaurer l'état des cases cochées depuis SharedPreferences
  void restoreCheckedStates() async {
    final prefs = await SharedPreferences.getInstance();
    isCheckedList = List.generate(moderateurs.length, (index) => prefs.getBool('isChecked_${moderateurs[index].id}') ?? false);
  }

 //le body
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Liste des modérateurs',
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
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdAccueilPage(),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 30, // Ajustez la taille selon vos préférences
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
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher un modérateur...',
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
                       filteredModerateurs = moderateurs
                      .where((moderateur) =>
                     moderateur.surname.toLowerCase().contains(query.toLowerCase()))
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
                    child: CircularProgressIndicator(), // Afficher le CircularProgressIndicator lorsque isLoading est true
                  )
                : ListView.builder(
              itemCount: filteredModerateurs.length,
              itemBuilder: (context, index) {
                final moderateur = filteredModerateurs[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    title: Text(
                      moderateur.surname,
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
                            showModeratorDetails(moderateur);
                          },
                        ),
                        //Icone DE MODIFICATION
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.orange,
                          ),
                          onPressed: () {
                            _showEditDialog(moderateur);
                          },
                        ),
                        //LA CASE D'ACTIVATION
                        Checkbox(
                          value: isCheckedList.isNotEmpty && isCheckedList[index],
                          onChanged: (newValue) {
                            if (newValue != null) {
                              if (newValue) {
                                // Si la case est cochée, montrez une boîte de dialogue de confirmation
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: const Text(
                                        'Voulez-vous vraiment désactiver ce modérateur ?',
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
                                            // Ferme la boîte de dialogue
                                            Navigator.of(context).pop();
                                            // Rétablissez la case à cocher à sa valeur précédente
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
                                            // Désactive le modérateur
                                            Navigator.of(context).pop(); // Ferme la boîte de dialogue
                                            // Mettez à jour la désactivation du modérateur localement dans votre liste
                                            setState(() {
                                              isCheckedList[index] = true;
                                            });
                                            // Appelez votre API pour désactiver le modérateur en utilisant son ID
                                            deactivateModerateur(moderateur.id);
                                          },
                                          child: const Text('Oui'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else {
                                // Si la case est désactivée, la désactiver immédiatement localement
                                setState(() {
                                  isCheckedList[index] = newValue;
                                });
                                // Appelez votre API pour activer le modérateur en utilisant son ID
                                activateModerateur(moderateur.id);
                              }
                            }
                          },
                        )
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

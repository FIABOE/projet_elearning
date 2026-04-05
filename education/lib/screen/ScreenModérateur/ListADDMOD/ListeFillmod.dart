import 'package:flutter/material.dart';
import 'package:education/screenAdmin/Add_filiere.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:education/models/filiere.dart';
import 'package:education/models/moderateur.dart'; 
import 'package:education/utils/constances.dart';
import 'package:education/screenAdmin/adAccueil_page.dart';

class ListFill extends StatefulWidget {
  const ListFill({super.key});

  @override
  _ListFillState createState() => _ListFillState();
}

class _ListFillState extends State<ListFill> {
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
        Uri.parse('$BASE_URL/$FILIERE_PATH'),
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

  //Fonction qui affiche la bite de modification
  Future<void> _showEditDialog(int id, String libelle) async {
    TextEditingController textEditingController = TextEditingController(text: libelle);
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier le module'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textEditingController,
                //decoration: InputDecoration(labelText: 'Nouveau libellé'),
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.red, // Couleur du texte (blanc)
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
                // Envoyez la mise à jour de la filière
                updateFiliere(id, textEditingController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }
  
  //fonction pour la recuperation du token
  Future<void> _getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
    //print('Token d\'authentification récupéré depuis les préférences : $userToken');
  }
 
 //Fonction pour l'appel de l'api pour la mofification dans le BD
 Future<void> updateFiliere(int id, String newLibelle) async {
  final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
    //print('authentification: $userToken');
    
    if (userToken == null) {
     // print('userToken est null. Impossible de mettre à jour la filière.');
     return;
    }
    if (newLibelle.isEmpty) {
      //print('Le nouveau libellé est nul ou vide. Impossible de mettre à jour la filière.');
      return;
    }
    try {
      final response = await http.put(
        Uri.parse('$BASE_URL/api/filieres/$id'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: jsonEncode({'libelle': newLibelle}),
      );
      //print('Réponse du serveur: ${response.body}');
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final updatedLibelle = responseData['data']['libelle'];
        if (updatedLibelle != null && updatedLibelle is String) {
          setState(() {
            final updatedFiliere = Filiere(id: id, libelle: updatedLibelle);
            final index = filieres.indexWhere((filiere) => filiere.id == id);
            if (index >= 0) {
              filieres[index] = updatedFiliere;
              filteredFilieres = List.from(filieres); 
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Module mise à jour avec succès.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: Color(0xFF70A19F),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Module avec l\'ID $id non trouvée dans la liste.',
                 style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
      } else {
        //print('Le libellé mis à jour est invalide.');
      }
    } else {
      //print('Erreur de mise à jour de la filière: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Échec de la mise à jour du module.',
           style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    //print('Une erreur s\'est produite lors de la mise à jour de la filière: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Une erreur s\'est produite lors de la mise à jour du module.',
         style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
  finally {
    setState(() {
      isLoading = false; // Définir l'état de chargement sur false à la fin de la requête
    });
  }
}


Future<void> _showDeleteDialog(int id, String libelle) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Êtes-vous sûr de vouloir supprimer le module : $libelle ?',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
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
              // Supprimez la filière ici en utilisant la fonction deleteFiliere(id)
              deleteFiliere(id);
              Navigator.of(context).pop();
            },
            child: const Text('Supprimer'),
          ),
        ],
      );
    },
  );
}

////Suppression 
Future<void> deleteFiliere(int id) async {
  final prefs = await SharedPreferences.getInstance();
  userToken = prefs.getString('userToken');
  
  try {
    final response = await http.delete(
      Uri.parse('$BASE_URL/api/filieres/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $userToken',
      },
    );

    if (response.statusCode == 200) {
      // Suppression réussie, mettez à jour votre liste de filières
      setState(() {
        filieres.removeWhere((filiere) => filiere.id == id);
        filteredFilieres = List.from(filieres); // Mettre à jour filteredFilieres
      });
    } else {
      // Gestion des erreurs
      //print('Erreur de suppression de la filière: ${response.statusCode}');
    }
  } catch (e) {
    // Gestion des erreurs
    print('Une erreur s\'est produite lors de la suppression du module: $e');
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
            'Liste des Modules',
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
                        builder: (context) => const AddFiliere(),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 30, 
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
                    hintText: 'Rechercher un module...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.white, 
                    ),
                    hintStyle: const TextStyle(color: Colors.white), 
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white), 
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white), // Couleur de la bordure lorsque la barre de recherche est active
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (query) {
                    setState(() {
                      filteredFilieres = filieres
                      .where((filiere) =>
                      filiere.libelle.toLowerCase().contains(query.toLowerCase()))
                      .toList();
                    });
                  },
                  style: const TextStyle(color: Colors.white), 
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
             itemCount: filteredFilieres.length,
              itemBuilder: (context, index) {
                final filiere = filteredFilieres[index];
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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.orange,
                          ),
                          onPressed: () {
                            _showEditDialog(filiere.id, filiere.libelle);
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            _showDeleteDialog(filiere.id, filiere.libelle);
                          },
                        ),
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

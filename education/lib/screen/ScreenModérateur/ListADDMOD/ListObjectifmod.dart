import 'package:flutter/material.dart';
import 'package:education/screenAdmin/AddObjectif_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:education/models/filiere.dart';
import 'package:education/models/objectif.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:education/models/moderateur.dart';
import 'package:education/utils/constances.dart'; 
import 'package:education/screenAdmin/adAccueil_page.dart';

class ListObjectif extends StatefulWidget {
  const ListObjectif({super.key});

  @override
  _ListObjectifState createState() => _ListObjectifState();
}

class _ListObjectifState extends State<ListObjectif> {
  List<Objectif> objectifs = [];
  List<Objectif> filteredObjectifs = [];
  String? userToken;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchObjectifs();
     _getUserToken();
  }

  ///Liste des objectifs
  Future<void> fetchObjectifs() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');

    setState(() {
      isLoading = true; // Définir l'état de chargement sur true au début de la requête
    });

    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/$OBJECTIF_PATH'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey('data') && data['data'] is List<dynamic>) {
          final List<dynamic> objectifsData = data['data'];
          final List<Objectif> fetchedObjectifs = objectifsData
            .map((item) => Objectif(id: item['id'], libelle: item['libelle'].toString()))
            .toList();

          setState(() {
            objectifs.clear();
            objectifs.addAll(fetchedObjectifs.reversed); // Inverser l'ordre de la liste
            filteredObjectifs = List.from(objectifs); // Créer une copie pour la recherche
          });
        } else {
          throw Exception('Failed to load objectifs');
        }
      } else {
        throw Exception('Failed to load objectifs');
      }
    } catch (error) {
      print('Error fetching objectifs: $error');
    } finally {
      setState(() {
        isLoading = false; // Définir l'état de chargement sur false à la fin de la requête
      });
    }
  }

  Future<void> _getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
    //print('Token d\'authentification récupéré depuis les préférences : $userToken');
  }

  //Fonction qui affiche la bite de modification
  Future<void> _showEditDialog(int id, String libelle) async {
    TextEditingController textEditingController = TextEditingController(text: libelle);
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier l\'objectif'),
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
                foregroundColor: Colors.white, backgroundColor: const Color(0xFF70A19F), // Couleur du texte (blanc)
              ),
              onPressed: () {
                // Envoyez la mise à jour de l'objectif
                updateObjectif(id, textEditingController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  //Fonction pour l'appel de l'api pour la mofification dans le BD
  Future<void> updateObjectif(int id, String newLibelle) async {
    final prefs = await SharedPreferences.getInstance();
      userToken = prefs.getString('userToken');
    if (userToken == null) {
      //print('userToken est null. Impossible de mettre à jour l\'objectif.');
      return;
    }
    if (newLibelle.isEmpty) {
      //print('Le nouveau libellé est nul ou vide. Impossible de mettre à jour l\'objectif.');
      return;
    }
    try {
      final response = await http.put(
        Uri.parse('$BASE_URL/api/objectifs/$id'),
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
            final updatedObjectif = Objectif(id: id, libelle: updatedLibelle);
            final index = objectifs.indexWhere((objectif) => objectif.id == id);
            if (index >= 0) {
              objectifs[index] = updatedObjectif;
              filteredObjectifs = List.from(objectifs); 
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Objectif mis à jour avec succès.',
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
                content: Text('Objectif avec l\'ID $id non trouvé dans la liste.',
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
      //print('Erreur de mise à jour de l\'objectif: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Échec de la mise à jour de l\'objectif.',
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
    //print('Une erreur s\'est produite lors de la mise à jour de l\'objectif: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Une erreur s\'est produite lors de la mise à jour de l\'objectif.',
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
        isLoading = false; 
      });
    }
}

//////  Affichage du modal//////////////
Future<void> _showDeleteDialog(int id, String libelle) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Êtes-vous sûr de vouloir supprimer l\'objectif : $libelle ?',
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
              // Supprimez l'objectif ici en utilisant la fonction deleteObjectif(id)
              deleteObjectif(id);
              Navigator.of(context).pop();
            },
            child: const Text('Supprimer'),
          ),
        ],
      );
    },
  );
}

//...

  Future<void> deleteObjectif(int id) async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');

    // Effectuez une requête HTTP DELETE pour supprimer l'objectif'
    try {
      final response = await http.delete(
        Uri.parse('$BASE_URL/api/objectifs/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );
      if (response.statusCode == 200) {
        // Suppression réussie, vous pouvez mettre à jour votre liste de filières
        setState(() {
          objectifs.removeWhere((objectif) => objectif.id == id);
          filteredObjectifs.removeWhere((objectif) => objectif.id == id); // Mettez à jour la liste filtrée également
        });
      } else {
        //print('Erreur de suppression de l\'objectif: ${response.statusCode}');
      }
    } catch (e) {
      print('Une erreur s\'est produite lors de la suppression de l\'objectif: $e');
    } finally {
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
            'Liste des objectifs',
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
                        builder: (context) => const AddObjectif(),
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
                    hintText: 'Rechercher d\'une objectif hebdomadaire...',
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
                      filteredObjectifs = objectifs
                      .where((objectif) =>
                      objectif.libelle.toLowerCase().contains(query.toLowerCase()))
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
              itemCount: filteredObjectifs.length,
              itemBuilder: (context, index) {
                final objectif = filteredObjectifs[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    title: Text(
                      objectif.libelle,
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
                            color: Colors.orange, // Couleur de l'icône d'édition
                          ),
                          onPressed: () {
                            _showEditDialog(objectif.id, objectif.libelle);
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            _showDeleteDialog(objectif.id, objectif.libelle);
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

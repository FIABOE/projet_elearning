import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:education/models/filiere.dart';
import 'package:education/utils/constances.dart';

class ListFiliere extends StatefulWidget {
  final String? selectedFiliere;

  const ListFiliere({super.key, this.selectedFiliere});

  @override
  _ListFiliereState createState() => _ListFiliereState();
}

class _ListFiliereState extends State<ListFiliere> {
  List<String> filieres = [];
  List<String> filteredFilieres = [];
  TextEditingController searchController = TextEditingController();
  String? selectedFiliere;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedFiliere = widget.selectedFiliere;
    fetchFilieres("", []);
  }

  Future<void> fetchFilieres(String query, List<String> filteredList) async {
     setState(() {
    isLoading = true; // Définir l'état de chargement sur true au début de la requête
  });
  try {
    final response = await http.get(
      Uri.parse('$BASE_URL/$FILIERE_PATH'),
      headers: {
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data.containsKey('data') && data['data'] is List<dynamic>) {
        final List<dynamic> filieresData = data['data'];
        final List<String> fetchedFilieres = filieresData
            .map((item) => item['libelle'].toString())
            .toList();

        setState(() {
          filieres.clear();
          filieres.addAll(fetchedFilieres.reversed);
          // Assurez-vous de mettre à jour également filteredFilieres pour afficher toutes les filières
          filteredFilieres.clear();
          filteredFilieres.addAll(filieres);
        });
      } else {
        throw Exception('Failed to load Module');
      }
    } else {
      throw Exception('Failed to load Module');
    }
  } catch (e) {
    // Gérez les erreurs ici
    print('Une erreur s\'est produite lors du chargement des Modules: $e');
  }
  finally {
    setState(() {
      isLoading = false; // Définir l'état de chargement sur false à la fin de la requête
    });
  }
}

  // Modifier filterFilieres pour appeler fetchFilieres avec les paramètres
  void filterFilieres(String query) {
    // Assurez-vous de maintenir la liste complète des filières dans filteredFilieres au début.
    if (filteredFilieres.isEmpty) {
      setState(() {
        filteredFilieres.addAll(filieres);
      });
    }
    if (query.isEmpty) {
      setState(() {
        // Si la requête est vide, affichez à nouveau toutes les filières.
        filteredFilieres.clear();
        filteredFilieres.addAll(filieres);
      });
      } else {
        List<String> filteredList = filieres
        .where((filiere) =>
        filiere.toLowerCase().contains(query.toLowerCase()))
        .toList();
        setState(() {
          // Mettez à jour filteredFilieres avec les résultats de la recherche.
          filteredFilieres.clear();
          filteredFilieres.addAll(filteredList);
        });
      }
    }

    void selectFiliere(String filiere) {
      setState(() {
        selectedFiliere = filiere;
      });
    }
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Nos Module',
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
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    controller: searchController,
                    onChanged: (query) {
                      // Mise à jour du filtrage à chaque changement dans le texte.
                      filterFilieres(query);
                    },
                    style: const TextStyle(fontSize: 16),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Rechercher une module',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
             child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(), 
                  )
                :  ListView.builder(
                itemCount: filteredFilieres.length,
                itemExtent: 70, 
                itemBuilder: (context, index) {
                  final filiere = filteredFilieres[index];
                  final isSelected = filiere == selectedFiliere;
                  return GestureDetector(
                    onTap: () {
                      final libelleFiliere = filiere;
                      selectFiliere(libelleFiliere);
                      Navigator.pop(context, libelleFiliere);
                    },
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        tileColor: isSelected ? Colors.grey.shade200 : Colors.white,
                        title: Text(
                          filiere,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.blue : Colors.black,
                          ),
                        ),
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

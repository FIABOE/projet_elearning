import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:education/models/cours.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:education/utils/constances.dart';
import 'package:education/screen/Homepage/accueil_page.dart';
//import 'package:dart_pdf_reader/dart_pdf_reader.dart';
import 'package:advance_pdf_viewer_fork/advance_pdf_viewer_fork.dart';
import 'dart:io';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class SearchPage extends StatefulWidget {
  final double averageScore;

  const SearchPage({super.key, required this.averageScore});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Cours> cours = [];
  Map<String, dynamic> userData = {};
  List<Cours> coursList = [];
  List<Cours> filteredCoursList = [];
  String? userToken;
  String searchText = "";
  int? filiereId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserToken();
    if (filiereId != null) {
      fetchCoursList(filiereId!);
    }
    fetchUserData();
  }

  Future<void> _getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
  }

  Future<void> fetchUserData() async {
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

      if (user.containsKey('filiere_id')) {
        setState(() {
          userData['FiliereId'] = user['filiere_id'];
          filiereId = user['filiere_id'];
        });
        fetchCoursList(filiereId!);
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
  }

Future<void> fetchCoursList(int filiereId) async {

  final prefs = await SharedPreferences.getInstance();
  userToken = prefs.getString('userToken');
await EasyLoading.show(
    status: 'veuillez patientez...',
    maskType: EasyLoadingMaskType.black,
  );
  try {
    final apiUrl = Uri.parse('$BASE_URL/api/list_cours/$filiereId');
    final response = await http.get(
      apiUrl,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $userToken',
      },
    );

    if (!mounted) return;
      await Future.delayed(const Duration(seconds: 2));
      // Masquer l'indicateur de chargement
      EasyLoading.dismiss();
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data.containsKey('success') && data['success'] == true) {
        final List<dynamic> coursData = data['data'];

        // Créer une nouvelle liste
        final List<Cours> fetchedCours = coursData.map((item) {
          final id = item['id'];
          final filiereId = item['filiere_id'].toString();
          final pdfFile = item['pdf_file'];
          final pdfFileName = item['pdf_file_name'];
          final filiere = item['filiere'].toString();
          return Cours(
            id: id,
            pdf_file: pdfFile,
            pdf_file_name: pdfFileName,
            filiere_id: filiereId,
            filiere: filiere,
          );
        }).toList();

        if (!mounted) return;

        setState(() {
          coursList = fetchedCours; // Utilisez fetchedCours au lieu de cours
          filteredCoursList = coursList;
          isLoading = false;
        });
      } else {
        throw Exception('La requête a échoué avec le message : ${data['message']}');
      }
    } else {
      throw Exception('Impossible de récupérer la liste des cours depuis l\'API. Code de statut : ${response.statusCode}');
    }
  } catch (error) {
    if (!mounted) return;
    print('Une erreur s\'est produite lors de la récupération des cours : $error');
     EasyLoading.dismiss();
  }
}

_openPDF(String pdfFile) async {
  try {
    final pdfUrl = '$BASE_URL/storage/$pdfFile';
    final pdfViewer = await PDFDocument.fromURL(pdfUrl);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewer(document: pdfViewer),
      ),
    );
  } catch (error) {
    _showErrorDialog('Impossible de lire le fichier PDF.');
  }
}

void _showErrorDialog(String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'Erreur',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 18),
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


@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'Mes cours',
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AccueilPage(averageScore: widget.averageScore),
            ),
          );
        },
      ),
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Rechercher un cours',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                    filteredCoursList = coursList
                        .where((cours) =>
                            cours.pdf_file_name
                                .toLowerCase()
                                .contains(searchText.toLowerCase()))
                        .toList();
                  });
                },
              ),
            ),
          ),
        ),
        Expanded(
  child: ListView.builder(
    itemCount: filteredCoursList.length,
    itemBuilder: (context, index) {
      final coursItem = filteredCoursList[index];
      return Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          title: Text(
            coursItem.pdf_file_name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          leading: const Icon(
            Icons.description,
            color: Color(0xFFF5804E),
          ),
          onTap: () {
            _openPDF(coursItem.pdf_file);
          },
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
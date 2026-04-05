import 'package:flutter/material.dart';
import 'package:education/models/cours.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:education/screen/Info/list_filière.dart';
import 'package:education/screenAdmin/listeADD/ListCours.dart';

class EditCours extends StatefulWidget {
  final Cours cour;

  const EditCours({super.key, required this.cour});

  @override
  _EditCoursState createState() => _EditCoursState();
}

class _EditCoursState extends State<EditCours> {
  TextEditingController courNameController = TextEditingController();
  File? selectedFile;
  String? selectedFiliere;
  bool isValiderButtonEnabled = false;
  String? userToken;

  // Pour naviguer vers la liste
  Future<void> navigateToFiliereSelection() async {
    final selectedFiliere = await Navigator.push<String?>(
      context,
      MaterialPageRoute(
        builder: (context) => ListFiliere(selectedFiliere: this.selectedFiliere),
      ),
    );
    if (selectedFiliere != null) {
      setState(() {
        this.selectedFiliere = selectedFiliere;
        isValiderButtonEnabled = true;
      });
    }
  }

  // Récupération du token
  Future<void> _getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
  }

  Future<void> selectPDFFile() async {
  final result = await FilePicker.platform.pickFiles(
    withData: true,
    type: FileType.custom,
    allowedExtensions: ['pdf'],
  );
  if (result != null && result.files.isNotEmpty) {
    setState(() {
      selectedFile = File(result.files.single.path!);
      // Initialiser courNameController.text avec le nom du fichier par défaut
      courNameController.text = selectedFile!.path.split('/').last;
      print('Chemin du fichier sélectionné : ${selectedFile!.path}');
    });
  }
}



 Future<void> submitForm() async {
  try {
    if (selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un fichier PDF.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('http://192.168.1.65:8000/api/cours'),
    );

    request.headers['Authorization'] = 'Bearer $userToken';
    request.headers['Accept'] = 'application/json';

    request.fields['courName'] = courNameController.text;

    if (selectedFiliere == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une filière.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    request.fields['filiere_libelle'] = selectedFiliere!;

    final pdfFile = http.MultipartFile(
      'pdf_file',
      selectedFile!.readAsBytes().asStream(),
      selectedFile!.lengthSync(),
      filename: selectedFile!.path.split('/').last,
    );

    request.files.add(pdfFile);
     print('Request fields: ${request.fields}');
    print('PDF file name: ${selectedFile!.path}');
    print('Request URL: ${request.url}');


    final response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cours mis à jour avec succès.'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        selectedFile = null;
        selectedFiliere = null;
        isValiderButtonEnabled = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Échec de la mise à jour du cours.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    print('Erreur lors de l\'exécution de la fonction submitForm : $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Une erreur s\'est produite. Veuillez réessayer plus tard.'),
        backgroundColor: Colors.red,
      ),
    );
  }
}


  @override
  void initState() {
    super.initState();
    _getUserToken();

    // Préremplir les champs avec les anciennes valeurs
  setState(() {
    selectedFile = File(widget.cour.pdf_file);
  });
    selectedFiliere = widget.cour.filiere;
  }

  @override
  void dispose() {
    courNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mettre à jour un cours',
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
                  builder: (context) => const ListCours(),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: selectPDFFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF70A19F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Icon(
                      Icons.file_upload,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 14),
                    Text(
                      selectedFile != null
                          ? selectedFile!.path.split('/').last
                          : 'Sélectionnez votre fichier',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 22),
                    Visibility(
                      visible: selectedFile != null,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedFile = null;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: navigateToFiliereSelection,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color.fromARGB(255, 204, 203, 203),
                    width: 2.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filière',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(255, 17, 15, 15),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          selectedFiliere ?? 'Sélection',
                          style: TextStyle(
                            fontSize: 16,
                            color: selectedFiliere != null
                                ? const Color(0xFF087B95)
                                : Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80),
            ElevatedButton(
              onPressed: isValiderButtonEnabled ? submitForm : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF70A19F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Mettre à jour',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF0F0F0),
    );
  }
}

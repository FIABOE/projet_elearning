import 'package:education/screen/Info/list_filière.dart';
import 'package:education/screenAdmin/listeADD/ListCours.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:education/utils/constances.dart';

class AddCours extends StatefulWidget {
  const AddCours({super.key});

  @override
  _AddCoursState createState() => _AddCoursState();
}

class _AddCoursState extends State<AddCours> {
  TextEditingController filiereController = TextEditingController();
  File? selectedFile;
  String? selectedFiliere;
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
  }

  @override
  void dispose() {
    filiereController.dispose();
    super.dispose();
  }

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
    //print('Token d\'authentification récupéré depuis les préférences : $userToken');
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
      });
    }
  }
 
 //soumettre un cours de format pdf
  Future<void> submitForm() async {
    try {
      setState(() {
        isSubmitting = true; // Activer le flag de soumission
      });
      if (selectedFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner un fichier PDF.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      // Afficher les valeurs de selectedFiliere et selectedFile
      //print('selectedFiliere: $selectedFiliere');
      //print('selectedFile: $selectedFile');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$BASE_URL/$Cours_PATH'),
      );
      // Ajouter l'en-tête Authorization avec le token de l'utilisateur
      request.headers['Authorization'] = 'Bearer $userToken';
      request.headers['Accept'] = 'application/json';

      request.fields['filiere_libelle'] = selectedFiliere!;

      final pdfFile = http.MultipartFile(
        'pdf_file',
        selectedFile!.readAsBytes().asStream(),
        selectedFile!.lengthSync(),
        filename: selectedFile!.path.split('/').last, // Obtenez le nom du fichier à partir du chemin
      );

      request.files.add(pdfFile);

      final response = await request.send();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Cours ajouté avec succès.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: Color(0xFF70A19F),
          ),
        );
        setState(() {
          selectedFile = null;
          selectedFiliere = null;
          isValiderButtonEnabled = false;
          isFormSubmitted = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Le cours existe déjà.',
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
    } catch (e) {
      print('Erreur lors de l\'exécution de la fonction submitForm : $e');
    }
    finally {
      setState(() {
        isSubmitting = false; // Désactiver le flag de soumission
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ajouter un cours',
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
                    // Condition pour afficher le bouton seulement si un fichier est sélectionné
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
                      'Module',
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
              onPressed: isValiderButtonEnabled && !isSubmitting
              ? submitForm
              : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF70A19F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Text(
                      'Soumettre',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
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
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF0F0F0),
    );
  }
}

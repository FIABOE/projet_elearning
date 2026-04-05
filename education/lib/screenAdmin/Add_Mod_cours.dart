import 'package:education/screen/Info/list_filière.dart';
import 'package:education/screenAdmin/ListCour.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:education/utils/constances.dart';

class Add_ModCours extends StatefulWidget {
  const Add_ModCours({super.key});

  @override
  _Add_ModCoursState createState() => _Add_ModCoursState();
}

class _Add_ModCoursState extends State<Add_ModCours> {
  TextEditingController filiereController = TextEditingController();
  File? selectedFile;
  String? selectedFiliere;
  bool isValiderButtonEnabled = false;
  bool isFormSubmitted = false;
  String? userToken;
  int totalFilieres = 0;
  int totalObjectifs = 0;
  int totalCours = 0;
  int totalQuiz = 0;
  int totalExercices = 0;
  int totalApprenants = 0;
  int totalModerateurs = 0;
  bool isSubmitting = false;

  
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
    if (selectedFiliere != null && mounted) {
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
    print('✅ Token récupéré: ${userToken != null ? "OUI" : "NON"}');
  }

  Future<void> selectPDFFile() async {
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.isNotEmpty && mounted) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
      print('✅ Fichier sélectionné: ${selectedFile!.path}');
    }
  }
 
  //soumettre un cours de format pdf
  Future<void> submitForm() async {
    try {
      if (mounted) {
        setState(() {
          isSubmitting = true;
        });
      }
      
      if (selectedFile == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veuillez sélectionner un fichier PDF.'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            isSubmitting = false;
          });
        }
        return;
      }
      
      print(' Préparation de la requête...');
      print(' URL: $BASE_URL/$Cours_PATH');
      print(' Filière: $selectedFiliere');
      print(' Fichier: ${selectedFile!.path}');
      
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
        filename: selectedFile!.path.split('/').last,
      );

      request.files.add(pdfFile);
      
      print('Envoi de la requête...');
      final response = await request.send();
      
      // LECTURE DE LA RÉPONSE COMPLÈTE
      final responseBody = await response.stream.bytesToString();
      print('Status Code: ${response.statusCode}');
      print('Response Body: $responseBody');
      print('Headers: ${response.headers}');

      if (!mounted) return; // Vérifier avant toute interaction UI

      if (response.statusCode == 201) {
  // Fermer tous les SnackBar précédents
  ScaffoldMessenger.of(context).clearSnackBars();
  
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
      duration: Duration(seconds: 2), // ← Ajoute une durée
    ),
  );
  setState(() {
    selectedFile = null;
    selectedFiliere = null;
    isValiderButtonEnabled = false;
    isFormSubmitted = true;
  });
} else {
  // Fermer tous les SnackBar précédents aussi
  ScaffoldMessenger.of(context).clearSnackBars();
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Erreur ${response.statusCode}: $responseBody',
        style: const TextStyle(
          fontSize: 14,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 5),
    ),
  );
}
    } catch (e) {
      print(' ERREUR EXCEPTION: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
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
                  builder: (context) => const ListeCours(),
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
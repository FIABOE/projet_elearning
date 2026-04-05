import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:education/screen/Profil/avatar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:education/utils/constances.dart';
import 'package:education/screen/Compte/compte_page.dart';
import 'package:intl/intl.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class UpdateComptePage extends StatefulWidget {
  final double averageScore;
  const UpdateComptePage({super.key, required this.averageScore,});

  @override
  _UpdateComptePageState createState() => _UpdateComptePageState();
}

class _UpdateComptePageState extends State<UpdateComptePage> {
  TextEditingController pseudoController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController dateNaissanceController = TextEditingController();
  TextEditingController prenomController = TextEditingController();
  TextEditingController nomController = TextEditingController();

  String dateNaissance = '';
  String prenom = '';
  String nom = '';
  String email = '';
  String pseudo = '';
  String? userToken;
  Map<String, dynamic> userData = {};
  String avatarUrl = '';
  String avatarPath = '';
  bool avatarSelected = false;
  bool isAvatarSelected = false;
  bool isLoading = false;
  double averageScore = 0.0;
  bool _avatarUpdated = false;
  

  // fonction qui traite le profil du user
  Future<void> fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
    //print('authentification: $userToken');
    /*await EasyLoading.show(
      status: 'En cours...',
      maskType: EasyLoadingMaskType.black,
    );*/
    try {
      //print('Début de la requête HTTP');
      final response = await http.get(
        Uri.parse('$BASE_URL/$USERPROFILE_PATH'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );
      //print('Réponse HTTP reçue');
       // Exemple de délai simulé pour lN es besoins de démonstration
      /*await Future.delayed(Duration(seconds: 2));
      // Masquer l'indicateur de chargement
      EasyLoading.dismiss();*/
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('success') && data['success'] == true) {
          // Récupérez le pseudo et l'URL de l'avatar depuis les données du profil
          final String userPseudo = data['pseudo'];
          final String userAvatarRelativeUrl = data['avatar'];
          // Remplacez ceci par l'URL de base de votre serveur
          const baseUrl = '$BASE_URL:8000/storage';
          // Construisez l'URL absolue en combinant la base de l'URL et l'URL relative de l'avatar
          final userAvatarUrl = '$baseUrl/$userAvatarRelativeUrl';

          print('Pseudo récupéré : $userPseudo');
          print('URL de l\'avatar récupéré : $userAvatarUrl');

          setState(() {
            pseudo = userPseudo; // Mettez à jour le pseudo dans l'état local
            avatarUrl = userAvatarUrl; // Mettez à jour l'URL de l'avatar dans l'état local
          });
          // Mettez à jour le texte du contrôleur pseudoController
          pseudoController.text = pseudo; // Utilisez la valeur de pseudo
          //print('Mise à jour de l\'état local effectuée');
        }
      }
    } catch (error) {
      print('Erreur lors de la récupération du profil utilisateur : $error');
      //EasyLoading.dismiss();
    }
  }

  // conversion de l'image
  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load(path);
    String pt = path.split('/')[2];
    final buffer = byteData.buffer;
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    var filePath = '$tempPath/$pt';
    return File(filePath)
        .writeAsBytes(buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  }

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
    fetchUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      avatarPath = prefs.getString('avatarPath') ?? '';
      setState(() {});
    });
  }

  // Récupération du user
  Future<void> fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
                    await EasyLoading.show(
      status: 'veuillez patientez...',
      maskType: EasyLoadingMaskType.black,
    );
    try {
    //print('Début de la requête HTTP pour récupérer les données de l\'utilisateur');
    final response = await http.get(
      Uri.parse('$BASE_URL/$USER_PATH'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $userToken',
      },
    );
    //print('Code de réponse HTTP : ${response.statusCode}');
    //print('Corps de la réponse HTTP : ${response.body}');
     // Exemple de délai simulé pour les besoins de démonstration
      await Future.delayed(const Duration(seconds: 2));
      // Masquer l'indicateur de chargement
      EasyLoading.dismiss();
    if (response.statusCode == 200) {
      //print('Réponse HTTP 200 OK, traitement des données...');
      final Map<String, dynamic> data = json.decode(response.body);
      final user = data['user'];

      //print('Données brutes de l\'utilisateur : $user');
      if (user.containsKey('Email')) {
        setState(() {
          userData = {
            'Email': user['Email'],
            'Date de Naissance': user['Date de Naissance'],
            'Prenom': user['Prenom'],
            'Nom': user['Nom'],
          };
          emailController.text = userData['Email'] ?? '';
          dateNaissanceController.text = userData['Date de Naissance'] ?? '';
          prenomController.text = userData['Prenom'] ?? '';
          nomController.text = userData['Nom'] ?? '';
        });

        //print('Données utilisateur mises à jour dans l\'état local');
        //print('UserData après la mise à jour : $userData');
      }
    } else {
      //print('Erreur HTTP ${response.statusCode} lors de la récupération des données');
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
  } catch (error) {
    print('Erreur lors de la requête HTTP : $error');
    EasyLoading.dismiss();
  }
}

  // Fonction de validation pour le nom
  String? validateSurName(String value) {
    if (value.isEmpty) {
      return 'Le champ nom est requis';
    }
    if (value.length < 2) {
      return 'Le nom doit avoir au moins 2 caractères';
    }
    if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value)) {
      return 'Le nom ne doit contenir que des lettres et des espaces';
    }
    return null; // La validation a réussi
  }

  // Fonction de validation pour le prenom
  String? validateName(String value) {
    if (value.isEmpty) {
      return 'Le champ Prenom est requis';
    }
    if (value.length < 2) {
      return 'Le prenom doit avoir au moins 2 caractères';
    }
    if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value)) {
      return 'Le prenom ne doit contenir que des lettres et des espaces';
    }
    return null; // La validation a réussi
  }

  // Fonction de validation pour la date de naissance
  String? validateDateNaissance(String value) {
    try {
      DateTime date = DateTime.parse(value); // Vérifier si la date est au format valide
    
      // Valider le format Y-m-d
      if (value.length != 10 || value[4] != '-' || value[7] != '-') {
        return 'Le format de date doit être Y-m-d';
      }
      // Valider l'âge minimum
      DateTime now = DateTime.now();
      DateTime minimumDate = DateTime(now.year - 15, now.month, now.day);
    
      if (date.isAfter(minimumDate)) {
        return 'Vous devez avoir au moins 15 ans';
      }

    } catch (e) {
      return 'Format de date invalide';
    }

    return null; 
  }

  // Fonction de validation pour l'email
  String? validateEmail(String value) {
    if (value.isEmpty) {
      return 'Le champ email est requis';
    }
    if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(value)) {
      return 'Veuillez entrer une adresse e-mail valide';
    }
    return null; 
  }

  // Fonction de validation pour le pseudo
  String? validatePseudo(String value) {
    if (value.isEmpty) {
      return 'Le champ pseudo est requis';
    }
    return null; 
  }

  Future<void> updateUserAndProfile() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
    final apiUrl = Uri.parse('$BASE_URL/$UPDATE_USER_PROFILE_PATH');

    setState(() {
      pseudo = pseudoController.text;
      email = emailController.text;
      dateNaissance = dateNaissanceController.text;

      setState(() {
      isLoading = true; // Définir l'état de chargement sur true au début de la requête
    });
        try {
          dateNaissance = DateFormat('y-M-d').format(DateFormat('dd-MM-yyyy').parse(dateNaissance));
        } catch (e) {
          //print('Erreur de format de date : $e');
          return; // Arrêtez la fonction si la date n'est pas au bon format
        }
      prenom = prenomController.text;
      nom = nomController.text;
    });

    // Valider le nom
    final nameError = validateSurName(nom);
    if (nameError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(nameError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    // Valider le prenom
    final surnameError = validateName(prenom);
    if (surnameError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(surnameError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    // Valider la date de naissance
    final dateNaissanceError = validateDateNaissance(dateNaissance);
    if (dateNaissanceError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(dateNaissanceError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    // Valider l'email
    final emailError = validateEmail(email);
    if (emailError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(emailError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
      // Valider le pseudo
      final pseudoError = validatePseudo(pseudo);
      if (pseudoError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(pseudoError),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      final data = {
        'name': nom,
        'surname': prenom,
        'dateNais': dateNaissance,
        'email': email,
        'pseudo': pseudo,
      };
      final jsonData = jsonEncode(data);
      try {
        final request = http.MultipartRequest('POST', apiUrl);
        request.headers['Authorization'] = 'Bearer $userToken';
        
        // Ajouter les champs de données à la demande
        request.fields['name'] = nom;
        request.fields['surname'] = prenom;
        request.fields['dateNais'] = dateNaissance;
        request.fields['email'] = email;
        request.fields['pseudo'] = pseudo;

        // Gérer le téléchargement de l'avatar s'il existe
        if (avatarPath.isNotEmpty) {
          var file = await getImageFileFromAssets(avatarPath);
          var avatar = await http.MultipartFile.fromPath('avatar', (file).path);
          request.files.add(avatar);

          // Mettre à jour avatarPath avec le nouveau chemin de l'avatar
          avatarPath = (file).path;
        }
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        //print('Response status: ${response.statusCode}');
        //print('Response body: $responseBody');

        if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseBody);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Profil mis à jour avec succès.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.teal,
          ),
        );
        setState(() {
          _avatarUpdated = true;
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UpdateComptePage(averageScore: widget.averageScore)),
        );  
      } else {
        final jsonResponse = json.decode(responseBody);
        final errorMessage = jsonResponse['errors'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour du profil: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      print('Erreur lors de la requête HTTP : $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour du profil: $error'),
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            'Modifier mes informations',
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
          ),
          onPressed: () {
            Navigator.push(context, 
            MaterialPageRoute(builder: (context) => ComptePage(averageScore: widget.averageScore)));
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5.0,
                      spreadRadius: 2.0,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Row(
  children: [
    FutureBuilder<String>(
      future: Future<String>.value(avatarPath.isNotEmpty ? avatarPath : avatarUrl),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return CircleAvatar(
            backgroundImage: AssetImage(snapshot.data ?? 'b.png'),
          );
        } else {
          // Retirez le widget CircularProgressIndicator
          return const SizedBox(); // Ou un autre widget vide si nécessaire
        }
      },
    ),
    const SizedBox(width: 16),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            userData['Email'] ?? '',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    ),
  ],
),

                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(255, 238, 145, 69),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          final selectedAvatar = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AvatarPage(),
                            ),
                          ) as String?;
                          if (selectedAvatar != null) {
                            setState(() {
                              avatarPath = selectedAvatar; // Mettez à jour avatarPath avec le nouveau chemin local
                              avatarUrl = selectedAvatar; // Mettez à jour avatarUrl avec le nouveau chemin local
                            });
                            pseudoController.text = pseudo;
                            // Enregistrez la nouvelle valeur de `avatarPath` dans les préférences (si nécessaire)
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            prefs.setString('avatarPath', selectedAvatar);
                            prefs.setString('avatarUrl', selectedAvatar); // Mettez à jour le lien de l'avatar distant
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              buildInfoField('Pseudo', pseudoController, (value) {}),
              buildInfoField('Date de naissance', dateNaissanceController, (value) {}),
              buildInfoField('Prénom', prenomController, (value) {}),
              buildInfoField('Nom', nomController, (value) {}),
              buildInfoField('Email', emailController, (value) {}),
              const SizedBox(height: 150),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
  padding: const EdgeInsets.only(bottom: 100.0),
  child: SizedBox(
    width: 150,
    height: 40,  // Ajustez la hauteur du bouton selon vos besoins
    child: ElevatedButton(
      onPressed: isLoading
          ? null
          : () {
              updateUserAndProfile();
            },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 24.0,
        ),
        backgroundColor: isLoading
            ? Colors.grey // Couleur lorsque le bouton est désactivé
            : const Color(0xFF70A19F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text(
            'Valider',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isLoading)
            const Positioned(
              right: 8.0,
              child: SizedBox(
                height: 24.0,
                width: 24.0,
                child: CircularProgressIndicator(
                  strokeWidth: 3.0,  // Ajustez la largeur du cercle selon vos besoins
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    ),
  ),
),

              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInfoField(
    String label,
    TextEditingController controller,
    ValueChanged<String> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: controller,
              onChanged: onChanged,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 235, 83, 23),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

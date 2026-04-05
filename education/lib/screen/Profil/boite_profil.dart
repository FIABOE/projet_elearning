import 'package:flutter/material.dart';
import 'package:education/screen/Profil/avatar.dart';
import '../Homepage/accueil_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:education/utils/constances.dart';
import 'package:education/screen/Info/mes_info.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class BoitePage extends StatefulWidget {
  const BoitePage({super.key});

  @override
  _BoitePageState createState() => _BoitePageState();
}

class _BoitePageState extends State<BoitePage> {
  final int _selectedIndex = 0;
  String avatarPath = '';
  String pseudo = '';
  bool avatarSelected = false;
  bool isAvatarSelected = false;
  String? userToken;
  final double averageScore = 0.0;
  bool _isDialogButtonDisabled = true; 
  final TextEditingController _pseudoController = TextEditingController();
  bool _isPseudoEntered = false;

  

  Future<void> _getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
    //print('Token d\'authentification récupéré depuis les préférences : $userToken');
  }

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

  //fonction pour gestion de profil
  Future<void> userProfile(String pseudo, String avatarPath) async {
    await EasyLoading.show(
    status: 'veuillez patientez...',
    maskType: EasyLoadingMaskType.black,
  );
    try {
      var request = http.MultipartRequest(
        'POST', 
        Uri.parse('$BASE_URL/$PROFIL_PATH'),
      );
      // Ajouter l'en-tête Authorization avec le token de l'utilisateur
        request.headers['Authorization'] = 'Bearer $userToken'; // Remplacez $userToken par le vrai token de l'utilisateur
        request.headers['Accept'] = 'application/json';

        request.fields['pseudo'] = pseudo;
      
        if (avatarPath.isNotEmpty) {
          var file = await getImageFileFromAssets(avatarPath);
          var avatar = await http.MultipartFile.fromPath('avatar', (file).path); // Attendre la résolution de la future
          request.files.add(avatar);
        }
        print('Demande envoyée : ${request.fields}');
        var response = await request.send();
        var responseStream = await response.stream.transform(utf8.decoder).toList();
        var responseBody = responseStream.join();
        print('Réponse brute du serveur : $responseBody'); 

        var jsonResponse = jsonDecode(responseBody) as Map<String, dynamic>;

         await Future.delayed(const Duration(seconds: 2));
      // Masquer l'indicateur de chargement
      EasyLoading.dismiss();
      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AccueilPage(averageScore: averageScore),
          ),
        );
      } else {
        print('Échec de la mise à jour du profil.');
        print('Réponse du serveur : $jsonResponse');
      }
    } catch (e) {
      print('Une erreur est survenue lors de la mise à jour du profil : $e');
      EasyLoading.dismiss();
    }
  }
  void _updateDialogButtonState() {
    // Mettez à jour l'état du bouton en fonction de la disponibilité des données nécessaires
    setState(() {
      _isDialogButtonDisabled = avatarPath.isEmpty;
    });
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      avatarPath = prefs.getString('avatarPath') ?? '';
      setState(() {});
      _showDialog(context);
    });
    _getUserToken();
    _pseudoController.addListener(() {
      // Mettez à jour l'état du bouton dans la boîte de dialogue
      setState(() {
        _isPseudoEntered = _pseudoController.text.isNotEmpty;
        _updateDialogButtonState();
      });
    });
  }

  ///Affichage du modal du profil
  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(
            child: Text(
              'Veuillez choisir votre pseudo et votre avatar',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color.fromARGB(255, 252, 252, 252),
                          child: avatarPath.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  size: 24,
                                  color: Color.fromARGB(255, 248, 91, 91),
                                )
                              : ClipOval(
                                  child: Image.asset(
                                    avatarPath,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          size: 24,
                          color: Colors.orange,
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
                              avatarPath = selectedAvatar;
                            });
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            prefs.setString('avatarPath', selectedAvatar);
                          }
                          // Mettez à jour l'état du bouton dans la boîte de dialogue
                          _updateDialogButtonState();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pseudo: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _pseudoController,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 143, 69, 9),
                              fontSize: 18,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              hintText: 'Mettez votre prenom ou un surnom',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            onChanged: (value) {
                              // Mettez à jour l'état du bouton dans la boîte de dialogue
                              _updateDialogButtonState();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isDialogButtonDisabled ? Colors.grey : const Color(0xFF70A19F),
                    ),
                    onPressed: _isDialogButtonDisabled
                    ? null
                    : () async {
                    if (_pseudoController.text.isNotEmpty) {
                      _isPseudoEntered = true;
                      final pseudo = _pseudoController.text;
                      await userProfile(pseudo, avatarPath);
                      } else {
                        // Affichez un message indiquant que le champ du pseudo doit être renseigné
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Veuillez entrer votre pseudo.',
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
                    },
                    child: const Text(
                      'Valider',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF70A19F),
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
            'Tolearnio',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 30, 
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MesinfoPage()),
            );
          },
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  _showDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: const Color(0xFF70A19F), 
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  'Afficher la boîte de profil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
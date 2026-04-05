import 'package:flutter/material.dart';
import '../Compte/compte_page.dart';
import 'package:education/screen/Quiz/revision_page.dart';
import 'package:education/screen/Quiz/cours_page.dart';
import 'package:education/screen/Quiz/Contenu/architecture.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:marquee/marquee.dart';
import 'package:path_provider/path_provider.dart';
import 'package:time_range_picker/time_range_picker.dart';
import 'package:education/utils/constances.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class AccueilPage extends StatefulWidget {  
  final double averageScore;
  const AccueilPage({super.key, required this.averageScore});

  @override
  _AccueilPageState createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  double averageScore = 0.0;
  double quota = 0;
  double progression = 0.0;
  double quotaWidthFactor = 0.0;
  int duree = 0;
  int _selectedIndex = 0;
  
  List<IconData> badgeIcons = [
    Icons.bookmark,
    Icons.star,
    Icons.label,
  ];
  List<String> objectifs = [];
  Map<String, dynamic> userData = {};
  String pseudo = '';
  String avatarUrl = '';
  String avatarFileName = '';
  String? selectedObjectif;
  String? userToken;
  String userFiliere = "";
  bool isListVisible = false;
  bool isLoading = true;

 
  @override
  void initState() {
    super.initState();
    fetchUserProfile();
    fetchUserData();
    fetchUserDatafilliere();
    fetchObjectifs();
    _getLastAverage();
    _getQuota();
  }

  //convertion des minutes
  String _extractDuration(String objectif) {
  String duree = objectif.replaceAll(RegExp(r'[^0-9h]+'), ''); // Supprime tous les caractères sauf les chiffres, 'h' et 'min'
    duree = duree.replaceAll('h', ' h '); // Ajoute des espaces autour de 'h' pour faciliter la séparation
    duree = duree.replaceAll('min', ' min '); // Ajoute des espaces autour de 'min' pour faciliter la séparation
    return duree.trim(); // Supprime les espaces supplémentaires aux extrémités
  }
  
  //fonction pour calculer la moyenne des quiz
  Future<void> _getLastAverage() async {
    final prefs = await SharedPreferences.getInstance();
    final userToken = prefs.getString('userToken');

    const String apiUrl = '$BASE_URL/$LAST_QUESTION_PATH';
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );
      final body = jsonDecode(response.body);
      final result = body['result'];

      if (result.isNotEmpty) {
        final average = double.parse(result[0]['moyenne_generale']);
        setState(() {
          averageScore = average;
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  //Methode pour afficher le temps passé 
  Future<void> _getQuota() async {
    final prefs = await SharedPreferences.getInstance();
    final userToken = prefs.getString('userToken');
    const String apiUrl = '$BASE_URL/$QUOTA_PATH';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );
      final body = jsonDecode(response.body);
      setState(() {
        duree = body['duree'];
        quota = body['quota'].toDouble(); // Conversion en double
        quotaWidthFactor = quota; // Mettez à jour la nouvelle variable
        isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }
   //ajouter try  er catch
  //Récupération de l'objectif hebdomadaire
  Future<void> fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken'); 
    //print('authentification: $userToken');
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
      //print('utilisateur: $user');
      if (user.containsKey('Objectif hebdomadaire')) {
        setState(() {
          userData = {
            'Objectif hebdomadaire': user['Objectif hebdomadaire'],
          };
          //print('Objectif hebdomadaire récupérée avec succès : ${userData['Objectif hebdomadaire']}');
        });
      } else {
        print("La clé 'Objectif hebdomadaire' n'est pas présente dans les données de l'utilisateur.");
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
  
  //gestion pour afficher la liste de l'objectif
  Future<void> fetchObjectifs() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
     /*await EasyLoading.show(
      status: 'En cours...',
      maskType: EasyLoadingMaskType.black,
    );*/
      try {
        final response = await http.get(
          Uri.parse('$BASE_URL/$OBJECTIFS_PATH'),
          headers: {
            'Accept': 'application/json',
          },
        );
         // Exemple de délai simulé pour les besoins de démonstration
      //await Future.delayed(Duration(seconds: 2));
      // Masquer l'indicateur de chargement
      EasyLoading.dismiss();
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('data') && data['data'] is List<dynamic>) {
          final List<dynamic> objectifsData = data['data'];
          final List<String> fetchedObjectifs = objectifsData
              .map((item) => item['libelle'].toString())
              .toList();

            setState(() {
              objectifs.clear();
              objectifs.addAll(fetchedObjectifs);
            });
          } else {
            throw Exception('Failed to load objectifs');
          }
        } else {
          throw Exception('Failed to load objectifs');
        }
      } catch (error) {
      print('Error fetching objectifs: $error');
      // Masquer l'indicateur de chargement en cas d'erreur
       //EasyLoading.dismiss(); 
    }
  }
  
  //sauvegarde de l'objectif
  Future<void> _saveObjectif(String selectedObjectif) async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
    final url = Uri.parse('$BASE_URL/$CHOISIR_OBJECTIF_PATH'); 
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $userToken',
    };
    final body = {
      'selected_objectif': selectedObjectif,
    };
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
            content: Text(
              'Objectif enregistré avec succès.',
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold, 
                color: Colors.white, 
              ),
            ),
            backgroundColor: Color(0xFF70A19F), 
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AccueilPage(averageScore: averageScore),
          ),
        ); 
        } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Erreur lors de l\'enregistrement de l\'objectif',
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Erreur lors de la requête. Veuillez réessayer.',
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold, 
              color: Colors.white, 
            ), 
          ),
          backgroundColor: Color(0xFFFC6161), 
        ),
      );
    }
  }

  ///Recupérer liste l'objectif hebdomadaire du user 
  Widget buildObjectifTile(String objectif) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16), 
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8), 
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          objectif,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black, 
          ),
        ),
        tileColor: Colors.transparent, // Couleur de fond transparente
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), 
        onTap: () {
          setState(() {
            selectedObjectif = objectif;
          });
          _saveObjectif(selectedObjectif!);
        },
        trailing: const Icon(
          Icons.check, 
          color: Colors.green, 
        ),
      ),
    );
  }

  //fonction qui traite le profil du user
  Future<void> fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
    //print('authentification: $userToken');
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
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('success') && data['success'] == true) {
          // Récupérez le pseudo et l'URL de l'avatar depuis les données du profil
          final String userPseudo = data['pseudo'];
          final String userAvatarRelativeUrl = data['avatar'];
          // Remplacez ceci par l'URL de base de votre serveur
          const baseUrl = '$BASE_URL/storage';
          // Construisez l'URL absolue en combinant la base de l'URL et l'URL relative de l'avatar
          final userAvatarUrl = '$baseUrl/$userAvatarRelativeUrl';
          //print('Pseudo récupéré : $userPseudo');
          //print('URL de l\'avatar récupéré : $userAvatarUrl');
          setState(() {
            pseudo = userPseudo; // Mettez à jour le pseudo dans l'état local
            avatarUrl = userAvatarUrl; // Mettez à jour l'URL de l'avatar dans l'état local
          });
          //print('Mise à jour de l\'état local effectuée');
        }
      }
    } catch (error) {
      print('Erreur lors de la récupération du profil utilisateur : $error');
    }
  }

  //Récupérer libelle filiere
  Future<void> fetchUserDatafilliere() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
    //print("User Token: $userToken"); // Vérifiez que le jeton d'utilisateur est correct.
    final response = await http.get(
      Uri.parse('$BASE_URL/$USER_PATH'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $userToken',
      },
    );
    //print("Response Status Code: ${response.statusCode}"); // Vérifiez le code d'état de la réponse.
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final user = data['user'];
      //print("User Data: $user"); // Vérifiez les données de l'utilisateur.
      if (user.containsKey('Module')) {
        setState(() {
          userFiliere = user['Module']; // Stockez la filière dans userFiliere.
          //print("User Filiere: $userFiliere"); // Vérifiez la valeur de la filière.
        });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF70A19F),
        automaticallyImplyLeading: false, // Désactive la flèche de retour
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ComptePage(averageScore: widget.averageScore)),
                );
              },
              child: SizedBox(
                width: 40,
                height: 40,
                child: ClipOval(
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(avatarUrl as String? ?? 'b.png'),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10), 
            const Text(
              'Tolearnio',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                    decoration: const BoxDecoration(
                      color: Color(0xFF70A19F),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bienvenue $pseudo',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Découvrez un monde d\'apprentissage interactif et amusant',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                       const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => Architecture(averageScore: widget.averageScore)),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 252, 202, 145), 
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5), 
                                ),
                              ),
                              child: const Text(
                                'Me tester',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 253, 253, 253), 
                                  fontSize: 16, 
                                  fontWeight: FontWeight.bold, 
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => SearchPage(averageScore: widget.averageScore)),
                                );
                              },
                              child: const Text(
                                'Aller aux cours',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 254),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[100], // Couleur de fond du cadre
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Objectifs hebdomadaires',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                CircleAvatar(
                                  backgroundColor: Colors.orange,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        isListVisible = !isListVisible;
                                      });
                                    },
                                  ),
                               ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Stack(
                              children: [
                                Container(
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: duree == 0 ? 0 : quotaWidthFactor / duree, // Utilisez la nouvelle variable ici
                                  child: Container(
                                    height: 10,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color.fromARGB(255, 66, 146, 73),
                                          Color.fromARGB(255, 70, 206, 131),
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              height: isListVisible ? 200 : 0,
                              child: isListVisible
                              ? ListView.builder(
                                itemCount: objectifs.length,
                                itemBuilder: (context, index) {
                                  return buildObjectifTile(objectifs[index]);
                                },
                              )
                            : null,
                            ),
                            const SizedBox(height: 10),
                            Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    // Supprimez complètement la condition suivante avec le CircularProgressIndicator()
    // if (isLoading) CircularProgressIndicator(), 
    Text(
      '${isLoading ? '' : quota.toStringAsFixed(2)} min', 
      style: const TextStyle(
        color: Color.fromARGB(255, 248, 232, 5),
        fontWeight: FontWeight.bold,
      ),
    ),
    Text(
      userData['Objectif hebdomadaire'] != null
        ? '${_extractDuration(userData['Objectif hebdomadaire'])} min'
        : '',
      style: const TextStyle(
        color: Color.fromARGB(255, 248, 232, 5),
        fontWeight: FontWeight.bold,
      ),
    ),
  ],
),

                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0), 
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 50,
                                backgroundColor: Color(0xFF70A19F),
                                child: Icon(
                                  Icons.school,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
  children: [
    // Vous pouvez supprimer complètement la condition suivante avec le CircularProgressIndicator()
    // if (isLoading) CircularProgressIndicator(), 
    const Text(
      'Moyenne générale',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    ),
    const SizedBox(height: 14),
    Text(
      '${isLoading ? '' : averageScore.toStringAsFixed(2)} /20', 
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.teal,
      ),
    ),
  ],
),

                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: 300,
                            height: 50,
                            child: Marquee(
                              text: 'Votre module choisit est $userFiliere',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown[800],
                              ),
                              scrollAxis: Axis.horizontal,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              blankSpace: 20.0,
                              velocity: 50.0,
                              pauseAfterRound: const Duration(seconds: 1),
                              startPadding: 20.0,
                              accelerationDuration: const Duration(seconds: 1),
                              accelerationCurve: Curves.linear,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.home,
                        color: _selectedIndex == 0 ? const Color(0xFF70A19F) : Colors.grey,
                        size: 16,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 0;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AccueilPage(averageScore: averageScore),
                          ),
                        );

                      },
                    ),
                    Text(
                      'Accueil',
                      style: TextStyle(
                        color: _selectedIndex == 0 ? const Color(0xFF70A19F) : Colors.grey, 
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.library_books,
                        color: _selectedIndex == 1 ? Colors.green : Colors.grey,
                        size: 16,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 1;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Architecture(averageScore: widget.averageScore)),
                        );
                      },
                    ),
                    Text('Me tester', style: TextStyle(
                      color: _selectedIndex == 1 ? Colors.green : Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.book,
                        color: _selectedIndex == 2 ? Colors.orange : Colors.grey,
                        size: 16, 
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 2;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SearchPage(averageScore: widget.averageScore)),
                        );
                      },
                    ),
                    Text(
                      'Mes Cours',
                      style: TextStyle(
                        color: _selectedIndex == 2 ? Colors.orange : Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.bold, 
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

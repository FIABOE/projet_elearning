// ignore_for_file: library_private_types_in_public_api, unnecessary_const

import 'package:flutter/material.dart';
import '../Compte/compte_page.dart';
import '../Homepage/accueil_page.dart';
import 'package:education/screen/Quiz/cours_page.dart';
import 'package:education/screen/Quiz/Contenu/architecture.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:education/utils/constances.dart';

class RevisionPage extends StatefulWidget {
  const RevisionPage({super.key});

  @override
  _RevisionPageState createState() => _RevisionPageState();
}

class _RevisionPageState extends State<RevisionPage> {
  int _selectedIndex = 1;
  Map<String, dynamic> userData = {}; 
  String? userToken;
  String avatarUrl = ''; 
  final double averageScore = 0.0;
  
  //Pour récupérer la filliere choisit
  Widget buildFiliereWidget() {
    if (userData['Filiere'] != null) {
      return Text(
        userData['Filiere'],
        style: const TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      );
    } else {
    //Message d'erreur si la filière est nulle.
      return const Text(
        '',
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchUserProfileAvatar();
  }

  Future<void> fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken'); 
    //print('authentification: $userToken');

    final response = await http.get(
      Uri.parse('$BASE_URL:8000/api/user'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $userToken',
      },
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final user = data['user'];
      //print('utilisateur: $user');
      
      if (user.containsKey('Filiere')) {
        setState(() {
          userData = {
            'Filiere': user['Filiere'],
          };
          print('Filiere récupérée avec succès : ${userData['Filiere']}');
        });
      } else {
        print("La clé 'Filiere' n'est pas présente dans les données de l'utilisateur.");
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

  Future<void> fetchUserDat() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');

    final response = await http.get(
      Uri.parse('$BASE_URL:8000/api/user'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $userToken',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final user = data['user'];
      
      if (user.containsKey('filiere_id')) { 
        //print('ID de la filière : ${user['filiere_id']}');
        setState(() {
          userData['FiliereId'] = user['filiere_id'];
        });
      }
    } else {
      // Gérez l'erreur en conséquence
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

  //fonction qui traite l'avatar choisit par l'utilisateur
  Future<void> fetchUserProfileAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
    //print('authentification: $userToken');
    try {
      print('Début de la requête HTTP');
      final response = await http.get(
        Uri.parse('$BASE_URL:8000/api/user/profile'),
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
          //final String userPseudo = data['pseudo'];
          final String userAvatarRelativeUrl = data['avatar'];

          // Remplacez ceci par l'URL de base de votre serveur
          const baseUrl = '$BASE_URL:8000/storage';

          // Construisez l'URL absolue en combinant la base de l'URL et l'URL relative de l'avatar
          final userAvatarUrl = '$baseUrl/$userAvatarRelativeUrl';

          //print('Pseudo récupéré : $userPseudo');
          //print('URL de l\'avatar récupéré : $userAvatarUrl');

          setState(() {
            //pseudo = userPseudo; // Mettez à jour le pseudo dans l'état local
            avatarUrl = userAvatarUrl; // Mettez à jour l'URL de l'avatar dans l'état local
          });

          //print('Mise à jour de l\'avatar effectuée');
        }
      }
    } catch (error) {
      print('Erreur lors de la récupération de l\'avatar de utilisateur : $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF70A19F),
        automaticallyImplyLeading: false,
        titleSpacing: 0.0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Utiliser le MainAxisAlignment.spaceBetween pour séparer les éléments
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text(
                'Tolearnio',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
            const Text(
              'Révision',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            
            IconButton(
              icon: const Icon(
                Icons.search,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () {
                Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RevisionPage()),
                      );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RevisionPage()),
              );
            },
            icon: SizedBox(
              width: 40,
              height: 40,
              child: ClipOval(
                child: CircleAvatar(
                  backgroundImage: NetworkImage(avatarUrl as String? ?? 'b.png'), 
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RevisionPage()),
                          );
                        },
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color.fromARGB(255, 82, 201, 181),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.grey,
                                        ),
                                        padding: const EdgeInsets.all(8.0),
                                        child: const Icon(
                                          Icons.watch,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 8.0),
                                      const Text(
                                        'Min de révision',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Text(
                                    '0 min',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 238, 70, 3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                            //title: Text('Alerte'),
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'C\'est votre pourcentage de bonnes réponses sur l\'ensemble des quiz proposés pour ton année scolaire. Cartonne dans tous tes quiz pour atteindre le 100%! Pour ton année de ----, tu es à : ---min',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16.0),
                                Align(
                                  alignment: Alignment.center,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pop(); // Ferme la boîte de dialogue
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const RevisionPage()),
                                      );
                                    },
                                    child: const Text(
                                      'OK',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pour l\'année',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 20,
                          ),
                        ),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Color.fromARGB(255, 215, 218, 221),
                              child: CircularProgressIndicator(
                                value: 0.5, // Remplacez la valeur avec le pourcentage de progression réel
                                backgroundColor: Colors.white,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color.fromARGB(255, 241, 219, 13),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.0),
                            Text(
                              '0%', // Remplacez la valeur avec le pourcentage de progression réel
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 91, 175, 161),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ),
            //Padding(
              //padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 4.0),
              //child: SizedBox(
                //width: double.infinity,
                //child: Card(
                  //elevation: 3,
                  //shape: RoundedRectangleBorder(
                    //borderRadius: BorderRadius.circular(10),
                  //),
                  //color: const Color.fromARGB(255, 251, 252, 251), // Couleur de fond de la carte
                  //child: const Padding(
                    //padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0), 
                    //child: Column(
                      //crossAxisAlignment: CrossAxisAlignment.start,
                      //children: [
                        //Row(
                          //children: [      
                           //CircleAvatar(
                              //backgroundImage: AssetImage('assets/images/ve.png',
                              //),
                              //radius: 20, // La moitié de la largeur/hauteur souhaitée
                            //),
                            //SizedBox(width: 8.0),
                            //Text(
                              //'S\'entrainer sur tous les matières',
                              //style: TextStyle(
                                //fontWeight: FontWeight.bold,
                                //fontSize: 18,
                                //color: Color.fromARGB(255, 216, 19, 5),
                              //),
                            //),
                          //],
                        //),
                        // Autres widgets de statistiques par matière
                      //],
                    //),
                  //),
                //),
              //),
            //),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 4.0),
              child: SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          //title: Text('Alerte'),
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'C\'est la moyenne des notes obtenues sur les quiz que vous avez déjà terminé pour votre année scolaire.',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              Align(
                                alignment: Alignment.center,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context); // Ferme la boîte de dialogue
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const RevisionPage()),
                                    );
                                  },
                                  child: const Text(
                                    'OK',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: const Color.fromARGB(255, 111, 179, 190), // Couleur de fond de la carte
                    child: const Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Moyenne générale',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 16.0),
                          Center(
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.blue, // Couleur de fond de l'icône
                              child: Icon(
                                Icons.school,
                                color: Colors.white, // Couleur de l'icône
                                size: 40,
                              ),
                            ),
                          ),
                          SizedBox(height: 16.0),
                          Center(
                            child: Text(
                              '9.5', // Moyenne provisoire
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 251, 251, 252),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 4.0),
              child: SizedBox(
                width: double.infinity,
                child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RevisionPage()),
                      );
                    },
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: const Color.fromARGB(255, 236, 192, 141), // Couleur de fond de la carte
                  child: Padding(
                     padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0), 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Center(
                              child: Image.asset(
                                'assets/images/sta.png',
                                width: 40,
                                height: 40,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            const Text(
                              'Mes statistiques',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        // Autres widgets de statistiques par matière
                      ],
                    ),
                  ),
                ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 4.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RevisionPage()), // Remplacez ArchitecturePage par le nom de votre page
                  );
                },
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: const Color(0xFFECEFF1),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Mon parcours',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const RevisionPage()),
                              );
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.fromARGB(255, 219, 156, 96),
                              ),
                              child: const Icon(
                                Icons.settings,
                                color: Color.fromARGB(255, 252, 251, 251),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: Colors.white, // Modifier la couleur de la sous-carte si nécessaire
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildFiliereWidget(), // Utilisation de la fonction pour afficher la filière
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                    ],
                  ),
                ),
              ),
            ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
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
                    color: _selectedIndex == 0 ? Colors.blue : Colors.grey,
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
                    color: _selectedIndex == 0 ? Colors.blue : Colors.grey,
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
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RevisionPage()),
                    );
                  },
                ),
                Text(
                  'Révision',
                  style: TextStyle(
                    color: _selectedIndex == 1 ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.emoji_events,
                    color: _selectedIndex == 2 ? Colors.orange : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 2;
                    });
                    // Action pour l'icône de tournoi
                  },
                ),
                Text(
                  'Tournoi',
                  style: TextStyle(
                    color: _selectedIndex == 2 ? Colors.orange : Colors.grey,
                  ),
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.star,
                    color: _selectedIndex == 3 ? Colors.purple : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 3;
                    });
                    // Action pour l'icône de profil
                  },
                ),
                Text(
                  'Premium',
                  style: TextStyle(
                    color: _selectedIndex == 3 ? Colors.purple : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ExerciseCard extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String title;

  const ExerciseCard({
    required this.icon,
    required this.color,
    required this.title,
    super.key,
  });

  @override
  _ExerciseCardState createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isTapped = !_isTapped;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        transform: Matrix4.translationValues(
          0.0,
          _isTapped ? -10.0 : 0.0,
          0.0,
        ),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: _isTapped ? widget.color.withOpacity(0.8) : Colors.grey[100],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isTapped ? Colors.white.withOpacity(0.8) : widget.color,
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      widget.icon,
                      color: _isTapped ? widget.color : Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: _isTapped ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
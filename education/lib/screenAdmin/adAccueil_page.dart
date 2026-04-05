import 'package:flutter/material.dart';
import 'package:education/screenAdmin/Add_filiere.dart';
import 'package:education/screenAdmin/AddCours_page.dart';
import 'package:education/screenAdmin/AddObjectif_page.dart';
import 'package:education/screenAdmin/AddQuiz_page.dart';
import 'package:education/screenAdmin/Profile_admin.dart';
import 'package:education/screenAdmin/AddExercices_page.dart';
import 'package:education/screenAdmin/listeADD/ListCours.dart';
import 'package:education/screenAdmin/listeADD/ListeFill.dart';
import 'package:education/screenAdmin/listeADD/ListObjectif.dart';
import 'package:education/screenAdmin/listeADD/ListExercice.dart';
import 'package:education/screenAdmin/listeADD/ListQuiz.dart';
import 'package:education/screenAdmin/listeADD/ListMod.dart';
import 'package:education/screenAdmin/listeADD/ListApprenants.dart';
import 'package:education/screen/omboard/onboarding_screen.dart';
import 'package:education/screenAdmin/AddQuiz_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animations/animations.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:education/screenAdmin/CercleStatistique.dart';
import 'package:education/screenAdmin/GraphStatistics.dart';
import 'package:education/screenAdmin/Filiere_Sta.dart';
import 'package:education/screenAdmin/Exo_Sta.dart';
import 'package:education/screenAdmin/Cours_Sta.dart';
import 'package:education/screenAdmin/Quiz_Sta.dart';
import 'package:education/screenAdmin/Liste_app_quiz.dart';
import 'package:education/screenAdmin/Objectif_Sta.dart';
import 'package:education/screenAdmin/TableStatistics.dart';
import 'package:education/utils/constances.dart';

class AdAccueilPage extends StatefulWidget {
  const AdAccueilPage({super.key});

  @override
  _AdAccueilPageState createState() => _AdAccueilPageState();
}

class _AdAccueilPageState extends State<AdAccueilPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController motDePasseController = TextEditingController();

  bool isValiderActive = false;//Activation
  int _selectedIndex = 0;
  String userName=''; 
  String? selectedRole; // Variable pour stocker le rôle sélectionné
  String? userToken; //Variable du token

  //Déclaration des variables pour les totaux
  int totalApprenants = 0;
  int totalModerateurs = 0;
  int totalFilieres = 0;
  int totalObjectifs = 0;
  int totalCours = 0;
  int totalQuiz = 0;
  int totalExercices = 0;
  int totalNiveaux = 0;
  
  //Appel des fonction
  @override
   void initState() {
    super.initState();
    fetchData(); 
    //fetchDataPeriodically();
    _loadUserName();
  }

  // Fonction pour charger le nom de l'utilisateur depuis les préférences partagées
  void _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? ''; 
      //prefs.setString('userName', user.name);
    });
  }
   
   //Récupération du token
   Future<void> _getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
    //print('Token d\'authentification récupéré depuis les préférences : $userToken');
  }

  //Boite pour l'ajout d'un modérateur
  void _afficherBoiteDialogue(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
      selectedRole = null;
      //nomController.clear(); 
      //prenomController.clear(); 
      //emailController.clear(); 
      //motDePasseController.clear();
        return SingleChildScrollView( 
        child: AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.add, 
                color: Colors.green, 
              ),
              SizedBox(width: 10), 
              Text(
                'Ajouter',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold, 
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nomController,
                  decoration: const InputDecoration(labelText: 'Nom'),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Veuillez entrer votre nom.';
                    }
                    if (value?.length == 1) {
                      return 'Le nom doit comporter plus d\'une lettre.';
                    }
                    if (RegExp(
                            r'[0-9!@#%^&*()_+={}\[\]:;<>,.?~\\/]')
                        .hasMatch(value ?? '')) {
                      return 'Le nom ne doit pas contenir de chiffres ou de caractères spéciaux.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: prenomController,
                  decoration: const InputDecoration(labelText: 'Prénom'),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Veuillez entrer votre prénom.';
                    }
                    if (value?.length == 1) {
                      return 'Le prénom doit comporter plus d\'une lettre.';
                    }
                    if (RegExp(
                            r'[0-9!@#%^&*()_+={}\[\]:;<>,.?~\\/]')
                        .hasMatch(value ?? '')) {
                      return 'Le prénom ne doit pas contenir de chiffres ou de caractères spéciaux.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Veuillez entrer votre email.';
                    }
                    if (!isValidEmail(value ?? '')) {
                      return 'Veuillez entrer une adresse email valide.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: motDePasseController,
                  decoration: const InputDecoration(labelText: 'Mot de passe'),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Veuillez entrer votre mot de passe.';
                    }
                    if (value!.length < 8) {
                      return 'Le mot de passe doit comporter au moins 8 caractères.';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                   // Champ de liste déroulante du rôle (ajouté)
                  value: selectedRole,
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value;
                    });
                  },
                  items: ['Modérateur'].map((role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  decoration: const InputDecoration(labelText: 'Rôle'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez sélectionner un rôle.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.red, // Couleur du texte (blanc)
                      ),
                      child: const Text('Annuler'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          registerModerateur(); // Appel de la fonction pour envoyer la requête HTTP
                          Navigator.of(context).pop(); // Fermer la boîte de dialogue
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: const Color(0xFF70A19F), // Couleur du texte (blanc)
                      ),
                      child: const Text('Valider'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        );
      },
    );
  }

  //L'email doit respecté le convention habituel ...@...com
  bool isValidEmail(String email) {
    final RegExp regex = RegExp(
        r'^[\w-]+(\.[\w-]+)*@([a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)+)$');
    return regex.hasMatch(email);
  }
  
  //Fonction pour appeler l'api pour permettre l'ajout du mod dans la base de donnée
  Future<void> registerModerateur() async {
    const String apiUrl = '$BASE_URL/$Register_Mod_PATH'; 
    final Map<String, dynamic> formData = {
      'surname': nomController.text,
      'name': prenomController.text,
      'email': emailController.text,
      'password': motDePasseController.text,
      'role': selectedRole, // Ajoutez le rôle aux données envoyées à l'API
    };
  
  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      body: formData,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $userToken',
      },
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Modérateur enregistré avec succès',
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
        const SnackBar(
          content: Text(
            'Ce modérateur existe déjà',
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
  } catch (error) {
    // Gestion des erreurs réseau ou autres
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Une erreur s\'est produite : $error',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFFFC6161),
        ),
      );
    }
  }
  
  //Recuperation des totaux depuis l'api
  Future<void> fetchData() async {
  final Uri apiUrl = Uri.parse('$BASE_URL/$Total_Get_PATH');

  try {
    final response = await http.get(
      apiUrl,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $userToken',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (mounted) {
        setState(() {
          totalApprenants = data['total_apprenants'];
          totalModerateurs = data['total_moderateurs'];
          totalFilieres = data['total_filiere'];
          totalObjectifs = data['total_objectif'];
          totalCours = data['total_cours'];
          totalQuiz = data['total_quiz'];
          totalExercices = data['total_exercices'];
          totalNiveaux = data['nombre_niveaux'];
        });
      }
    } else {
      //print('Erreur lors de la récupération des données : ${response.statusCode}');
    }
  } catch (exception) {
    print('Exception lors de la récupération des données : $exception');
  }
}

//Rafraichissement des totaux après modification faite
/*void fetchDataPeriodically() {
  // Rafraîchir les données toutes les 30 secondes (vous pouvez ajuster cette valeur)
  const refreshInterval = Duration(seconds: 1);
  Future<void> refresh() async {
    await fetchData();
    // Lancer une nouvelle actualisation après l'intervalle
    await Future.delayed(refreshInterval);
    refresh();
  }

  // Lancer la première actualisation
  refresh();
}*/

 // Le corps
  @override
  Widget build(BuildContext context) {
  return Scaffold(
      resizeToAvoidBottomInset: true,
    appBar: PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: RoundedBottomAppBar(
        userName: userName,
      ),
    ),
    drawer: const MyDrawer(),
    body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RoundedTopRightCard(
            child: Container(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              width: double.infinity,
              height: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cardTitles.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: buildStaCard(index),// Appel des carte de statistique
                        );
                      },
                    ),
                  ),
                  // Ajoutez le contenu du nombre total d'apprenants ici
                  Container(
                    padding: const EdgeInsets.all(0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.people,
                              color: Color(0xFF70A19F),
                            ), 
                            const SizedBox(width: 8), 
                            Text(
                              'Nombre total d\'apprenants: $totalApprenants',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
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
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    _afficherBoiteDialogue(context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: const Color(0xFF70A19F),
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add),
                      SizedBox(width: 8),
                      Text('Ajouter un modérateur'),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8), // Ajustez la marge intérieure
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Total Modérateur',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16, 
                          ),
                        ),
                        const SizedBox(height: 4), 
                        Text(
                          '$totalModerateurs', 
                          style: const TextStyle(
                            fontSize: 20, 
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF70A19F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
            SizedBox(
              height: 300,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (context, index) {
                  return RoundedTopRightCard(
                    child: buildCustomCard(index),
                    onPressed: () {
                      _handleCardClick(context, index);
                    },
                  );
                },
              ),
            ),
          ],  
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedIndex: _selectedIndex,
        onTabTapped: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  // La liste des couleurs pour les cartes (modifiables)
  final List<String> cardTitles = [
    'Total Modules',
    'Total Objectifs',
    'Total Cours',
    'Total Quiz',
    'Total Niveaux',
    'Total Exercices',
  ];
  final List<IconData> cardIcons = [
    Icons.book, 
    Icons.assignment,
    Icons.menu_book,
    Icons.question_answer,
     Icons.layers,
    Icons.fitness_center,
  ];
   final List<Color> cardColors = [
    const Color(0xFF70A19F), // Couleur personnalisée pour Total Filieres
    const Color(0xFF70A18C), // Couleur personnalisée pour Total Objectifs
    Colors.orange, // Couleur personnalisée pour Total Cours
    Colors.teal, // Couleur personnalisée pour Total Quiz
    const Color(0xFF70A18C), // Couleur personnalisée pour Total Objectifs
    const Color(0xFF70A18C), // Couleur personnalisée pour Total Exercices
  ];
   
   //methode pour les cartes statiques
 Widget buildStaCard(int index) {
  int value = 0;

  switch (index) {
    case 0:
      value = totalFilieres;
      break;
    case 1:
      value = totalObjectifs;
      break;
    case 2:
      value = totalCours;
      break;
    case 3:
      value = totalQuiz;
      break;
       case 4:
      value = totalNiveaux;
      break;
    case 5:
      value = totalExercices;
    break;
  }

  return Container(
    padding: const EdgeInsets.all(16),
    width: 250,
    decoration: BoxDecoration(
      color: cardColors[index],
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 3,
          blurRadius: 7,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          cardIcons[index],
          color: Colors.white,
          size: 40,
        ),
        const SizedBox(height: 8),
        Text(
          cardTitles[index],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Valeur : $value',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20, 
            fontWeight: FontWeight.bold, 
          ),
        ),
      ],
    ),
  );
}

  //pour afficher la date du jour
 /* String getCurrentDate() {
    final now = DateTime.now();
    final formattedDate = "${now.day}/${now.month}/${now.year}";
    return formattedDate;
  }*/

  void _handleCardClick(BuildContext context, int index) {
  switch (index) {
    case 0:
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddFiliere(),
        ),
      );
      break;
    case 1:
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddObjectif(),
        ),
      );
      break;
    case 2:
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddCours(),
        ),
      );
      break;
    case 3:
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddQuiz(),
        ),
      );
      break;
    case 4:
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddExercices(),
        ),
      );
      break;
  }
}

  //pour les catre d'en bas
  Widget buildCustomCard(int index) {
    String cardTitle = '';
    IconData cardIcon = Icons.star;
    Color cardColor = Colors.white;

    switch (index) {
      case 0:
        cardTitle = 'Module';
        cardIcon = Icons.school;
        cardColor = const Color(0xFFEEC867);
        break;
      case 1:
        cardTitle = 'Objectif';
        cardIcon = Icons.assignment;
        cardColor = const Color(0xFF70A19F);
        break;
      case 2:
        cardTitle = 'Cours';
        cardIcon = Icons.book;
        cardColor = Colors.orange;
        break;
      case 3:
        cardTitle = 'Quiz';
        cardIcon = Icons.quiz;
        cardColor = Colors.teal;
        break;
      case 4:
        cardTitle = 'Exercice';
        cardIcon = Icons.fitness_center;
        cardColor = const Color(0xFFA48EA0);
        break;
    }

    return Card(
    elevation: 4,
    margin: const EdgeInsets.all(12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  cardIcon,
                  size: 30,
                  color: cardColor,
                ),
                const SizedBox(height: 10),
                Text(
                  cardTitle,
                  style: TextStyle(fontSize: 20, color: cardColor),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {
              // Utilisez le même callback que pour le texte ou l'icône
              _handleCardClick(context, index);
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(), backgroundColor: cardColor,
              padding: const EdgeInsets.all(16),
            ),
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
  );
}
  }


//pour l'en tête
class RoundedBottomAppBar extends StatelessWidget {
  final String userName; 

  const RoundedBottomAppBar({super.key, required this.userName}); 
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: const ShapeBorderClipper(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30.0),
            bottomRight: Radius.circular(0.0),
          ),
        ),
      ),
      child: AppBar(
        backgroundColor: const Color(0xFF70A19F),
        elevation: 5,
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            //userName.isNotEmpty ? userName : '',
            'Mr AMA',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        actions: [
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    getCurrentDate(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  
  //pour l'affichage de la date du jour
  String getCurrentDate() {
    final now = DateTime.now();
    final formattedDate = "${now.day}/${now.month}/${now.year}";
    return formattedDate;
  }
}

//Pour le pid de page
class BottomNavigationBar extends StatelessWidget {
 final int selectedIndex;
  final Function(int) onTabTapped;

  const BottomNavigationBar({super.key, required this.selectedIndex, required this.onTabTapped});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          buildNavItem(Icons.home, 'Accueil', 0, () {
             onTabTapped(0);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdAccueilPage(),
              ),
            );
          }),
          buildNavItem(Icons.insert_chart, 'Nombre inscrit', 1, () {
            onTabTapped(1);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GraphStatisticsPage(),
              ),
            );
          }),
           buildNavItem(Icons.table_chart, 'Nombre d\'ajout', 2, () {
            onTabTapped(2);
            DialogHelper.showTableOptionsDialog(context);
          }),
        ],
      ),
    );
  }

  Widget buildNavItem(IconData icon, String label, int index, Function() onPressed) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            icon,
            color: selectedIndex == index ? const Color(0xFF70A19F) : Colors.grey,
            size: 16,
          ),
          onPressed: () {
            onTabTapped(index);
            onPressed();
          },
        ),
        Text(
          label,
          style: TextStyle(
            color: selectedIndex == index ? const Color(0xFF70A19F) : Colors.grey,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}


//pour le dashboard
class RoundedTopRightCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;

  const RoundedTopRightCard({super.key, required this.child, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(0.0),
          bottomLeft: Radius.circular(16.0),
          bottomRight: Radius.circular(16.0),
        ),
      ),
      child: InkWell(
        onTap: onPressed, 
        child: child,
      ),
    );
  }
}
class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    const TextStyle drawerItemStyle = TextStyle(
      color: Colors.black, 
      fontSize: 18, 
      fontWeight: FontWeight.bold, 
    );
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF70A19F),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.school,
                  color: Colors.white,
                  size: 40,
                ),
                Text(
                  'Tolearnio',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.list,
              color: Color(0xFF70A19F), 
            ),
            title: const Text(
              'Liste des modules',
              style: drawerItemStyle, 
            ),
             onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/ListFill'); 
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.check_circle,
              color: Color(0xFF70A19F), 
            ),
            title: const Text(
              'Liste d\'objectifs',
              style: drawerItemStyle, 
            ),
             onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/ListObjectif'); 
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.library_books,
              color: Color(0xFF70A19F), 
            ),
            title: const Text(
              'Liste de cours',
              style: drawerItemStyle, 
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/ListCours'); 
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.quiz,
              color: Color(0xFF70A19F), 
            ),
            title: const Text(
              'Liste des questions',
              style: drawerItemStyle, 
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/ListQuiz'); 
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.fitness_center,
              color: Color(0xFF70A19F), 
            ),
            title: const Text(
              'Liste des exercices',
              style: drawerItemStyle, 
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/ListExercices');
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.people,
              color: Color(0xFF70A19F), 
            ),
            title: const Text(
              'Liste des modérateur',
              style: drawerItemStyle, 
            ),
             onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/ListMod'); 
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.people,
              color: Color(0xFF70A19F), 
            ),
            title: const Text(
              'Liste des apprenants',
              style: drawerItemStyle, 
            ),
            onTap: () {
              Navigator.pop(context);
              _afficherOptionsListeApprenants(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.person,
              color: Color(0xFF70A19F), 
            ),
            title: const Text(
              'Profil',
              style: drawerItemStyle, 
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/AdminProfilePage'); 
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.exit_to_app,
              color: Color(0xFF70A19F), 
            ),
            title: const Text(
              'Se Déconnecter',
              style: drawerItemStyle,
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/OnboardingScreen'); 
            },
          ),
        ],
      ),
    );
  }
 void _afficherOptionsListeApprenants(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Liste des apprenants'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.people, color: Colors.blue),
              title: const Text(
                'Liste des apprenants inscrits',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/ListApp');
              },
            ),
            const Divider(), // Ajout d'une ligne de séparation
            ListTile(
              leading: const Icon(Icons.today, color: Colors.green),
              title: const Text(
                'Liste des apprenants qui ont fait des quiz aujourd\'hui',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/ListAppQuiz');
              },
            ),
            const SizedBox(height: 20), 
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); 
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, 
              ),
              child: const Text(
                'Annuler',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const LegendItem({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16, // Largeur du carré de couleur de la légende
          height: 16, // Hauteur du carré de couleur de la légende
          color: color,
        ),
        const SizedBox(width: 4), 
        Text(label),
      ],
    );
  }
}

//Classe pour afficher la boite des staitistique (Quiz,cours,filiere,objectif,exercice)
class DialogHelper {
  static void showTableOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Les statistiques',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200), 
            child: SingleChildScrollView(
              child: Column(
                children: [
                  buildOption(context, 'Nombre de module', Icons.category, const FilliereStatisticsPage()),
                  buildOption(context, 'Nombre de Quiz', Icons.question_answer, const QuizStatisticsPage()),
                  buildOption(context, 'Nombre d\'objectif', Icons.flag, const ObjectifStatisticsPage()),
                  buildOption(context, 'Nombre de Cours', Icons.library_books, const CoursStatisticsPage()),
                  buildOption(context, 'Nombre d\'exercices', Icons.assignment, const ExoStatisticsPage()),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Annuler',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget buildOption(BuildContext context, String text, IconData icon, Widget page) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => page,
          ),
        );
      },
      icon: Icon(icon, color: const Color(0xFF70A19F)),
      label: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}

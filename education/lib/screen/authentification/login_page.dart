import 'package:flutter/material.dart';
import '../Homepage/accueil_page.dart';
import 'dart:convert';
import '../omboard/onboarding_screen.dart';
import '../authentification/register_page.dart';
import 'package:education/screenAdmin/AdAccueil_Page.dart';
import 'package:education/screen/ScreenMod%C3%A9rateur/accueilMod%C3%A9rateur.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:education/models/user.dart';
import 'package:education/utils/constances.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final double averageScore = 0.0;
  late String userName; 
  bool _obscureText = true;
  bool _isFormValid = false;
  String? userToken;
  int _loginAttempts = 0;
  DateTime? _blockEndTime;


  void _updateFormValidity() {
    setState(() {
      if (_formKey.currentState != null) {
        _isFormValid = _formKey.currentState!.validate();
      }
    });
  }
  
  //Same password
  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
  
  //Retour sur la page onboardinScreen
  void _goBackToOnboarding() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      (route) => false, // Supprime toutes les autres routes de la pile
    );
  }
  
  //L'email doit respecté la convention normale et le champs doit être remplie
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre adresse e-mail.';
    }
    final emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Veuillez entrer une adresse e-mail valide.';
    }
    return null;
  }
  
   //Le mot de passe doit respecté la convention normale et le champs doit être remplie
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre mot de passe.';
    }
    if (value.length < 8) {
      return 'Le mot de passe doit comporter au moins 8 caractères.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(top: 0.0),
          child: Text(
            'Se connecter',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22, 
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
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Tolearnio',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF087B95),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            const Text(
              'Consolider vos acquis via notre \nApp d’éducation',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  onChanged: _updateFormValidity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          suffixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Colors.grey, // Couleur du contour par défaut
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF70A19F), // Couleur du contour lorsqu'il est sélectionné
                            ),
                          ),
                        ),
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: passwordController,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: _togglePasswordVisibility,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Colors.grey, // Couleur du contour par défaut
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF70A19F), // Couleur du contour lorsqu'il est sélectionné
                            ),
                          ),
                        ),
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/editPass');
                          },
                          child: const Text(
                            'Mot de passe oublié?',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              height: 45,
              child: ElevatedButton(
                onPressed: _isFormValid ? _performLogin : null,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: _isFormValid ? const Color(0xFF70A19F) : Colors.grey,
                ),
                child: const Text(
                  'Se connecter',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  //Methode pour appelé l'api de login
  void _performLogin() async {
    if (_loginAttempts < 3) {
    final Map<String, dynamic> formData = {
      'email': emailController.text,
      'password': passwordController.text,
    };
     await EasyLoading.show(
    status: 'veuillez patientez...',
    maskType: EasyLoadingMaskType.black,
  );
    try {
      final response = await http.post(
         Uri.parse('$BASE_URL/$LOGIN_PATH'),
        body: formData,
      );
      // Exemple de délai simulé pour les besoins de démonstration
      await Future.delayed(const Duration(seconds: 2));
      // Masquer l'indicateur de chargement
      EasyLoading.dismiss();
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final userToken = responseData['data']['token'];
        if (userToken != null && userToken.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('userToken', userToken);
        }
        
        if (responseData.containsKey('data')) {
          final user = User.fromJson(responseData['data']);
          print('is_active from JSON: ${user.is_active}');
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('userName', user.name);
          
          if (user.is_active == true) {//verification du statut de l'utilisateur
          if (user.role == 'admin') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdAccueilPage()),
            );
          } else if (user.role == 'moderateur') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AccueilMod()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AccueilPage(averageScore: averageScore),
              ),
            );
          }
        } else {
          // Compte inactif
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text(
                  'Compte inactif',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: const Text(
                  'Votre compte est inactif. Veuillez contacter l\'administrateur.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                actions: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        }
      }
    } else if (response.statusCode == 401) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Erreur d\'authentification',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'Vos identifiants sont incorrects. Veuillez réessayer.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      );
      setState(() {
          _loginAttempts++;
        });
    } else if (response.statusCode == 403) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Compte inactif',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'Votre compte est inactif. Veuillez contacter l\'administrateur.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Erreur de connexion',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'Une erreur s\'est produite lors de la connexion. Veuillez réessayer.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  } catch (error) {
    print('Erreur de demande HTTP : $error');
    EasyLoading.dismiss();
  }
  } else {
    // L'utilisateur a dépassé le nombre maximum de tentatives
    _blockEndTime = DateTime.now().add(const Duration(minutes: 6)); // Bloquer pendant 5 minutes

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Trop de tentatives',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            children: [
              const Text(
                'Vous avez dépassé le nombre maximum de tentatives.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
              ),
              if (_blockEndTime != null && DateTime.now().isBefore(_blockEndTime!))
                Text(
                  'Veuillez réessayer dans ${_blockEndTime!.difference(DateTime.now()).inMinutes} minutes.',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                  ),
                ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
}
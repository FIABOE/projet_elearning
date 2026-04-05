import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import '../Info/intro_page.dart';
import '../authentification/login_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:education/utils/constances.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isFormValid = false;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =TextEditingController();
  bool _acceptTerms = false;
  bool _obscureText = true;
  String? _errorMessage;
  final Color _checkedColor = Colors.blue;
  String? userToken;
  String? remember_token;


  DateTime? _selectedDate;
  
  //Pour la validation des champs
  void _updateFormValidity() {
    setState(() {
      _isFormValid = _formKey.currentState?.validate() ?? false;
      _isFormValid = _isFormValid && _acceptTerms;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
  
  //Condition requis lors de la soumission de la Date de naissance 
  String? _validateDateOfBirth(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez choisir votre date de naissance.';
    }

    DateTime currentDate = DateTime.now();
    DateTime selectedDate = DateTime.parse(value);

    String errorMessage =
        'Vous avez moins de 15 ans ! Il est préférable que vos parents ou tuteurs remplissent le formulaire pour vous. Merci.';

    if (currentDate.year - selectedDate.year < 15 ||
        (currentDate.year - selectedDate.year == 15 &&
            currentDate.month < selectedDate.month) ||
        (currentDate.year - selectedDate.year == 15 &&
            currentDate.month == selectedDate.month &&
            currentDate.day < selectedDate.day)) {
      // Supprimer la première occurrence du message d'erreur
      if (_errorMessage == errorMessage) {
        return null;
      }
      return errorMessage;
    }
    return null;
  }
  
  //Condition à remplir pour soumettre l'email
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre adresse email.';
    }
    // Utilisez une expression régulière pour valider le format de l'email
    // Voici un exemple simple, vous pouvez le modifier selon vos besoins
    bool isValidEmail = RegExp(
            r'^[\w-]+(\.[\w-]+)*@([a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)+)$')
        .hasMatch(value);
    if (!isValidEmail) {
      return 'Veuillez entrer une adresse email valide.';
    }
    return null;
  }
  
  //Pour le mot de passe
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre mot de passe.';
    }
    if (value.length < 8) {
      return 'Le mot de passe doit comporter au moins 8 caractères.';
    }
    return null;
  }
  
  //Methode  pour afficher le calendrier
  Future<void> _showDatePicker() async {
    final DateTime? selectedDateTime = await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Align( 
            alignment: Alignment.bottomCenter, //Alignement en bas de la page
            child: Container(
              height: 200,
              color: Colors.white,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: DateTime.now(),
                      onDateTimeChanged: (DateTime newDateTime) {
                        setState(() {
                          _selectedDate = newDateTime;
                          _dateController.text = _selectedDate!
                              .toIso8601String()
                              .split('T')[0];
                          _errorMessage =
                              _validateDateOfBirth(_dateController.text);
                          _updateFormValidity();
                        });
                      },
                    ),
                  ),
                  Positioned(
                    top: 8.0,
                    right: 8.0,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: 32.0,
                        height: 32.0,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 15, 177, 185),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            'OK',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.0,
                            ),
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
      },
    );

    if (selectedDateTime != null) {
      setState(() {
        _selectedDate = selectedDateTime;
        _dateController.text = _selectedDate!.toString();
        _errorMessage = _validateDateOfBirth(_dateController.text);
        _updateFormValidity();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(top: .0),
          child: Text(
            'Inscrivez-vous',
            textAlign: TextAlign.center, // Centrer le texte horizontalement
            style: TextStyle(
              color: Colors.white, // Modifier la couleur du texte en blanc
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
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          onChanged: _updateFormValidity,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Tolearnio',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF087B95),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pour accéder à ce service, il est nécessaire d’avoir 15 ans ou d’obtenir l’autorisation d’un parent.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () {
                    _showDatePicker();
                  },
                  child: AbsorbPointer(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _dateController,
                          decoration: InputDecoration(
                            labelText: 'Date de naissance',
                            suffixIcon: const Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF70A19F), // Couleur du contour lorsqu'il est sélectionné
                              ),
                            ),
                          ),
                          validator: _validateDateOfBirth,
                        ),
                        if (_errorMessage != null)
                          Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Prénom',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF70A19F), // Couleur du contour lorsqu'il est sélectionné
                      ),
                    ),
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre prénom.';
                    }
                    if (value.length == 1) {
                      return 'Le prénom doit comporter plus d\'une lettre.';
                    }
                    if (RegExp(r'[0-9!@#%^&*()_+={}\[\]:;<>,.?~\\/]').hasMatch(value)) {
                      return 'Le prénom ne doit pas contenir de chiffres ou de caractères spéciaux.';
                    }
                    return null;
                  },

                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _surnameController,
                  decoration: InputDecoration(
                    labelText: 'Nom',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF70A19F), // Couleur du contour lorsqu'il est sélectionné
                      ),
                    ),
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre nom.';
                    }
                    if (value.length == 1) {
                      return 'Le nom doit comporter plus d\'une lettre.';
                    }
                    if (RegExp(r'[0-9!@#%^&*()_+={}\[\]:;<>,.?~\\/]').hasMatch(value)) {
                      return 'Le nom ne doit pas contenir de chiffres ou de caractères spéciaux.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(
                      //color: const Color(0xFF70A19F), // Couleur du texte d'indication lorsqu'il est sélectionné
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8), 
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
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF70A19F), // Couleur du contour lorsqu'il est sélectionné
                      ),
                    ),
                  ),
                  obscureText: _obscureText,
                  validator: _validatePassword,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirmez votre mot de passe',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF70A19F), // Couleur du contour lorsqu'il est sélectionné
                      ),
                    ),
                  ),
                  obscureText: _obscureText,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez confirmer votre mot de passe.';
                    }
                    if (value != _passwordController.text) {
                      return 'Les mots de passe ne correspondent pas.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Checkbox(
                      value: _acceptTerms,
                      onChanged: (bool? value) {
                        setState(() {
                          _acceptTerms = value ?? false;
                          _updateFormValidity();
                        });
                      },
                      activeColor: _checkedColor,
                    ),
                    const Flexible(
                      child: Text(
                        'J’accepte les conditions Générales d’utilisation de Tolearnio. Vous bénéficiez d’un droit d’accès, d’information, de rectification, d’effacement, de limitation, d’opposition et de portabilité aux informations collectées.',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(  
        color: const Color(0xFFFFFFFF),
         // Définir la couleur de fond du pied de page à blanc 
        child: SizedBox(
          height: 56.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 300.0,
                height: 45,
                child: ElevatedButton(
                  onPressed: _isFormValid ? _register: null,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    backgroundColor: _isFormValid ? const Color(0xFF70A19F) : Colors.grey,
                  ),
                  child: const Text(
                    'Soumettre',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color:Colors.white,
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
  
  //METHODE POUR L'APPEL DE L'URL ET LE LIIEN AVEC L'Api
  void _register() async {
    if (_isFormValid) {
      final formData = {
        'name': _nameController.text,
        'surname': _surnameController.text,
        'dateNais': _dateController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'c_password': _confirmPasswordController.text,
        'consent': _acceptTerms.toString(),
      };
      final response = await http.post(
        Uri.parse('$BASE_URL/$REGISTER_PATH'),
        body: formData,
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('reponse : $responseData');
        final userToken = responseData['data']['token'];
        print('Token d\'authentification sauvegardé : $userToken');
        
        if (userToken != null && userToken.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('userToken', userToken);
        }
        showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text(
                    'Inscription réussie',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: const Text(
                    'Vous êtes maintenant inscrit.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  actions: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const IntroPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'OK',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
         // }
        //}
      }else if (response.statusCode == 400) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                'Erreur d\'inscription',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: const Text(
                'Un compte existe déjà avec cette adresse e-mail.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: const Text(
                        'Se connecter',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: const Text(
                        'Annuler',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      } else {
        String errorText = 'Inscription échouée. Veuillez réessayer.';
        if (response.body.isNotEmpty) {
          errorText = response.body;
        }
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                'Erreur d\'inscription',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                errorText,
                style: const TextStyle(
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
  }
}



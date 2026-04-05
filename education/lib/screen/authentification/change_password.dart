import 'package:flutter/material.dart';
import 'package:education/utils/constances.dart';
import 'package:education/screen/Homepage/accueil_page.dart';
import 'package:education/screen/authentification/login_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String email;

  const ChangePasswordScreen({super.key, required this.email});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isObscureNewPassword = true;
  bool _isObscureConfirmPassword = true;
  //bool _isLoading = false; 

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre mot de passe.';
    }
    if (value.length < 8) {
      return 'Le mot de passe doit comporter au moins 8 caractères.';
    }
    return null;
  }

  void _changePassword() async {
    String oldPassword = _oldPasswordController.text;
    String newPassword = _newPasswordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (newPassword != confirmPassword) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Erreur'),
            content: const Text('Les mots de passe ne correspondent pas.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); 
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }
    await EasyLoading.show(
    status: 'veuillez patientez...',
    maskType: EasyLoadingMaskType.black,
  );
    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/$CHANGEPASSWORD_PATH'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': widget.email,
          'password': newPassword,
        }),
      );
       // Exemple de délai simulé pour les besoins de démonstration
      await Future.delayed(const Duration(seconds: 2));
      // Masquer l'indicateur de chargement
      EasyLoading.dismiss();
      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Succès'),
              content: const Text('Le mot de passe a été changé avec succès.'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    ); 
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else if (response.statusCode == 500) {
        //print(response.statusCode);
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final errorMessage = responseData['message'] ?? 'Erreur inconnue';
        //print(errorMessage);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erreur sur le serveur"),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      print('Error occurred: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Une erreur est survenue lors de la validation du code.'),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
      EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Changer le mot de passe',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
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
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _newPasswordController,
                obscureText: _isObscureNewPassword,
                decoration: InputDecoration(
                  labelText: 'Nouveau mot de passe',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscureNewPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscureNewPassword = !_isObscureNewPassword;
                      });
                    },
                  ),
                ),
                validator: _validatePassword,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _isObscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirmer le nouveau mot de passe',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscureConfirmPassword =
                            !_isObscureConfirmPassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez confirmer votre mot de passe.';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Les mots de passe ne correspondent pas.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 90),
              ElevatedButton(
                onPressed: _formKey.currentState?.validate() ?? false
                ? () {
                  _changePassword();
                }
                : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF70A19F),
                ),
                child: const Text(
                  'Soumettre',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20,
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
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:education/utils/constances.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isObscureOldPassword = true;
  bool _isObscureNewPassword = true;
  bool _isObscureConfirmPassword = true;
  final bool _isLoading = false;
  String? userToken;

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre mot de passe.';
    }
    if (value.length < 8) {
      return 'Le mot de passe doit comporter au moins 8 caractères.';
    }
    return null;
  }

  void _refreshPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const ChangePasswordScreen(),
      ),
    );
  }

  void _changePassword() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
   await EasyLoading.show(
    status: 'veuillez patientez...',
    maskType: EasyLoadingMaskType.black,
  );
    try {
      String oldPassword = _oldPasswordController.text;
      String newPassword = _newPasswordController.text;
      String confirmPassword = _confirmPasswordController.text;
      if (newPassword != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Les mots de passe ne correspondent pas.',
              style: TextStyle(fontSize: 16),
            ),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      /*setState(() {
        _isLoading = true;
      });*/
      final response = await http.post(
        Uri.parse('$BASE_URL/$RESET2PASSWORD_PATH'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $userToken',
        },
        body: jsonEncode(<String, String>{
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      );
      //print('Réponse du serveur: ${response.statusCode}');
      //print('Corps de la réponse: ${response.body}');

      // Exemple de délai simulé pour les besoins de démonstration
      await Future.delayed(const Duration(seconds: 2));
      // Masquer l'indicateur de chargement
      EasyLoading.dismiss();
      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                'Succès',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              content: const Text(
                'Le mot de passe a été changé avec succès.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _refreshPage();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, 
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold, 
                    ),
                  ),
                ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0), // Coins arrondis
              ),
            );
          },
        );
        } else if (response.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "L'ancien mot de passe est incorrect.",
              style: TextStyle(fontSize: 16),
            ),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
        } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "L'utilisateur n'est pas correctement authentifié.",
              style: TextStyle(fontSize: 16),
            ),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
        } else if (response.statusCode == 500) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final errorMessage = responseData['message'] ?? 'Erreur inconnue';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Erreur sur le serveur: $errorMessage",
              style: const TextStyle(fontSize: 16),
            ),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
      } catch (error) {
      print('Error occurred: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Une erreur est survenue lors de la validation du code.',
            style: TextStyle(fontSize: 16),
          ),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 150),
                TextFormField(
                  controller: _oldPasswordController,
                  obscureText: _isObscureOldPassword,
                  decoration: InputDecoration(
                    labelText: 'Ancien mot de passe',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscureOldPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscureOldPassword = !_isObscureOldPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez saisir votre ancien mot de passe.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
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
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading
                  ? null
                  : () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _changePassword();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF70A19F),
                  ),
                  child: _isLoading
                  ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                  : const Text(
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
      ),
    );
  }
}

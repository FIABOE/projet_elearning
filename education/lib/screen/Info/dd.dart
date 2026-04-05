import 'package:education/screen/authentification/login_page.dart';
import 'package:education/screen/authentification/register_page.dart';
import 'package:flutter/material.dart';
import 'package:education/screen/authentification/otp_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:education/utils/constances.dart';

class EditPassPage extends StatefulWidget {
  const EditPassPage({super.key});

  @override
  _EditPassPageState createState() => _EditPassPageState();
}

class _EditPassPageState extends State<EditPassPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  late String _email;
  bool _isFormValid = false;
  bool _isLoading = false;

  void _updateFormValidity() {
    setState(() {
      _isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            'Mot de passe oublié?',
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
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          onChanged: _updateFormValidity,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Tolearnio',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF087B95),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Consolider vos acquis via notre \nApp d’éducation',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 100),
                const Text(
                  'Veuillez entrer votre adresse e-mail pour réinitialiser votre mot de passe. Merci !',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF087B95),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    suffixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorStyle: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 15,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre adresse e-mail.';
                    }
                    final emailRegExp = RegExp(
                        r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
                    if (!emailRegExp.hasMatch(value)) {
                      return 'Veuillez entrer une adresse e-mail valide.';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _email = value;
                    });
                  },
                ),
                const SizedBox(height: 200),
                SizedBox(
                  width: 400.0,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : (_isFormValid ? _forgotPassword : null),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: _isFormValid
                      ? const Color(0xFF70A19F)
                      : Colors.grey,
                    ),
                     child: _isLoading
                     ? const CircularProgressIndicator() 
                     : const Text(
                      'Soumettre',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, a, b) => const RegisterPage(),
                        transitionDuration: const Duration(seconds: 0),
                      ),
                      (route) => false,
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: "Vous n'avez pas de compte? ",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(
                          text: "S'inscrire",
                          style: TextStyle(
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, a, b) => const LoginPage(),
                        transitionDuration: const Duration(seconds: 0),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text(
                    'Se connecter',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  void _forgotPassword() async {
    final email = _emailController.text;
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/$EDIT_PATH'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email':email,
        }),
      );
      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OTPScreen(email: email)),
        );
      } else {
        //print(response.statusCode);
        final Map<String, dynamic> responseData = json.decode(response.body);
        final errorMessage = responseData['message'] ?? 'Erreur inconnue';
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "L'email soumis n'existe pas",
              textAlign: TextAlign.center, 
            ),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      //print('Error occurred: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Une erreur est survenue lors de la demande de réinitialisation du mot de passe.',
            textAlign: TextAlign.center, 
          ),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
    finally {
      setState(() {
        _isLoading = false; 
      });
    }
  }
}

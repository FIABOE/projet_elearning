import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:education/screen/authentification/change_password.dart';
import 'package:education/utils/constances.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class OTPScreen extends StatefulWidget {
    final String email;
  
  const OTPScreen({super.key,required this.email});
  
  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  List<TextEditingController> controllers = List.generate(4, (index) => TextEditingController());
  int _counter = 60*5; // Définir la durée du compte à rebours en secondes
  late Timer _timer;
  bool _buttonEnabled = false;
  bool _resendOtpLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }
  void _startTimer() {
    const oneSecond = Duration(seconds: 1);
    _timer = Timer.periodic(oneSecond, (timer) {
      if (_counter > 0) {
        setState(() {
          _counter--;
        });
      } else {
        _timer.cancel(); // Arrêter le compteur à la fin
        setState(() {
          _buttonEnabled = true; // Activer le bouton à la fin du compteur
        });
      }
    });
  }
  void _resetTimer() {
    _timer.cancel();
    setState(() {
      _counter = 10; // Réinitialiser le compteur
      _buttonEnabled = false; // Désactiver le bouton au début du compteur
    });
    _startTimer(); // Redémarrer le compteur
  }
  @override
  void dispose() {
    _timer.cancel(); // Annuler le compteur à la fermeture de l'écran
    super.dispose();
  }

  void  _resendOtpCode() async{
      await EasyLoading.show(
    status: 'veuillez patientez...',
    maskType: EasyLoadingMaskType.black,
  );
    try {
      setState(() {
        _resendOtpLoading = true; 
      });
      final response = await http.post(
        Uri.parse('$BASE_URL/$RESENDPASSWORD_PATH'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email':widget.email,
        }), 
      );
      //print(response.statusCode);
     //print(jsonDecode(response.body));
     setState(() {
        _resendOtpLoading = false; 
      });
      // Exemple de délai simulé pour les besoins de démonstration
      await Future.delayed(const Duration(seconds: 2));
      // Masquer l'indicateur de chargement
      EasyLoading.dismiss();
      if(response.statusCode == 200){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Center(
              child: Text(
                "Code Envoyé",
                textAlign: TextAlign.center,
              ),
            ),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.green,
          ),
        );
      }
      else if(response.statusCode == 404){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Center(
              child: Text(
                "Votre compte n'existe pas",
                textAlign: TextAlign.center,
              ),
            ),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
      else if (response.statusCode == 500) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final errorMessage = responseData['message'] ?? 'Erreur inconnue';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur: $errorMessage"),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    catch(e){
      print(e);
      setState(() {
        _resendOtpLoading = false; 
      });
      EasyLoading.dismiss();
    }
  }
  void _verifyOtp() async {
    String otpCode = controllers.fold('', (prev, controller) => prev + controller.text);
      await EasyLoading.show(
    status: 'veuillez patientez...',
    maskType: EasyLoadingMaskType.black,
  );
    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/$VERIFYPASSWORD_PATH'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email':widget.email,
          'otp': otpCode
        }),
      );
        // Exemple de délai simulé pour les besoins de démonstration
      await Future.delayed(const Duration(seconds: 2));
      // Masquer l'indicateur de chargement
      EasyLoading.dismiss();
      if (response.statusCode == 200) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChangePasswordScreen(email: widget.email)),
          );
        } else if(response.statusCode == 401) {
        //print(response.statusCode);
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final errorMessage = responseData['message'] ?? 'Erreur inconnue';
        //  print(errorMessage);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Code incorect"),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
      else if(response.statusCode == 402) {
        //print(response.statusCode);
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final errorMessage = responseData['message'] ?? 'Erreur inconnue';
        //print(errorMessage);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Le Code a expire veuillez generer un nouveau code en appuyant sur le bouton 'renvoyer le code' "),
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
        title: const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
           'OTP Validation',
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Entrez le code OTP',
              style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                4,
                (index) => SizedBox(
                  width: 50,
                  child: TextField(
                    controller: controllers[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.length == 1 && index < 3) {
                        FocusScope.of(context).nextFocus();
                      } else if (value.isEmpty && index > 0) {
                        FocusScope.of(context).previousFocus();
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                String otpCode = controllers.fold('', (prev, controller) => prev + controller.text);
                _verifyOtp();
                //print('Code OTP entré : $otpCode');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Valider',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 30),
            Text.rich(
              TextSpan(
                text: 'Nous vous avons envoyé un code de 4 chiffres sur l\'adresse : ',
                style: const TextStyle(fontSize: 16),
                children: <TextSpan>[
                  TextSpan(
                    text: widget.email,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 45),
            ElevatedButton(
              onPressed: _buttonEnabled
              ? () {
                _resetTimer();
                _resendOtpCode();
              }
              : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _buttonEnabled ? Colors.teal : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Renvoyer le code',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Temps restant : $_counter secondes',
              style: const TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
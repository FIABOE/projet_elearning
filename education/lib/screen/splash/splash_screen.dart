// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

import '../omboard/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  final String?
      routeName; // Utilisez "final"  pour déclarer la variable

  const SplashScreen({super.key, this.routeName}); 
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    var d = const Duration(seconds: 3);
    Future.delayed(d, () {
      Navigator.pushReplacementNamed(context, '/OnboardingScreen');
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/girl3.jpg'),
            //girl
            fit: BoxFit.cover,
          ),
        ),
        child: const Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Tolearnio',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Solutions mobiles pour l\'apprentissage universel',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

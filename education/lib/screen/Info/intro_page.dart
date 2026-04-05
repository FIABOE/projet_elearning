// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import '../omboard/onboarding_screen.dart';
import 'package:education/screen/Info/filière_page.dart';


class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {

  void showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Déconnexion',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Êtes-vous sûr de vouloir vous déconnecter ?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      //Navigator.of(context).pop();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ), backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10), 
                    ),
                    child: const Text(
                      'Se déconnecter',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ), backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10), 
                    ),
                    child: const Text(
                      'Annuler',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF70A19F),
        leading: GestureDetector(
          onTap: () {
            showLogoutConfirmationDialog();
          },
          child: Container(
            margin: const EdgeInsets.all(10.0),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: CustomPaint(
              size: const Size(24, 24),
              painter: CrossPainter(
                color: const Color(0xFF70A19F),
                strokeWidth: 2.0,
              ),
            ),
          ),
        ),
        title: const Text(
          'Tolearnio',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 80),
            const Text(
              'Afin de t\'offrir un contenu adapté à tes besoins, nous avons besoin de quelques informations supplémentaires. Ne vous t\'inquiètez pas, cela ne prendra pas beaucoup de temps.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF087B95),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Image.asset(
              'assets/images/fl.png',
              width: 250, 
              height: 250, 
            ),
            const SizedBox(height: 24),
            const Spacer(),
            SizedBox(
              width: 300.0,
              height: 45,
              child: ElevatedButton(
               onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const FilierePage()),
                );
              },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  backgroundColor: const Color(0xFF70A19F),
                ),
                child: const Text(
                  'Continuer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class CrossPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  CrossPainter({
    required this.color,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = size.width / 2;

    canvas.drawCircle(
      Offset(centerX, centerY),
      radius,
      paint,
    );

    canvas.drawLine(
      Offset(centerX - radius / 2, centerY - radius / 2),
      Offset(centerX + radius / 2, centerY + radius / 2),
      paint,
    );
    canvas.drawLine(
      Offset(centerX - radius / 2, centerY + radius / 2),
      Offset(centerX + radius / 2, centerY - radius / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

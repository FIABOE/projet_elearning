import 'dart:async';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController(initialPage: 0);
  int _currentPage = 0;
  Timer? _timer;

  final List<OnboardingItem> _onboardingItems = [
    const OnboardingItem(
      title: 'Etudier en mobilité',
      description:
          'Plateforme d\'instruction virtuelle favorisant \nla réussite et l\'amélioration de vos\nperformances scolaires',
      imagePath: 'assets/images/jaune.jpg',
    ),
    const OnboardingItem(
      title: 'Se tester',
      description:
          'Consolider vos acquis par des quiz et des\ncorrigés. Revoir les cours à travers des\nfichiers et des exercices.',
      imagePath: 'assets/images/af.jpg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _stopAutoScroll();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_currentPage < _onboardingItems.length - 1) {
        _controller.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      } else {
        _controller.jumpToPage(0);
      }
    });
  }

  void _stopAutoScroll() {
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF54737D),
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _onboardingItems.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return OnboardingItemWidget(item: _onboardingItems[index]);
            },
          ),
          Positioned(
            left: 20,
            bottom: 20,
            child: Row(
              children: [
                for (int i = 0; i < _onboardingItems.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: _currentPage == i ? 16 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == i ? Colors.white : Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward, color: Colors.white),
              onPressed: () {
                if (_currentPage != _onboardingItems.length - 1) {
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                }
              },
            ),
          ),
          Positioned(
            left: 50,
            right: 50,
            bottom: 100,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 45,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 7, 94, 134),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register'); // Redirection vers la page d'inscription
                    },
                    child: const Text(
                      "S'inscrire",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 45,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color.fromARGB(255, 13, 152, 177)), // Couleur des contours du bouton
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login'); // Redirection vers la page de connexion
                    },
                    style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all<Color>(Colors.transparent), // Aucune couleur d'overlay lors du tap
                    ),
                    child: const Text(
                      'Se connecter',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white, // Couleur du texte en blanc
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final String imagePath;

  const OnboardingItem({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}

class OnboardingItemWidget extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth,
      padding: const EdgeInsets.only(bottom: 40),
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: Image.asset(
                item.imagePath,
                width: double.infinity,
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FittedBox( // Utilisation de FittedBox pour redimensionner automatiquement le texte
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topCenter,
                  child: Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

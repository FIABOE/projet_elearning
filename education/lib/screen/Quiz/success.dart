import 'package:flutter/material.dart';
import 'package:education/screen/Homepage/accueil_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:education/utils/constances.dart';

class SuccessPage extends StatefulWidget {
  final int second;
  final int totalScore;
  final double averageScore;
  final String niveau;
  final int nombreQuestionsRepondues;
  final int nombreQuestionsReussies;
  final int nombreQuestionsEchouees;

  const SuccessPage({
    super.key,
    required this.second,
    required this.totalScore,
    required this.averageScore,
    required this.niveau,
    required this.nombreQuestionsRepondues,
    required this.nombreQuestionsReussies,
    required this.nombreQuestionsEchouees,
  });

  @override
  _SuccessPageState createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {

  String getFelicitationMessage() {
    if (widget.averageScore >= 18.0) {
      return "Excellent travail! Vous êtes brillant!";
    } else if (widget.averageScore >= 15.0) {
      return "Félicitations! Continuez ainsi!";
    } else if (widget.averageScore >= 12.0) {
      return "Bien joué! Vous progressez!";
    } else if (widget.averageScore >= 10.0) {
      return "Pas mal! Continuez à vous améliorer!";
    } else {
      return "Continuez à travailler dur! Vous pouvez le faire!";
    }
  }

 @override
 Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: const Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Text(
          'Résultats',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      centerTitle: true,
      backgroundColor: const Color(0xFF70A19F),
    ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.star,
              color: Colors.amber,
              size: 48,
            ),
            const SizedBox(height: 20),
            const Text(
              'Votre Score',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Text(
              '${widget.totalScore} / ${widget.nombreQuestionsRepondues * 4}',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Moyenne Générale',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF161818),
              ),
            ),
            Text(
              '${widget.averageScore.toStringAsFixed(2)} /20',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFFDBAE74),
              ),
            ),
            const SizedBox(height: 20),
             Text(
              'Sur ${widget.nombreQuestionsRepondues} questions, vous avez commis ${widget.nombreQuestionsEchouees} fautes et réussi à ${widget.nombreQuestionsReussies} questions',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9422E6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2), // Fond vert avec opacité
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  getFelicitationMessage(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Colors.green, 
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
              onPressed: () async {
                String? userToken;
                final prefs = await SharedPreferences.getInstance();
                userToken = prefs.getString('userToken');
                const String apiUrl = '$BASE_URL/$Save_Question_PATH';

                final Map<String, dynamic> formData = {
                  'niveau': widget.niveau,
                  'total_score': widget.totalScore.toString(),
                  'nombre_questions_repondues': widget.nombreQuestionsRepondues.toString(),
                  'nombre_questions_reussies': widget.nombreQuestionsReussies.toString(),
                  'nombre_questions_echouees': widget.nombreQuestionsEchouees.toString(),
                  'moyenne_generale': widget.averageScore.toString(),
                  'temps_passe': widget.second.toString(),
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
                  //print(response.statusCode);
                } catch (e) {
                  print(e);
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AccueilPage(averageScore: widget.averageScore),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

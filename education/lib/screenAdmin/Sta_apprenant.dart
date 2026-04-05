import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:education/utils/constances.dart';
import 'package:education/screenAdmin/adAccueil_page.dart';


class StaApprenant extends StatefulWidget {
   final int apprenantId;
  const StaApprenant({super.key , required this.apprenantId});

  @override
  _StaApprenantState createState() => _StaApprenantState();
}

class _StaApprenantState extends State<StaApprenant> {
 List<Map<String, dynamic>> averageData = [];
  List<double> globalValues = [];
  String? userToken;
  bool loadingGlobalData = false;
  bool loadingNiveauData = false;


  @override
  void initState() {
    super.initState();
    fetchNiveauData();
    fetchGlobalData();
  }

   //Récupération du token
   Future<void> _getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
    //print('Token d\'authentification récupéré depuis les préférences : $userToken');
  }

  // Fonction pour récupérer les données globales depuis l'API
  Future<void> fetchGlobalData() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
  try {
    //print('Apprenant ID: ${widget.apprenantId}'); // Ajout de la déclaration print ici
     setState(() {
      loadingGlobalData = true; // Ajout d'un indicateur de chargement
    });

    final response = await http.get(Uri.parse('$BASE_URL/api/get-global_Moyenne/apprenants/${widget.apprenantId}'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      // Assurez-vous que les valeurs ne sont pas nulles avant de les affecter
      double faible = double.parse(responseData['faible'] ?? '0.0');
      double forte = double.parse(responseData['forte'] ?? '0.0');


      // Ajouter des déclarations print pour le débogage
      //print('Valeurs globales récupérées avec succès: $globalValues');
      //print('Type de faible: ${faible.runtimeType}');
      //print('Type de forte: ${forte.runtimeType}');

      setState(() {
        globalValues = [faible, forte];
        loadingGlobalData = false;
      });
    } else {
      throw Exception('Erreur lors de la récupération des données globales');
    }
  } catch (error) {
    print('Erreur lors de la récupération des données globales: $error');
    setState(() {
      loadingGlobalData = false; // Désactivez l'indicateur de chargement en cas d'erreur
    });
  }
}


  // Fonction pour récupérer les données par niveau depuis l'API
  Future<void> fetchNiveauData() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
  try {
    print('Apprenant ID: ${widget.apprenantId}'); // Ajout de la déclaration print ici
    setState(() {
      loadingNiveauData = true; // Ajout d'un indicateur de chargement
    });

    final response = await http.get(Uri.parse('$BASE_URL/api/get-Niv_Moyenne/apprenants/${widget.apprenantId}'));

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);

       // Tri des données par niveau
        responseData.sort((a, b) => a['niveau'].compareTo(b['niveau']));

      setState(() {
        averageData = List<Map<String, dynamic>>.from(responseData);
       loadingNiveauData = false;
      });

      // Ajouter des déclarations print pour le débogage
      print('Données par niveau récupérées avec succès: $averageData');
    } else {
      throw Exception('Erreur lors de la récupération des données par niveau');
    }
  } catch (error) {
    print('Erreur lors de la récupération des données par niveau: $error');
    setState(() {
      loadingNiveauData = false; // Désactivez l'indicateur de chargement en cas d'erreur
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Moyenne',
        style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold, 
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF70A19F),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Moyenne par Niveau',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildAverageList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Moyenne globale',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        //color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildAverageChart(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildAverageList() {
  if (loadingNiveauData) {
    return const CircularProgressIndicator();
  } else {
    if (averageData.isEmpty) {
      return const Text(
        'Aucune donnée disponible pour l\'utilisateur.',
        style: TextStyle(fontSize: 18, color: Colors.red), 
      );
    } else {
      return Column(
        children: averageData.map((data) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${data['niveau']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC65606),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Faible: ', style: TextStyle(fontSize: 18, color: Colors.black)),
                  Text(
                    '${data['faible']}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFFF01111),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text('Forte: ', style: TextStyle(fontSize: 18, color: Colors.black)),
                  Text(
                    '${data['forte']}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF599D9A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          );
        }).toList(),
      );
    }
  }
}


Widget _buildAverageChart() {
  if (loadingGlobalData) {
    return const CircularProgressIndicator();
  } else {
    final List<double> averageValues = globalValues.isEmpty ? [0.0, 0.0] : globalValues;

    if (averageValues.every((value) => value == 0.0)) {
      return const Text(
        'Aucune donnée disponible pour l\'utilisateur.',
        style: TextStyle(fontSize: 18, color: Colors.red),
      );
    } else {
      return SizedBox(
        height: 200,
        child: Column(
          children: [
            Expanded(
              child: PieChart(
                PieChartData(
                  borderData: FlBorderData(
                    show: false,
                  ),
                  sectionsSpace: 0,
                  centerSpaceRadius: 30,
                  sections: _buildPieChartSections(averageValues),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LegendItem(color: Color(0xFF70A19F), label: 'Faible'),
                SizedBox(width: 16),
                LegendItem(color: Color(0xFFF28435), label: 'Forte'),
              ],
            ),
          ],
        ),
      );
    }
  }
}

  List<PieChartSectionData> _buildPieChartSections(List<double> values) {
    return List.generate(
      values.length,
      (index) {
        const double fontSize = 16;
        const double radius = 60;
        Color textColor;

        if (index.isEven) {
          textColor = const Color(0xFFF7F4F4);
        } else {
          textColor = const Color(0xFFFFFFFF);
        }

        return PieChartSectionData(
          color: index.isEven ? const Color(0xFF70A19F) : const Color(0xFFF28435),
          value: values[index],
          title: '${values[index]}%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        );
      },
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const LegendItem({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}




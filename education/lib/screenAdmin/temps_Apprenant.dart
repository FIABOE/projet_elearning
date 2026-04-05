import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:education/utils/constances.dart';
import 'dart:math';

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const LegendItem({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}

class TempsApprenant extends StatefulWidget {
  final int apprenantId;

  const TempsApprenant({super.key, required this.apprenantId});

  @override
  _TempsApprenantState createState() => _TempsApprenantState();
}

class _TempsApprenantState extends State<TempsApprenant> {
  List<Map<String, dynamic>> timeSpentData = [];
  String? userToken;
  bool loadingTimeSpentData = false;

  @override
  void initState() {
    super.initState();
    fetchTimeSpentData();
  }

  Future<void> _getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
  }

 Future<void> fetchTimeSpentData() async {
  final prefs = await SharedPreferences.getInstance();
  userToken = prefs.getString('userToken');
  try {
    setState(() {
      loadingTimeSpentData = true;
    });

    final response = await http.get(
      Uri.parse('$BASE_URL/api/quiz/time-spent/apprenants/${widget.apprenantId}')
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);

      setState(() {
        timeSpentData = List<Map<String, dynamic>>.from(responseData.map((data) {
          return {
            'niveau': data['niveau'],  // Ajoutez cette ligne pour inclure le niveau
            'temps_passe': data['temps_passe'] is int
                ? (data['temps_passe'] as int).toDouble()
                : data['temps_passe'],
          };
        }).toList());
        loadingTimeSpentData = false;
      });
    } else {
      throw Exception('Erreur lors de la récupération des données par niveau');
    }
  } catch (error) {
    print('Erreur lors de la récupération des données par niveau: $error');
    setState(() {
      loadingTimeSpentData = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Temps passé par Niveau',
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
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Temps passé par Niveau',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTimeSpentChart(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSpentChart() {
  if (loadingTimeSpentData) {
    return const CircularProgressIndicator();
  } else {
    final List<double> timeSpentValues =
        timeSpentData.map((data) => data['temps_passe'] as double).toList();

    final List<String> niveaux =
        timeSpentData.map((data) => data['niveau'].toString().toLowerCase()).toList();

    if (timeSpentValues.isEmpty) {
      return const Text(
        'Aucune donnée disponible pour l\'utilisateur.',
        style: TextStyle(fontSize: 18, color: Colors.red),
      );
    } else {
      return SizedBox(
        height: 300,
        child: PieChart(
          PieChartData(
            sectionsSpace: 0,
            centerSpaceRadius: 30,
            sections: _buildPieChartSections(timeSpentValues, niveaux),
          ),
        ),
      );
    }
  }
}

List<PieChartSectionData> _buildPieChartSections(List<double> values, List<String> niveaux) {
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
        color: _generateRandomColor(),
        value: values[index],
        title: '${values[index]}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        badgeWidget: _buildBadgeWidget(niveaux[index], textColor),
        badgePositionPercentageOffset: .98,
      );
    },
  );
}

Widget _buildBadgeWidget(String label, Color color) {
  return Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.black, // Noir
      ),
    ),
  );
}



  Color _generateRandomColor() {
    return Color.fromRGBO(
      Random().nextInt(256),
      Random().nextInt(256),
      Random().nextInt(256),
      1,
    );
  }
}

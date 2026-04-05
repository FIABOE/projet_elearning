import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StaApprenant extends StatefulWidget {
   final int apprenantId;
  const StaApprenant({super.key , required this.apprenantId});

  @override
  _StaApprenantState createState() => _StaApprenantState();
}

class _StaApprenantState extends State<StaApprenant> {
 List<Map<String, dynamic>> averageData = [];
  List<double> globalValues = [];

  @override
  void initState() {
    super.initState();
    fetchNiveauData();
    fetchGlobalData();
  }

  // Fonction pour récupérer les données globales depuis l'API
  Future<void> fetchGlobalData() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.10.229:8000/api/get-global_Moyenne/apprenants/${widget.apprenantId}'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        setState(() {
          globalValues = [responseData['faible'], responseData['forte']];
        });
      } else {
        throw Exception('Erreur lors de la récupération des données globales');
      }
    } catch (error) {
      print('Erreur: $error');
    }
  }

  // Fonction pour récupérer les données par niveau depuis l'API
  Future<void> fetchNiveauData() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.10.229:8000/api/get-Niv_Moyenne/apprenants/${widget.apprenantId}'));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        
        setState(() {
          averageData = List<Map<String, dynamic>>.from(responseData);
        });
      } else {
        throw Exception('Erreur lors de la récupération des données par niveau');
      }
    } catch (error) {
      print('Erreur: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Statistiques des Apprenants',
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
                      'Moyennes par Niveau',
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
                      'Moyennes global',
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

  Widget _buildAverageChart() {
    final List<double> averageValues = globalValues.isEmpty ? [0.0, 0.0] : globalValues;

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
              LegendItem(color: Color(0xFF70A19F), label: 'Forte'),
              SizedBox(width: 16),
              LegendItem(color: Color(0xFFF28435), label: 'Faible'),
            ],
          ),
        ],
      ),
    );
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




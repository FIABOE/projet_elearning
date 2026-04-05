import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CercleStatisticsPage extends StatefulWidget {
  const CercleStatisticsPage({super.key});

  @override
  _CercleStatisticsPageState createState() => _CercleStatisticsPageState();
}

class _CercleStatisticsPageState extends State<CercleStatisticsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
             'Cercle Statistics',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          color: const Color(0xFF70A19F),
                          value: 20, // Remplacez par la valeur réelle de la première section
                          title: 'Section 1', // Légende de la première section
                          radius: 50, // Rayon de la section
                        ),
                        PieChartSectionData(
                          color: const Color(0xFFB2DB87),
                          value: 30, // Remplacez par la valeur réelle de la deuxième section
                          title: 'Section 2', // Légende de la deuxième section
                          radius: 50, // Rayon de la section
                        ),
                        PieChartSectionData(
                          color: const Color(0xFFA48EA0),
                          value: 15, // Remplacez par la valeur réelle de la troisième section
                          title: 'Section 3', // Légende de la troisième section
                          radius: 50, // Rayon de la section
                        ),
                        PieChartSectionData(
                          color: const Color(0xFFC4C4C4),
                          value: 10, // Remplacez par la valeur réelle de la quatrième section
                          title: 'Section 4', // Légende de la quatrième section
                          radius: 50, // Rayon de la section
                        ),
                        PieChartSectionData(
                          color: const Color(0xFFE6D9B9),
                          value: 25, // Remplacez par la valeur réelle de la cinquième section
                          title: 'Section 5', // Légende de la cinquième section
                          radius: 50, // Rayon de la section
                        ),
                        // Add more sections here...
                      ],
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 0,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LegendItem(color: Color(0xFF70A19F), label: 'Section 1'),
                  // Add more legend items here...
                ],
              ),
            ],
          ),
        ),
      ),
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
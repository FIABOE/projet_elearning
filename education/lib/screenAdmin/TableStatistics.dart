import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TableStatisticsPage extends StatefulWidget {
  const TableStatisticsPage({super.key});

  @override
  _TableStatisticsPageState createState() => _TableStatisticsPageState();
}

class _TableStatisticsPageState extends State<TableStatisticsPage> {
   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Taux de Croissance des Utilisateurs'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Taux de Croissance des Utilisateurs au Fil du Temps',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DataTable(
              columns: const [
                DataColumn(label: Text('Mois')),
                DataColumn(label: Text('Taux de Croissance')),
              ],
              rows: const [
                DataRow(cells: [
                  DataCell(Text('Janvier')),
                  DataCell(Text('30%')),  // Remplacez par le taux réel
                ]),
                DataRow(cells: [
                  DataCell(Text('Février')),
                  DataCell(Text('25%')),  // Remplacez par le taux réel
                ]),
                DataRow(cells: [
                  DataCell(Text('Mars')),
                  DataCell(Text('40%')),  // Remplacez par le taux réel
                ]),
                // Ajoutez d'autres lignes pour chaque mois
              ],
            ),
          ],
        ),
      ),
    );
  }
}
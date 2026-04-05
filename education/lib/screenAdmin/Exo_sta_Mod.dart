import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:education/utils/constances.dart';
import 'package:education/screenAdmin/adAccueil_page.dart';
import 'package:education/screen/ScreenMod%C3%A9rateur/accueilMod%C3%A9rateur.dart';

class Exo_ModStatisticsPage extends StatefulWidget {
  const Exo_ModStatisticsPage({super.key});

  @override
  _Exo_ModStatisticsPageState createState() => _Exo_ModStatisticsPageState();
}

class _Exo_ModStatisticsPageState extends State<Exo_ModStatisticsPage> {
  late List<UserData> chartData;

  @override
  void initState() {
    super.initState();
    fetchDataAndSetState(ApiManager.fetchExercicesCountByDay);
  }

  void fetchDataAndSetState(Future<List<UserData>> Function() fetchDataFunction) async {
    List<UserData> data = await fetchDataFunction();
    setState(() {
      chartData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Statistiques d\'exercice',
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AccueilMod()),
            );
          },
        ),
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              indicatorColor: Colors.blue, // Couleur de l'indicateur de l'onglet sélectionné
              tabs: const [
                Tab(text: 'Par Jour'),
                Tab(text: 'Par Semaine'),
                Tab(text: 'Par Mois'),
              ],
              onTap: (index) {
                if (index == 0) {
                  fetchDataAndSetState(ApiManager.fetchExercicesCountByDay);
                } else if (index == 1) {
                  fetchDataAndSetState(ApiManager.fetchExercicesCountByWeek);
                } else if (index == 2) {
                  fetchDataAndSetState(ApiManager.fetchExercicesCountByMonth);
                }
              },
            ),
            Expanded(
              child: TabBarView(
                children: [
                  buildChart('Jour', ApiManager.fetchExercicesCountByDay, 'Nombre d\'ajout par jour'),
                  buildChart('Semaine', ApiManager.fetchExercicesCountByWeek, 'Nombre d\'ajout par semaine'),
                  buildChart('Mois', ApiManager.fetchExercicesCountByMonth, 'Nombre d\'ajout par mois'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildChart(String timePeriod, Future<List<UserData>> Function() fetchDataFunction, String title) {
    return FutureBuilder<List<UserData>>(
      future: fetchDataFunction(),
      builder: (context, snapshot) {
        print('Snapshot data for $timePeriod: ${snapshot.data}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.blue, // Couleur du cercle de chargement
            ),
          );
        } else if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Erreur de chargement des données depuis l\'API',
              style: TextStyle(
                color: Colors.red, // Couleur du texte d'erreur
              ),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'Aucune donnée disponible',
              style: TextStyle(
                color: Colors.grey, // Couleur du texte informatif
              ),
            ),
          );
        } else {
          List<UserData> data = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre au-dessus du graphique
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                // Libellé horizontal en haut à gauche
                const Text(
                  'Nombre',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                // Graphique
                SfCartesianChart(
                  plotAreaBorderWidth: 0,
                  primaryXAxis: CategoryAxis(
                    labelRotation: 45,
                    majorGridLines: const MajorGridLines(width: 0),
                    majorTickLines: const MajorTickLines(size: 0),
                  ),
                  primaryYAxis: NumericAxis(
                    majorGridLines: const MajorGridLines(width: 0),
                    majorTickLines: const MajorTickLines(size: 0),
                  ),
                  series: <ChartSeries<UserData, String>>[
                    ColumnSeries<UserData, String>(
                      color: const Color(0xFF70A19F), // Couleur de la colonne
                      dataSource: data,
                      xValueMapper: (UserData userData, _) => userData.timePeriod.toString(),
                      yValueMapper: (UserData userData, _) => userData.value,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Libellé horizontal en bas
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Date',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

class ApiManager {
  static Future<List<UserData>> fetchExercicesCountByDay() async {
    return _fetchData('exercice-stats');
  }

  static Future<List<UserData>> fetchExercicesCountByWeek() async {
    return _fetchData('exercice-week');
  }

  static Future<List<UserData>> fetchExercicesCountByMonth() async {
    return _fetchData('exercice-month');
  }

  static Future<List<UserData>> _fetchData(String endpoint) async {
    String apiUrl = '$BASE_URL/api/$endpoint';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);

      print('Data for $endpoint: $jsonData');

      return jsonData.map((data) => UserData.fromJson(data)).toList();
    } else {
      print('Erreur de l\'API pour $endpoint: ${response.statusCode}');
      throw Exception('Erreur lors de la récupération des données depuis l\'API');
    }
  }
}

class UserData {
  final dynamic timePeriod;
  final int value;

  UserData(this.timePeriod, this.value);

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      _formatDate(json['day'] ?? json['week'] ?? json['month']),
      json['exercice_count'] ?? json['count'],
    );
  }

  static String _formatDate(dynamic date) {
    if (date is int) {
      // Si la date est un entier, supposons qu'il s'agit d'une semaine
      return '$date';
    } else {
      final DateTime dateTime = DateTime.parse(date);
      return '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year.toString().substring(2)}';
    }
  }
}

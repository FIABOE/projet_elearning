import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:education/utils/constances.dart';
import 'package:education/screenAdmin/adAccueil_page.dart';

class QuizStatisticsPage extends StatefulWidget {
  const QuizStatisticsPage({super.key});

  @override
  _QuizStatisticsPageState createState() => _QuizStatisticsPageState();
}

class _QuizStatisticsPageState extends State<QuizStatisticsPage> {
  late List<UserData> chartData;

  @override
  void initState() {
    super.initState();
    fetchDataAndSetState(ApiManager.fetchQuizCountByDay);
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
          'Statistiques des Quiz',
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
              MaterialPageRoute(builder: (context) => const AdAccueilPage()),
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
                  fetchDataAndSetState(ApiManager.fetchQuizCountByDay);
                } else if (index == 1) {
                  fetchDataAndSetState(ApiManager.fetchQuizCountByWeek);
                } else if (index == 2) {
                  fetchDataAndSetState(ApiManager.fetchQuizCountByMonth);
                }
              },
            ),
            Expanded(
              child: TabBarView(
                children: [
                  buildChart('Jour', ApiManager.fetchQuizCountByDay, 'Nombre d\'ajout par jour'),
                  buildChart('Semaine', ApiManager.fetchQuizCountByWeek, 'Nombre d\'ajout par semaine'),
                  buildChart('Mois', ApiManager.fetchQuizCountByMonth, 'Nombre d\'ajout par mois'),
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
                    SplineSeries<UserData, String>(
                      color: const Color(0xFF70A19F), // Couleur de la courbe
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
  static Future<List<UserData>> fetchQuizCountByDay() async {
    return _fetchData('quiz-stats');
  }

  static Future<List<UserData>> fetchQuizCountByWeek() async {
    return _fetchData('quiz-week');
  }

  static Future<List<UserData>> fetchQuizCountByMonth() async {
    return _fetchData('quiz-month');
  }

  static Future<List<UserData>> _fetchData(String endpoint) async {
    String apiUrl = '$BASE_URL/api/$endpoint';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);

      return jsonData.map((data) => UserData.fromJson(data)).toList();
    } else {
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
      json['quiz_count'] ?? json['count'],
    );
  }

  static String _formatDate(dynamic date) {
    if (date is int) {
      return '$date';
    } else {
      final DateTime dateTime = DateTime.parse(date);
      return '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year.toString().substring(2)}';
    }
  }
}

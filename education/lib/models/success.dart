import 'package:flutter/material.dart';

class SuccessPage extends StatefulWidget {
  final int second;
  final int totalScore;
  final double averageScore;
  final String niveau;
  final int nombreQuestionsRepondues;

  const SuccessPage({
    super.key,
    required this.second,
    required this.totalScore,
    required this.averageScore,
    required this.niveau,
    required this.nombreQuestionsRepondues,
  });
  @override
  _SuccessPageState createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
}
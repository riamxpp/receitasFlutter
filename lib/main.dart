// lib/main.dart
import 'package:flutter/material.dart';
import 'package:receitas/pages/home_page.dart';
// import 'package:receitas/pages/random_meal.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Receitas',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(), // Define a HomePage como a tela inicial
    );
  }
}
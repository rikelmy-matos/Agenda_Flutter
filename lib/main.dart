import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda de Contatos',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Roboto'),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 4,
          backgroundColor: Colors.deepPurple,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.deepPurple,
        ),
      ),
      home: const MyHomePage(title: 'Agenda de Contatos'),
    );
  }
}

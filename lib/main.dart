import 'package:flutter/material.dart';
import 'package:textsummarizer/screens/homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Short-out',
      darkTheme: ThemeData(
        primaryColor: Colors.amber,
        buttonTheme: const ButtonThemeData(buttonColor: Colors.amber),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.dark,
      home: const HomePage(),
    );
  }
}

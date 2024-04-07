import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Tetris",
      themeMode: ThemeMode.dark,
      home: Scaffold(
      ),
    );
  }
}

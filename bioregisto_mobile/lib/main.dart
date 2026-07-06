import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/observations/new_observation_screen.dart';

void main() {
  runApp(const BioRegistoApp());
}

class BioRegistoApp extends StatelessWidget {
  const BioRegistoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BioRegisto',
      home: const HomeScreen(),
    );
  }
}
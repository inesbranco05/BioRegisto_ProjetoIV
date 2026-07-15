import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'services/api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hasSession =
      await ApiService.restoreSession();

  runApp(
    BioRegistoApp(
      hasSession: hasSession,
    ),
  );
}

class BioRegistoApp extends StatelessWidget {
  final bool hasSession;

  const BioRegistoApp({
    super.key,
    required this.hasSession,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BioRegisto',

      home: hasSession
          ? const HomeScreen()
          : const LoginScreen(),
    );
  }
}
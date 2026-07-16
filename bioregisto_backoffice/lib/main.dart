import 'package:flutter/material.dart';
import 'utils/app_colors.dart';
import 'screens/auth/login_screen.dart';

void main() {
  runApp(
    const BioRegistoBackoffice(),
  );
}

class BioRegistoBackoffice
    extends StatelessWidget {
  const BioRegistoBackoffice({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return MaterialApp(
  debugShowCheckedModeBanner: false,
  title: 'BioRegisto Backoffice',

  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
    ),

    elevatedButtonTheme:
        ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            AppColors.primary,
        foregroundColor:
            Colors.white,
      ),
    ),

    progressIndicatorTheme:
        ProgressIndicatorThemeData(
      color: AppColors.primary,
    ),

    inputDecorationTheme:
        InputDecorationTheme(
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),
    ),
  ),

      home:
          const LoginScreen(),
    );
  }
}
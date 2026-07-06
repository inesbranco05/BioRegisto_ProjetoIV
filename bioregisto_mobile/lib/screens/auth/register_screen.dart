import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Voltar',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        iconTheme:
            const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 60,
                ),

                const SizedBox(width: 12),

                const Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BioRegisto',
                      style: TextStyle(
                        fontSize: 28,
                      ),
                    ),
                    Text(
                      'CMIA Viana do Castelo',
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              'Crie a sua conta',
              style: TextStyle(
                fontSize: 20,
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              decoration: InputDecoration(
                labelText: 'Nome completo',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Palavra-passe',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText:
                    'Confirmar palavra-passe',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Row(
              children: [
                Checkbox(
                  value: false,
                  onChanged: null,
                ),
                Expanded(
                  child: Text(
                    'Concordo com os termos e condições e política de privacidade',
                  ),
                )
              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Criar conta',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
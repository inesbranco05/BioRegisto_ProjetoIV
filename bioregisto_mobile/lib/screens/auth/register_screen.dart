import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {
  final _nameController =
      TextEditingController();

  final _emailController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  final _confirmPasswordController =
      TextEditingController();

  bool _acceptedTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> _register() async {
    final name =
        _nameController.text.trim();

    final email =
        _emailController.text.trim();

    final password =
        _passwordController.text;

    final confirmPassword =
        _confirmPasswordController.text;

    // Validar campos vazios
    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessage(
        'Por favor, preencha todos os campos.',
      );

      return;
    }

    // Validar passwords
    if (password != confirmPassword) {
      _showMessage(
        'As palavras-passe não coincidem.',
      );

      return;
    }

    // Validação básica da password
    if (password.length < 6) {
      _showMessage(
        'A palavra-passe deve ter pelo menos 6 caracteres.',
      );

      return;
    }

    // Validar termos
    if (!_acceptedTerms) {
      _showMessage(
        'Deve aceitar os termos e condições.',
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    final error =
        await ApiService.registerUser(
      name: name,
      email: email,
      password: password,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (error == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Conta criada com sucesso! Já pode iniciar sessão.',
          ),
        ),
      );

      // Voltar para o ecrã de login
      Navigator.pop(context);
    } else {
      _showMessage(error);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,

      appBar: AppBar(
        backgroundColor:
            AppColors.background,

        elevation: 0,

        title: const Text(
          'Voltar',

          style: TextStyle(
            color: Colors.black,
          ),
        ),

        iconTheme:
            const IconThemeData(
          color: Colors.black,
        ),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(24),

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

            // NOME
            TextField(
              controller:
                  _nameController,

              enabled: !_isLoading,

              decoration: InputDecoration(
                labelText:
                    'Nome completo',

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // EMAIL
            TextField(
              controller:
                  _emailController,

              enabled: !_isLoading,

              keyboardType:
                  TextInputType.emailAddress,

              decoration: InputDecoration(
                labelText: 'Email',

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // PASSWORD
            TextField(
              controller:
                  _passwordController,

              enabled: !_isLoading,

              obscureText: true,

              decoration: InputDecoration(
                labelText:
                    'Palavra-passe',

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // CONFIRMAR PASSWORD
            TextField(
              controller:
                  _confirmPasswordController,

              enabled: !_isLoading,

              obscureText: true,

              decoration: InputDecoration(
                labelText:
                    'Confirmar palavra-passe',

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // TERMOS E CONDIÇÕES
            Row(
              children: [
                Checkbox(
                  value:
                      _acceptedTerms,

                  activeColor:
                      AppColors.primary,

                  onChanged: _isLoading
                      ? null
                      : (value) {
                          setState(() {
                            _acceptedTerms =
                                value ??
                                    false;
                          });
                        },
                ),

                const Expanded(
                  child: Text(
                    'Concordo com os termos e condições e política de privacidade',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // BOTÃO CRIAR CONTA
            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : _register,

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.primary,

                  foregroundColor:
                      Colors.white,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                  ),
                ),

                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,

                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color:
                              Colors.white,
                        ),
                      )
                    : const Text(
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
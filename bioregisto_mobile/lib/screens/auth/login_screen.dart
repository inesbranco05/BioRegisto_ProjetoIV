import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../services/api_service.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email =
        _emailController.text.trim();

    final password =
        _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage(
        'Por favor, preencha o email e a palavra-passe.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result =
        await ApiService.loginUser(
      email: email,
      password: password,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const HomeScreen(),
        ),
        (route) => false,
      );
    } else {
      _showMessage(
        result['message'] ??
            'Erro ao iniciar sessão.',
      );
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

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),

          child: Column(
            children: [
              const SizedBox(height: 30),

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
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),

                      Text(
                        'CMIA Viana do Castelo',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 40),

              const Text(
                'Bem-vindo de volta',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 40),

              TextField(
                controller:
                    _emailController,

                enabled: !_isLoading,

                keyboardType:
                    TextInputType.emailAddress,

                decoration: InputDecoration(
                  labelText: 'Email',

                  prefixIcon:
                      const Icon(
                    Icons.email_outlined,
                  ),

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

              TextField(
                controller:
                    _passwordController,

                enabled: !_isLoading,
                obscureText: true,

                onSubmitted: (_) {
                  if (!_isLoading) {
                    _login();
                  }
                },

                decoration: InputDecoration(
                  labelText:
                      'Palavra-passe',

                  prefixIcon:
                      const Icon(
                    Icons.lock_outline,
                  ),

                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Align(
                alignment:
                    Alignment.centerLeft,

                child: TextButton(
                  onPressed: () {},

                  child: const Text(
                    'Esqueceu a palavra-passe?',
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : _login,

                  icon: _isLoading
                      ? const SizedBox.shrink()
                      : const Icon(
                          Icons.login,
                        ),

                  label: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,

                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Entrar',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),

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
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [
                  const Text(
                    'Ainda não tem conta? ',
                  ),

                  GestureDetector(
                    onTap: _isLoading
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const RegisterScreen(),
                              ),
                            );
                          },

                    child: const Text(
                      'Criar conta',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 80),

              const Text(
                'Centro de Monitorização e Interpretação Ambiental',
                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
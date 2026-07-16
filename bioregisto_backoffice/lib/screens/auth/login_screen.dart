import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../utils/app_colors.dart';
import '../validator/validator_dashboard.dart';
import '../admin/admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {
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

    if (email.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Preencha o email e a palavra-passe.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result =
        await ApiService.login(
      email: email,
      password: password,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (!result['success']) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            result['message'],
          ),
        ),
      );

      return;
    }
final role =
    ApiService.currentUser?['role'];

if (role == 'Validator') {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) =>
          const ValidatorDashboard(),
    ),
  );

  return;
}

if (role == 'Admin') {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) =>
          const AdminDashboard(),
    ),
  );

  return;
}

// Qualquer outro papel não pode
// entrar no backoffice.
await ApiService.logout();

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text(
      'Esta conta não tem permissão para aceder ao backoffice.',
    ),
  ),
);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,

      body: Center(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(30),

          child: Container(
            width: 450,

            padding:
                const EdgeInsets.all(40),

            decoration:
                BoxDecoration(
              color: Colors.white,

              borderRadius:
                  BorderRadius.circular(
                24,
              ),

              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(0.08),

                  blurRadius: 30,
                ),
              ],
            ),

            child: Column(
              children: [
                Icon(
                  Icons.eco,

                  size: 60,

                  color:
                      AppColors.primary,
                ),

                const SizedBox(
                  height: 15,
                ),

                const Text(
                  'BioRegisto',

                  style: TextStyle(
                    fontSize: 30,

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const Text(
                  'Backoffice',

                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(
                  height: 40,
                ),

                TextField(
                  controller:
                      _emailController,

                  decoration:
                      InputDecoration(
                    labelText: 'Email',

                    prefixIcon:
                        const Icon(
                      Icons
                          .email_outlined,
                    ),

                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        12,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                TextField(
                  controller:
                      _passwordController,

                  obscureText: true,

                  onSubmitted: (_) {
                    _login();
                  },

                  decoration:
                      InputDecoration(
                    labelText:
                        'Palavra-passe',

                    prefixIcon:
                        const Icon(
                      Icons.lock_outline,
                    ),

                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        12,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 30,
                ),

                SizedBox(
                  width:
                      double.infinity,

                  height: 52,

                  child:
                      ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : _login,

                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          AppColors
                              .primary,

                      foregroundColor:
                          Colors.white,
                    ),

                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,

                            child:
                                CircularProgressIndicator(
                              strokeWidth:
                                  2,

                              color:
                                  Colors
                                      .white,
                            ),
                          )
                        : const Text(
                            'Entrar',

                            style:
                                TextStyle(
                              fontSize:
                                  16,
                            ),
                          ),
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),

                const Text(
                  'Acesso reservado a validadores e administradores',

                  textAlign:
                      TextAlign.center,

                  style: TextStyle(
                    color: Colors.grey,

                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
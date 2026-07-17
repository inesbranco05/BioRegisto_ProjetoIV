import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../utils/app_colors.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen
    extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
  });

  @override
  State<ForgotPasswordScreen>
      createState() =>
          _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final _formKey =
      GlobalKey<FormState>();

  final _emailController =
      TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final email =
        _emailController.text
            .trim();

    final result =
        await ApiService
            .forgotPassword(
      email: email,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result['success'] != true) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ??
                'Não foi possível enviar o código.',
          ),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Código de recuperação enviado.',
        ),
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ResetPasswordScreen(
          email: email,
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(
        0xFFF4F7F3,
      ),

      appBar: AppBar(
        backgroundColor:
            AppColors.primary,

        foregroundColor:
            Colors.white,

        elevation: 0,

        title: const Text(
          'Recuperar palavra-passe',
        ),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(
          25,
        ),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .stretch,

            children: [
              const SizedBox(
                height: 40,
              ),

              Icon(
                Icons.lock_reset,
                size: 80,
                color:
                    AppColors.primary,
              ),

              const SizedBox(
                height: 25,
              ),

              const Text(
                'Esqueceu-se da palavra-passe?',

                textAlign:
                    TextAlign.center,

                style: TextStyle(
                  fontSize: 24,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              Text(
                'Introduza o email associado à sua conta. '
                'Enviaremos um código de recuperação válido durante 15 minutos.',

                textAlign:
                    TextAlign.center,

                style: TextStyle(
                  color:
                      Colors.grey.shade600,

                  height: 1.5,
                ),
              ),

              const SizedBox(
                height: 35,
              ),

              TextFormField(
                controller:
                    _emailController,

                keyboardType:
                    TextInputType
                        .emailAddress,

                decoration:
                    const InputDecoration(
                  labelText: 'Email',

                  hintText:
                      'exemplo@email.com',

                  prefixIcon:
                      Icon(
                    Icons.email_outlined,
                  ),

                  border:
                      OutlineInputBorder(),
                ),

                validator: (
                  value,
                ) {
                  final email =
                      value?.trim() ??
                          '';

                  if (email.isEmpty) {
                    return 'Introduza o seu email.';
                  }

                  if (!email.contains(
                    '@',
                  )) {
                    return 'Introduza um email válido.';
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 25,
              ),

              SizedBox(
                height: 52,

                child:
                    ElevatedButton(
                  onPressed:
                      _isLoading
                          ? null
                          : _sendCode,

                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        AppColors.primary,

                    foregroundColor:
                        Colors.white,
                  ),

                  child:
                      _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,

                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2,

                                color:
                                    Colors.white,
                              ),
                            )
                          : const Text(
                              'Enviar código',

                              style:
                                  TextStyle(
                                fontSize:
                                    16,

                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
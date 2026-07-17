import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../utils/app_colors.dart';

class ResetPasswordScreen
    extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({
    super.key,
    required this.email,
  });

  @override
  State<ResetPasswordScreen>
      createState() =>
          _ResetPasswordScreenState();
}

class _ResetPasswordScreenState
    extends State<ResetPasswordScreen> {
  final _formKey =
      GlobalKey<FormState>();

  final _codeController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  final _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;

  bool _obscurePassword = true;
  bool _obscureConfirmation = true;

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController
        .dispose();

    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result =
        await ApiService
            .resetPassword(
      email: widget.email,

      code:
          _codeController.text
              .trim(),

      newPassword:
          _passwordController.text,
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
                'Não foi possível alterar a palavra-passe.',
          ),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Palavra-passe alterada com sucesso.',
        ),
      ),
    );

    // Volta ao ecrã inicial
    // da autenticação.
    Navigator.of(context)
        .popUntil(
      (route) =>
          route.isFirst,
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

        title: const Text(
          'Nova palavra-passe',
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
                height: 25,
              ),

              Icon(
                Icons
                    .mark_email_read_outlined,

                size: 75,

                color:
                    AppColors.primary,
              ),

              const SizedBox(
                height: 20,
              ),

              const Text(
                'Verifique o seu email',

                textAlign:
                    TextAlign.center,

                style: TextStyle(
                  fontSize: 24,

                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              Text(
                'Introduza o código enviado para ${widget.email}.',

                textAlign:
                    TextAlign.center,

                style: TextStyle(
                  color:
                      Colors.grey.shade600,
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              TextFormField(
                controller:
                    _codeController,

                keyboardType:
                    TextInputType.number,

                maxLength: 6,

                decoration:
                    const InputDecoration(
                  labelText:
                      'Código de recuperação',

                  prefixIcon:
                      Icon(
                    Icons
                        .pin_outlined,
                  ),

                  border:
                      OutlineInputBorder(),

                  counterText: '',
                ),

                validator: (
                  value,
                ) {
                  final code =
                      value?.trim() ??
                          '';

                  if (code.isEmpty) {
                    return 'Introduza o código recebido.';
                  }

                  if (code.length !=
                      6) {
                    return 'O código deve ter 6 dígitos.';
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 20,
              ),

              TextFormField(
                controller:
                    _passwordController,

                obscureText:
                    _obscurePassword,

                decoration:
                    InputDecoration(
                  labelText:
                      'Nova palavra-passe',

                  prefixIcon:
                      const Icon(
                    Icons.lock_outline,
                  ),

                  border:
                      const OutlineInputBorder(),

                  suffixIcon:
                      IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword =
                            !_obscurePassword;
                      });
                    },

                    icon: Icon(
                      _obscurePassword
                          ? Icons
                              .visibility_outlined
                          : Icons
                              .visibility_off_outlined,
                    ),
                  ),
                ),

                validator: (
                  value,
                ) {
                  if (value == null ||
                      value.isEmpty) {
                    return 'Introduza a nova palavra-passe.';
                  }

                  if (value.length < 6) {
                    return 'A palavra-passe deve ter pelo menos 6 caracteres.';
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 20,
              ),

              TextFormField(
                controller:
                    _confirmPasswordController,

                obscureText:
                    _obscureConfirmation,

                decoration:
                    InputDecoration(
                  labelText:
                      'Confirmar palavra-passe',

                  prefixIcon:
                      const Icon(
                    Icons.lock_outline,
                  ),

                  border:
                      const OutlineInputBorder(),

                  suffixIcon:
                      IconButton(
                    onPressed: () {
                      setState(() {
                        _obscureConfirmation =
                            !_obscureConfirmation;
                      });
                    },

                    icon: Icon(
                      _obscureConfirmation
                          ? Icons
                              .visibility_outlined
                          : Icons
                              .visibility_off_outlined,
                    ),
                  ),
                ),

                validator: (
                  value,
                ) {
                  if (value !=
                      _passwordController
                          .text) {
                    return 'As palavras-passe não coincidem.';
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 30,
              ),

              SizedBox(
                height: 52,

                child:
                    ElevatedButton(
                  onPressed:
                      _isLoading
                          ? null
                          : _resetPassword,

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
                              'Alterar palavra-passe',

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
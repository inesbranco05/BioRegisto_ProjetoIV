import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../utils/app_colors.dart';
import '../auth/login_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user =
        ApiService.currentUser;

    final userName =
        user?['name'] ?? 'Administrador';

    return Scaffold(
      backgroundColor: AppColors.background,

      body: Row(
        children: [
          // SIDEBAR
          Container(
            width: 260,
            color: Colors.white,

            padding: const EdgeInsets.symmetric(
              vertical: 30,
              horizontal: 20,
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Row(
                  children: [
                    Icon(
                      Icons.eco,
                      color: AppColors.primary,
                      size: 32,
                    ),

                    const SizedBox(width: 10),

                    const Text(
                      'BioRegisto',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 45),

                _menuItem(
                  Icons.dashboard_outlined,
                  'Dashboard',
                  true,
                ),

                _menuItem(
                  Icons.people_outline,
                  'Utilizadores',
                  false,
                ),

                _menuItem(
                  Icons.eco_outlined,
                  'Espécies',
                  false,
                ),

                _menuItem(
                  Icons.visibility_outlined,
                  'Observações',
                  false,
                ),

                _menuItem(
                  Icons.notifications_outlined,
                  'Notificações',
                  false,
                ),

                _menuItem(
                  Icons.emoji_events_outlined,
                  'Eventos e Desafios',
                  false,
                ),

                const Spacer(),

                _menuItem(
                  Icons.logout,
                  'Terminar sessão',
                  false,

                  onTap: () async {
                    await ApiService.logout();

                    if (!context.mounted) {
                      return;
                    }

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),

          // CONTEÚDO
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(35),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,

                    children: [
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          const Text(
                            'Painel de Administração',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            'Bem-vindo, $userName',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),

                      CircleAvatar(
                        radius: 24,
                        backgroundColor:
                            AppColors.primary,

                        child: Text(
                          userName
                              .toString()
                              .substring(0, 1)
                              .toUpperCase(),

                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  const Text(
                    'Visão geral do sistema',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          Icons.people_outline,
                          'Utilizadores',
                          '—',
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: _statCard(
                          Icons.verified_user_outlined,
                          'Técnicos',
                          '—',
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: _statCard(
                          Icons.visibility_outlined,
                          'Observações',
                          '—',
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: _statCard(
                          Icons.eco_outlined,
                          'Espécies',
                          '—',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 35),

                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.all(25),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(20),
                    ),

                    child: const Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Text(
                          'Atividade do sistema',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 10),

                        Text(
                          'As estatísticas e a atividade recente do sistema serão apresentadas aqui.',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(
    IconData icon,
    String title,
    bool selected, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8,
      ),

      child: ListTile(
        onTap: onTap,

        leading: Icon(
          icon,
          color: selected
              ? AppColors.primary
              : Colors.grey,
        ),

        title: Text(
          title,
          style: TextStyle(
            color: selected
                ? AppColors.primary
                : Colors.black87,

            fontWeight: selected
                ? FontWeight.w600
                : FontWeight.normal,
          ),
        ),

        tileColor: selected
            ? AppColors.primary
                .withOpacity(0.10)
            : Colors.transparent,

        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _statCard(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),

      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
                AppColors.primary
                    .withOpacity(0.10),

            child: Icon(
              icon,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(width: 15),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
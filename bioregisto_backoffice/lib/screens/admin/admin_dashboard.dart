import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../utils/app_colors.dart';
import '../auth/login_screen.dart';
import 'users_management_screen.dart';
import 'species_database_screen.dart';
import 'observations_management_screen.dart';
import 'notifications_management_screen.dart';
import 'events_challenges_management_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({
    super.key,
  });

  @override
  State<AdminDashboard> createState() =>
      _AdminDashboardState();
}

class _AdminDashboardState
    extends State<AdminDashboard> {
  Map<String, dynamic>? _statistics;

  bool _isLoadingStatistics = true;

  @override
  void initState() {
    super.initState();

    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      final statistics =
          await ApiService
              .getAdminStatistics();

      if (!mounted) return;

      setState(() {
        _statistics = statistics;
        _isLoadingStatistics = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoadingStatistics = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível carregar as estatísticas.',
          ),
        ),
      );
    }
  }

  String _statValue(
    dynamic value,
  ) {
    if (_isLoadingStatistics) {
      return '...';
    }

    return value?.toString() ?? '0';
  }

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

  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const UsersManagementScreen(),
      ),
    );
  },
),

               _menuItem(
                  Icons.eco_outlined,
                  'Espécies',
                  false,

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const SpeciesDatabaseScreen(),
                      ),
                    );
                  },
                ),

                _menuItem(
                  Icons.visibility_outlined,
                  'Observações',
                  false,

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const ObservationsManagementScreen(),
                      ),
                    );
                  },
                ),

                _menuItem(
                    Icons.notifications_outlined,
                    'Notificações',
                    false,

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const NotificationsManagementScreen(),
                        ),
                      );
                    },
                  ),

               _menuItem(
                  Icons.emoji_events_outlined,
                  'Eventos e Desafios',
                  false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const EventsChallengesManagementScreen(),
                      ),
                    );
                  },
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
        _statValue(
          _statistics?['users']
              ?['total'],
        ),
      ),
    ),

    const SizedBox(width: 15),

    Expanded(
      child: _statCard(
        Icons.verified_user_outlined,
        'Técnicos',
        _statValue(
          _statistics?['users']
              ?['validators'],
        ),
      ),
    ),

    const SizedBox(width: 15),

    Expanded(
      child: _statCard(
        Icons.visibility_outlined,
        'Observações',
        _statValue(
          _statistics?['observations']
              ?['total'],
        ),
      ),
    ),

    const SizedBox(width: 15),

    Expanded(
      child: _statCard(
        Icons.eco_outlined,
        'Espécies',
        _statValue(
          _statistics?['species'],
        ),
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

  child: Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,

    children: [
      Row(
        mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,

        children: [
          const Text(
            'Atividade do sistema',

            style: TextStyle(
              fontSize: 20,

              fontWeight:
                  FontWeight.bold,
            ),
          ),

          IconButton(
            tooltip: 'Atualizar',

            onPressed:
                _loadStatistics,

            icon: Icon(
              Icons.refresh,

              color:
                  AppColors.primary,
            ),
          ),
        ],
      ),

      const SizedBox(height: 25),

      Wrap(
        spacing: 40,
        runSpacing: 25,

        children: [
          _activityItem(
            'Utilizadores ativos',
            _statValue(
              _statistics?['users']
                  ?['active'],
            ),
          ),

          _activityItem(
            'Observadores',
            _statValue(
              _statistics?['users']
                  ?['observers'],
            ),
          ),

          _activityItem(
            'Pendentes',
            _statValue(
              _statistics?[
                      'observations']
                  ?['pending'],
            ),
          ),

          _activityItem(
            'Aprovadas',
            _statValue(
              _statistics?[
                      'observations']
                  ?['validated'],
            ),
          ),

          _activityItem(
            'Rejeitadas',
            _statValue(
              _statistics?[
                      'observations']
                  ?['rejected'],
            ),
          ),

          _activityItem(
            'Notificações enviadas',
            _statValue(
              _statistics?[
                  'notifications'],
            ),
          ),
        ],
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

  Widget _activityItem(
  String label,
  String value,
) {
  return SizedBox(
    width: 180,

    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Text(
          value,

          style: TextStyle(
            fontSize: 25,

            fontWeight:
                FontWeight.bold,

            color:
                AppColors.primary,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          label,

          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    ),
  );
}
}
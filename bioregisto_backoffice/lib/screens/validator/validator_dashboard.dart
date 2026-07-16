import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../utils/app_colors.dart';
import '../auth/login_screen.dart';
import 'pending_observations_screen.dart';
import 'validation_history_screen.dart';
import 'taxonomy_management_screen.dart';

class ValidatorDashboard extends StatefulWidget {
  const ValidatorDashboard({super.key});

  @override
  State<ValidatorDashboard> createState() =>
      _ValidatorDashboardState();
}

class _ValidatorDashboardState
    extends State<ValidatorDashboard> {

  late Future<Map<String, dynamic>>
      _statsFuture;

   late Future<List<dynamic>>
    _pendingFuture; 

  int _notificationCount = 0;

  @override
  void initState() {
    super.initState();

    _statsFuture =
        ApiService.getValidatorStats();

     _pendingFuture =
      ApiService.getPendingObservations();

      _loadNotificationCount();
  }

  Future<void> _loadNotificationCount() async {
  try {
    final observations =
        await ApiService.getPendingObservations();

    if (!mounted) return;

    setState(() {
      _notificationCount =
          observations.length;
    });
  } catch (error) {
    // Mantemos o dashboard funcional
    // mesmo que as notificações falhem.
  }
}

  Future<void> _refreshStats() async {
    setState(() {
      _statsFuture =
          ApiService.getValidatorStats();

      _pendingFuture =
          ApiService.getPendingObservations();
    });
     await _loadNotificationCount();
  }

  Future<void> _logout(
    BuildContext context,
  ) async {
    await ApiService.logout();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const LoginScreen(),
      ),
      (route) => false,
    );
  }

  Future<void> _showNotifications() async {
  final observations =
      await ApiService.getPendingObservations();

  if (!mounted) return;

  showDialog(
    context: context,

    builder: (dialogContext) {
      return AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.notifications_outlined,
            ),

            const SizedBox(width: 10),

            Text(
              'Observações pendentes (${observations.length})',
            ),
          ],
        ),

        content: SizedBox(
          width: 550,
          height: 400,

          child: observations.isEmpty
              ? const Center(
                  child: Text(
                    'Não existem novas observações para validar.',
                  ),
                )
              : ListView.separated(
                  itemCount:
                      observations.length,

                  separatorBuilder:
                      (context, index) =>
                          const Divider(),

                  itemBuilder:
                      (context, index) {
                    final observation =
                        observations[index];

                    return ListTile(
                      leading:
                          const CircleAvatar(
                        child: Icon(
                          Icons.eco,
                        ),
                      ),

                      title: Text(
                        observation[
                                'commonName'] ??
                            'Nova observação',
                      ),

                      subtitle: Text(
                        observation[
                                'scientificName'] ??
                            'Identificação não indicada',
                      ),

                      trailing:
                          const Icon(
                        Icons.chevron_right,
                      ),

                      onTap: () {
                        Navigator.pop(
                          dialogContext,
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const PendingObservationsScreen(),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(
                dialogContext,
              );
            },

            child: const Text(
              'Fechar',
            ),
          ),

          if (observations.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const PendingObservationsScreen(),
                  ),
                );
              },

              child: const Text(
                'Ver todas',
              ),
            ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final userName =
        ApiService.currentUser?['name'] ??
            'Validador';

    return Scaffold(
      backgroundColor:
          AppColors.background,

      body: Row(
        children: [
          // SIDEBAR
          Container(
            width: 250,
            color: AppColors.sidebar,

            padding:
                const EdgeInsets.symmetric(
              vertical: 30,
              horizontal: 20,
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.eco,
                      color: Colors.white,
                      size: 35,
                    ),

                    SizedBox(width: 10),

                    Text(
                      'BioRegisto',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 50),

                _menuItem(
                  Icons.dashboard_outlined,
                  'Dashboard',
                  true,
                ),

                _menuItem(
                  Icons.fact_check_outlined,
                  'Observações pendentes',
                  false,

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const PendingObservationsScreen(),
                      ),
                    );
                  },
                ),

                _menuItem(
  Icons.verified_outlined,
  'Histórico de validações',
  false,

  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const ValidationHistoryScreen(),
      ),
    );
  },
),

_menuItem(
  Icons.account_tree_outlined,
  'Gestão da Taxonomia',
  false,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const TaxonomyManagementScreen(),
      ),
    );
  },
),

                const Spacer(),

                const Divider(
                  color: Colors.white24,
                ),

                _menuItem(
                  Icons.logout,
                  'Terminar sessão',
                  false,
                  onTap: () =>
                      _logout(context),
                ),
              ],
            ),
          ),

          // CONTEÚDO
          Expanded(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.all(35),

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
                            CrossAxisAlignment
                                .start,

                        children: [
                          const Text(
                            'Painel de Validação',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(
                            height: 5,
                          ),

                          Text(
                            'Bem-vindo, $userName',
                            style:
                                const TextStyle(
                              color:
                                  Colors.grey,
                            ),
                          ),
                        ],
                      ),

                     Row(
  children: [
    Stack(
      clipBehavior: Clip.none,

      children: [
        IconButton(
          tooltip: 'Notificações',

          onPressed: () {
            _showNotifications();
          },

          icon: const Icon(
            Icons.notifications_outlined,
            size: 28,
          ),
        ),

        if (_notificationCount > 0)
          Positioned(
            right: 2,
            top: 2,

            child: Container(
              constraints:
                  const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),

              padding:
                  const EdgeInsets.symmetric(
                horizontal: 5,
              ),

              decoration:
                  const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),

              alignment:
                  Alignment.center,

              child: Text(
                _notificationCount > 99
                    ? '99+'
                    : '$_notificationCount',

                style:
                    const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    ),

    const SizedBox(width: 15),

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
                    ],
                  ),

                  const SizedBox(height: 35),

                  // CARDS
                FutureBuilder<Map<String, dynamic>>(
  future: _statsFuture,

  builder: (context, snapshot) {
    if (snapshot.connectionState ==
        ConnectionState.waiting) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (snapshot.hasError) {
      return Container(
        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(18),
        ),

        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Não foi possível carregar as estatísticas.',
              ),
            ),

            IconButton(
              onPressed: _refreshStats,
              icon: const Icon(
                Icons.refresh,
              ),
            ),
          ],
        ),
      );
    }

    final stats =
        snapshot.data ?? {};

    return LayoutBuilder(
  builder: (context, constraints) {
    final cardWidth =
        constraints.maxWidth > 1100
            ? (constraints.maxWidth - 60) / 4
            : (constraints.maxWidth - 20) / 2;

    return Wrap(
      spacing: 20,
      runSpacing: 20,

      children: [
        SizedBox(
          width: cardWidth,
          child: _statCard(
            '${stats['pending'] ?? 0}',
            'Pendentes',
            Icons.pending_actions,
          ),
        ),

        SizedBox(
          width: cardWidth,
          child: _statCard(
            '${stats['validated'] ?? 0}',
            'Validadas',
            Icons.verified,
          ),
        ),

        SizedBox(
          width: cardWidth,
          child: _statCard(
            '${stats['rejected'] ?? 0}',
            'Rejeitadas',
            Icons.cancel_outlined,
          ),
        ),

        SizedBox(
          width: cardWidth,
          child: _statCard(
            '${stats['totalProcessed'] ?? 0}',
            'Total processadas',
            Icons.fact_check_outlined,
          ),
        ),
      ],
    );
  },
);
  },
),

    const SizedBox(height: 35),

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(25),

  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
  ),

  child: Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,

    children: [
      Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

        children: [
          const Text(
            'Observações pendentes recentes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          TextButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const PendingObservationsScreen(),
                ),
              );

              _refreshStats();
            },
            child: const Text(
              'Ver todas',
            ),
          ),
        ],
      ),

      const SizedBox(height: 20),

      FutureBuilder<List<dynamic>>(
        future: _pendingFuture,

        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child:
                    CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasError) {
            return const Text(
              'Não foi possível carregar as observações recentes.',
            );
          }

          final observations =
              snapshot.data ?? [];

          if (observations.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(25),
              child: Center(
                child: Text(
                  'Não existem observações pendentes.',
                ),
              ),
            );
          }

          final recent =
              observations.take(5).toList();

          return Column(
            children: recent
                .map(
                  (observation) =>
                      _recentObservation(
                    observation,
                  ),
                )
                .toList(),
          );
        },
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
      padding:
          const EdgeInsets.only(
        bottom: 10,
      ),

      child: Material(
        color: selected
            ? Colors.white.withOpacity(
                0.15,
              )
            : Colors.transparent,

        borderRadius:
            BorderRadius.circular(12),

        child: InkWell(
          onTap: onTap,

          borderRadius:
              BorderRadius.circular(12),

          child: Padding(
            padding:
                const EdgeInsets.all(14),

            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child: Text(
                    title,
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

Widget _recentObservation(
  dynamic observation,
) {
  final imageUrl =
      ApiService.getImageUrl(
    observation['imageUrl'],
  );

  return Container(
    padding: const EdgeInsets.symmetric(
      vertical: 12,
    ),

    decoration: const BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: Color(0xFFEEEEEE),
        ),
      ),
    ),

    child: Row(
      children: [
        ClipRRect(
          borderRadius:
              BorderRadius.circular(10),

          child: SizedBox(
            width: 55,
            height: 55,

            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,

                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return Container(
                        color:
                            Colors.grey.shade200,
                        child: const Icon(
                          Icons.image_outlined,
                        ),
                      );
                    },
                  )
                : Container(
                    color:
                        Colors.grey.shade200,
                    child: const Icon(
                      Icons.image_outlined,
                    ),
                  ),
          ),
        ),

        const SizedBox(width: 15),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                observation['commonName'] ??
                    'Sem nome comum',

                style: const TextStyle(
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              Text(
                observation[
                        'scientificName'] ??
                    'Espécie desconhecida',

                style: const TextStyle(
                  color: Colors.grey,
                  fontStyle:
                      FontStyle.italic,
                ),
              ),
            ],
          ),
        ),

        const Icon(
          Icons.schedule,
          color: Colors.orange,
          size: 18,
        ),

        const SizedBox(width: 6),

        const Text(
          'Pendente',
          style: TextStyle(
            color: Colors.orange,
          ),
        ),
      ],
    ),
  );
}

Widget _statCard(
  String value,
  String label,
  IconData icon,
) {
  return Container(
    padding: const EdgeInsets.all(18),

    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(18),
    ),

    child: Row(
      children: [
        Container(
          padding:
              const EdgeInsets.all(12),

          decoration: BoxDecoration(
            color: AppColors.primary
                .withOpacity(0.12),

            borderRadius:
                BorderRadius.circular(14),
          ),

          child: Icon(
            icon,
            color: AppColors.primary,
            size: 26,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            mainAxisSize:
                MainAxisSize.min,

            children: [
              Text(
                value,

                style: const TextStyle(
                  fontSize: 26,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                label,

                maxLines: 2,

                overflow:
                    TextOverflow.ellipsis,

                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}
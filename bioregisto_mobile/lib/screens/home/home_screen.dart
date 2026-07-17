import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../map/map_screen.dart';
import '../profile/profile_screen.dart';
import '../challenges/challenges_screen.dart';
import '../observations/my_observations_screen.dart';
import '../observations/new_observation_screen.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';
import '../notifications/notifications_screen.dart';
import '../observations/observation_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {
  int _notificationCount = 0;
  late Future<List<dynamic>>
    _observationsFuture;

  @override
  void initState() {
    super.initState();

    _checkNotifications();
     _observationsFuture =
      ApiService.getObservations();
  }

 Future<void> _checkNotifications() async {
  try {
    final notifications =
        await ApiService.getNotifications();

    if (!mounted) return;

    final individualNotifications =
        notifications.where(
      (notification) {
        final isGlobal =
            notification['isGlobal'];

        return isGlobal == false;
      },
    ).toList();

    setState(() {
      _notificationCount =
          individualNotifications.length;
    });
  } catch (error) {
    debugPrint(
      'Erro ao carregar notificações: $error',
    );
  }
}
  @override
  Widget build(BuildContext context) {
    final profileImageUrl =
    ApiService.currentUser?['profileImageUrl']
        ?.toString();

final fullProfileImageUrl =
    profileImageUrl != null &&
            profileImageUrl.isNotEmpty
        ? profileImageUrl.startsWith('http')
            ? profileImageUrl
            : '${ApiService.baseUrl.replaceFirst('/api', '')}$profileImageUrl'
        : null;
return Scaffold(
backgroundColor: AppColors.background,

drawer: Drawer(
  child: ListView(
    padding: EdgeInsets.zero,
    children: [
      UserAccountsDrawerHeader(
        accountName: Text(
          ApiService.currentUser?['name'] ??
              'Utilizador',
        ),

        accountEmail: Text(
          ApiService.currentUser?['email'] ??
              '',
        ),

       currentAccountPicture: CircleAvatar(
  backgroundColor: Colors.white,

  backgroundImage:
      fullProfileImageUrl != null
          ? NetworkImage(
              fullProfileImageUrl,
            )
          : null,

  child:
      fullProfileImageUrl == null
          ? Icon(
              Icons.person,
              color: AppColors.primary,
              size: 35,
            )
          : null,
),

        decoration: BoxDecoration(
          color: AppColors.primary,
        ),
      ),

      ListTile(
        leading:
            const Icon(Icons.home),

        title:
            const Text('Início'),

        onTap: () {
          Navigator.pop(context);
        },
      ),

      ListTile(
        leading:
            const Icon(Icons.map),

        title:
            const Text('Mapa'),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const MapScreen(),
            ),
          );
        },
      ),

      ListTile(
        leading: const Icon(
          Icons.photo_camera,
        ),

        title: const Text(
          'As minhas observações',
        ),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const MyObservationsScreen(),
            ),
          );
        },
      ),

      ListTile(
        leading: const Icon(
          Icons.emoji_events,
        ),

        title: const Text(
          'Desafios',
        ),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const ChallengesScreen(),
            ),
          );
        },
      ),

      ListTile(
        leading: const Icon(
          Icons.person,
        ),

        title:
            const Text('Perfil'),

       onTap: () async {
  // Fecha primeiro o side menu.
  Navigator.pop(context);

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) =>
          const ProfileScreen(),
    ),
  );

  // Reconstrói a Home quando
  // regressamos do Perfil.
  if (!mounted) return;

  setState(() {});
},
      ),

      const Divider(),

      ListTile(
        leading: const Icon(
          Icons.logout,
          color: Colors.red,
        ),

        title: const Text(
          'Terminar sessão',

          style: TextStyle(
            color: Colors.red,
          ),
        ),

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

  floatingActionButton: Container(
  width: 72,
  height: 72,

  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: AppColors.primary,

    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 8,
      ),
    ],
  ),

  child: IconButton(
    icon: const Icon(
      Icons.camera_alt,
      color: Colors.white,
    ),

    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const NewObservationScreen(),
        ),
      );
    },
  ),
),

floatingActionButtonLocation:
    FloatingActionButtonLocation.centerDocked,

bottomNavigationBar: BottomAppBar(
  shape: const CircularNotchedRectangle(),
  color: Colors.white,
  surfaceTintColor: Colors.white,
  elevation: 8,

  child: SizedBox(
    height: 70,

    child: Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceAround,

      children: [

        _navItem(
          context,
          Icons.home,
          "Início",
          const HomeScreen(),
        ),

        _navItem(
          context,
          Icons.map,
          "Mapa",
          const MapScreen(),
        ),

        const SizedBox(width: 40),

        _navItem(
          context,
          Icons.emoji_events_outlined,
          "Desafios",
          const ChallengesScreen(),
        ),

       _navItem(
        context,
        Icons.person,
        "Perfil",
        const ProfileScreen(),
      ),
      ],
    ),
  ),
),

  body: SingleChildScrollView(
    child: Column(
      children: [

        // Header
        Container(
          padding: const EdgeInsets.all(20),
          height: 220,

          decoration: BoxDecoration(
            color: AppColors.primary,

            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),

          child: Column(
            children: [

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [

                 Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(
                        Icons.menu,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ),

                  Text(
                    "BioRegisto",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

Stack(
  clipBehavior: Clip.none,

  children: [
    IconButton(
      tooltip: 'Notificações',

      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const NotificationsScreen(),
          ),
        );

        if (!mounted) return;

        setState(() {
          _notificationCount = 0;
        });
      },

      icon: const Icon(
        Icons.notifications_none,
        color: Colors.white,
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
                ],
              ),

              const SizedBox(height: 40),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Olá, ${ApiService.currentUser?['name'] ?? 'Observador'}!",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Bem-vindo de volta",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Menu principal
        Padding(
          padding: const EdgeInsets.all(20),

          child: GridView.count(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),

            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.1,

            children: [

              _menuCard(
                context,
                "Nova\nObservação",
                Icons.camera_alt_outlined,
                AppColors.cardGreen,
                const NewObservationScreen(),
              ),

              _menuCard(
                context,
                "Mapa",
                Icons.map_outlined,
                AppColors.cardBlue,
                const MapScreen(),
              ),

             _menuCard(
                context,
                "As minhas\nobservações",
                Icons.photo_camera_outlined,
                AppColors.cardBrown,
                const MyObservationsScreen(),
              ),

              _menuCard(
                context,
                "Desafios",
                Icons.emoji_events_outlined,
                AppColors.cardOrange,
                const ChallengesScreen(),
              ),
            ],
          ),
        ),

      // Observações recentes
Padding(
  padding: const EdgeInsets.symmetric(
    horizontal: 20,
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
            'Observações Recentes',

            style: TextStyle(
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const MyObservationsScreen(),
                ),
              );
            },

            child: Text(
              'Ver todas',

              style: TextStyle(
                color:
                    AppColors.primary,
              ),
            ),
          ),
        ],
      ),

      const SizedBox(
        height: 10,
      ),

      FutureBuilder<List<dynamic>>(
        future:
            _observationsFuture,

        builder: (
          context,
          snapshot,
        ) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return Padding(
              padding:
                  const EdgeInsets.all(
                25,
              ),

              child: Center(
                child:
                    CircularProgressIndicator(
                  color:
                      AppColors.primary,
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return const Padding(
              padding:
                  EdgeInsets.symmetric(
                vertical: 20,
              ),

              child: Text(
                'Não foi possível carregar as observações recentes.',
              ),
            );
          }

          final observations =
              snapshot.data ?? [];

          if (observations.isEmpty) {
            return Container(
              width:
                  double.infinity,

              padding:
                  const EdgeInsets.all(
                25,
              ),

              decoration:
                  BoxDecoration(
                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),

              child: const Column(
                children: [
                  Icon(
                    Icons
                        .photo_camera_outlined,

                    size: 40,

                    color:
                        Colors.grey,
                  ),

                  SizedBox(
                    height: 10,
                  ),

                  Text(
                    'Ainda não tem observações registadas.',

                    textAlign:
                        TextAlign.center,

                    style: TextStyle(
                      color:
                          Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          // A API já devolve por
          // CreatedAt descendente.
          final recentObservations =
              observations
                  .take(3)
                  .toList();

          return Column(
            children:
                recentObservations
                    .map(
              (observation) {
                return Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 10,
                  ),

                  child:
                      _observationCard(
                    observation,
                  ),
                );
              },
            ).toList(),
          );
        },
      ),

      const SizedBox(
        height: 30,
      ),
    ],
  ),
),
      ],
    ),
  ),
);

}

Widget _menuCard(
  BuildContext context,
  String title,
  IconData icon,
  Color color,
  Widget screen,
) {
  return GestureDetector(
 onTap: () async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => screen,
    ),
  );

  if (!mounted) return;

  setState(() {
    _observationsFuture =
        ApiService.getObservations();
  });
},

    child: Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25),
      ),

      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Icon(
            icon,
            color: Colors.white,
            size: 35,
          ),

          const SizedBox(height: 15),

          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _navItem(
  BuildContext context,
  IconData icon,
  String label,
  Widget screen,
) {
  return GestureDetector(
    onTap: () async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => screen,
    ),
  );

  if (!mounted) return;

  setState(() {});
},
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,

      children: [

        Icon(
          icon,
          color: const Color(0xFF8CA38D),
        ),

        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF8CA38D),
          ),
        ),
      ],
    ),
  );
}

Widget _observationCard(
  dynamic observation,
) {
  final species =
      observation['commonName']
                  ?.toString()
                  .trim()
                  .isNotEmpty ==
              true
          ? observation['commonName']
              .toString()
          : observation['scientificName']
                  ?.toString() ??
              'Espécie desconhecida';

  final status =
      observation['status']
              ?.toString()
              .toLowerCase() ??
          'pending';

  // Preparar URL da fotografia
  final imageUrl =
      observation['imageUrl']
          ?.toString();

  final fullImageUrl =
      imageUrl != null &&
              imageUrl.isNotEmpty
          ? imageUrl.startsWith(
              'http',
            )
              ? imageUrl
              : '${ApiService.baseUrl.replaceFirst('/api', '')}$imageUrl'
          : null;

  String statusText;
  IconData statusIcon;
  Color statusColor;

  if (status == 'validated') {
    statusText = 'Validada';
    statusIcon =
        Icons.check_circle;
    statusColor =
        Colors.green;
  } else if (
      status == 'rejected') {
    statusText = 'Rejeitada';
    statusIcon =
        Icons.cancel;
    statusColor =
        Colors.red;
  } else {
    statusText = 'Pendente';
    statusIcon =
        Icons.access_time;
    statusColor =
        Colors.orange;
  }

  return Material(
    color: Colors.white,

    borderRadius:
        BorderRadius.circular(
      20,
    ),

    child: InkWell(
      borderRadius:
          BorderRadius.circular(
        20,
      ),

      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ObservationDetailScreen(
              observation:
                  observation,
            ),
          ),
        );
      },

      child: Container(
        padding:
            const EdgeInsets.all(
          16,
        ),

        decoration:
            BoxDecoration(
          borderRadius:
              BorderRadius.circular(
            20,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(
                0.05,
              ),

              blurRadius: 10,

              offset:
                  const Offset(
                0,
                4,
              ),
            ),
          ],
        ),

        child: Row(
          children: [
            // FOTOGRAFIA
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(
                15,
              ),

              child: Container(
                width: 55,
                height: 55,

                color:
                    AppColors.cardGreen,

                child:
                    fullImageUrl != null
                        ? Image.network(
                            fullImageUrl,

                            fit:
                                BoxFit.cover,

                            errorBuilder: (
                              context,
                              error,
                              stackTrace,
                            ) {
                              return const Icon(
                                Icons
                                    .broken_image_outlined,

                                color:
                                    Colors.white,
                              );
                            },
                          )
                        : const Icon(
                            Icons
                                .photo_camera,

                            color:
                                Colors.white,
                          ),
              ),
            ),

            const SizedBox(
              width: 15,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [
                  Text(
                    species,

                    maxLines: 1,

                    overflow:
                        TextOverflow
                            .ellipsis,

                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight
                              .bold,

                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Row(
                    children: [
                      Icon(
                        statusIcon,

                        size: 16,

                        color:
                            statusColor,
                      ),

                      const SizedBox(
                        width: 5,
                      ),

                      Text(
                        statusText,

                        style:
                            TextStyle(
                          color:
                              statusColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(
              width: 8,
            ),

            Icon(
              Icons.chevron_right,

              color:
                  Colors.grey.shade400,
            ),
          ],
        ),
      ),
    ),
  );
}

}

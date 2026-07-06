import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../map/map_screen.dart';
import '../profile/profile_screen.dart';
import '../challenges/challenges_screen.dart';
import '../observations/my_observations_screen.dart';
import '../observations/new_observation_screen.dart';


class HomeScreen extends StatelessWidget {
const HomeScreen({super.key});

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: AppColors.background,

drawer: Drawer(
  child: ListView(
    padding: EdgeInsets.zero,
    children: [

      UserAccountsDrawerHeader(
        accountName: const Text(
          "João Silva",
        ),

        accountEmail: const Text(
          "400 pontos",
        ),

        currentAccountPicture:
            const CircleAvatar(
          child: Icon(Icons.person),
        ),

        decoration: BoxDecoration(
          color: AppColors.primary,
        ),
      ),

      ListTile(
        leading: const Icon(Icons.home),
        title: const Text("Início"),
        onTap: () {
          Navigator.pop(context);
        },
      ),

      ListTile(
        leading: const Icon(Icons.map),
        title: const Text("Mapa"),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MapScreen(),
            ),
          );
        },
      ),

      ListTile(
        leading: const Icon(
          Icons.photo_camera,
        ),
        title: const Text(
          "As minhas observações",
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
          "Desafios",
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
        leading: const Icon(Icons.person),
        title: const Text("Perfil"),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const ProfileScreen(),
            ),
          );
        },
      ),

      const Divider(),

      ListTile(
        leading: const Icon(Icons.settings),
        title: const Text("Definições"),
        onTap: () {},
      ),

      ListTile(
        leading: const Icon(
          Icons.help_outline,
        ),
        title: const Text("Ajuda"),
        onTap: () {},
      ),

      const Divider(),

      ListTile(
        leading: const Icon(
          Icons.logout,
          color: Colors.red,
        ),

        title: const Text(
          "Terminar sessão",
          style: TextStyle(
            color: Colors.red,
          ),
        ),

        onTap: () {},
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

                  Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                  ),
                ],
              ),

              const SizedBox(height: 40),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Olá, Observador!",
                  style: TextStyle(
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

              const Text(
                "Observações Recentes",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              _observationCard(
                "Pardal-comum",
                "Aprovada",
                Icons.check_circle,
                Colors.green,
              ),

              const SizedBox(height: 10),

              _observationCard(
                "Espécie desconhecida",
                "Pendente",
                Icons.access_time,
                Colors.orange,
              ),

              const SizedBox(height: 30),
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
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => screen,
        ),
      );
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
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => screen,
        ),
      );
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
String species,
String status,
IconData icon,
Color statusColor,
) {
return Container(
padding: const EdgeInsets.all(16),

  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius:
        BorderRadius.circular(20),

    boxShadow: [
      BoxShadow(
        color:
            Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  ),

  child: Row(
    children: [

      Container(
        width: 55,
        height: 55,

        decoration: BoxDecoration(
          color: AppColors.cardGreen,
          borderRadius:
              BorderRadius.circular(15),
        ),

        child: const Icon(
          Icons.photo_camera,
          color: Colors.white,
        ),
      ),

      const SizedBox(width: 15),

      Expanded(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text(
              species,
              style: const TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              status,
              style: TextStyle(
                color: statusColor,
              ),
            ),
          ],
        ),
      ),

      Icon(
        icon,
        color: statusColor,
      ),
    ],
  ),
);
}
}

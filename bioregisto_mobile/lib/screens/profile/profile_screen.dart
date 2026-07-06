import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F3),

      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            // HEADER
            Container(
              width: double.infinity,

              padding: const EdgeInsets.only(
                bottom: 30,
              ),

              decoration: BoxDecoration(
                color: AppColors.primary,

                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),

              child: Column(
                children: [

                  const CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,

                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "João Silva",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    "Observador registado",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 15),

                  ElevatedButton.icon(
                    onPressed: () {},

                    icon: const Icon(
                      Icons.share,
                    ),

                    label: const Text(
                      "Partilhar perfil",
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                children: [

                  // ESTATÍSTICAS

                  Row(
                    children: [

                      Expanded(
                        child: _statCard(
                          "4",
                          "Observações",
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _statCard(
                          "4",
                          "Espécies",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [

                      Expanded(
                        child: _statCard(
                          "2",
                          "Locais",
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _statCard(
                          "5",
                          "Dias ativos",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // ATIVIDADE

                  _sectionCard(
                    "Atividade Mensal",
                    Column(
                      children: [

                        Container(
                          height: 120,
                          width: double.infinity,

                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius:
                                BorderRadius.circular(12),
                          ),

                          child: const Center(
                            child: Text(
                              "Gráfico de atividade",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // CONQUISTAS

                  _sectionCard(
                    "Conquistas",

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,

                      children: [

                        _achievement(
                          Icons.my_location,
                          "Primeiro Registo",
                        ),

                        _achievement(
                          Icons.star,
                          "Observador Ativo",
                        ),

                        _achievement(
                          Icons.emoji_events,
                          "10 Espécies",
                        ),

                        _achievement(
                          Icons.verified,
                          "Verificador",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ESPÉCIES

                  _sectionCard(
                    "Espécies registadas",

                    Column(
                      children: const [

                        ListTile(
                          title:
                              Text("Pardal-comum"),
                          trailing: Text("1x"),
                        ),

                        ListTile(
                          title:
                              Text("Tentilhão-comum"),
                          trailing: Text("1x"),
                        ),

                        ListTile(
                          title:
                              Text("Carvalho-alvarinho"),
                          trailing: Text("1x"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(
    String value,
    String label,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Column(
        children: [

          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(label),
        ],
      ),
    );
  }

  Widget _sectionCard(
    String title,
    Widget child,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          child,
        ],
      ),
    );
  }

  Widget _achievement(
    IconData icon,
    String title,
  ) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius:
            BorderRadius.circular(15),
      ),

      child: Column(
        children: [

          Icon(
            icon,
            color: AppColors.primary,
          ),

          const SizedBox(height: 10),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
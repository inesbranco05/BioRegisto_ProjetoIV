import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {
  late Future<List<dynamic>> _observationsFuture;

  @override
  void initState() {
    super.initState();

    _observationsFuture =
        ApiService.getObservations();
  }

  bool _isVerified(dynamic observation) {
    final status =
        observation['status']
                ?.toString()
                .toLowerCase() ??
            '';

    return status == 'verified' ||
        status == 'verificada' ||
        status == 'approved' ||
        status == 'aprovada';
  }

  @override
  Widget build(BuildContext context) {
    final user = ApiService.currentUser;

    final userName =
        user?['name']?.toString() ??
            'Utilizador';

    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F7F3),

      appBar: AppBar(
        backgroundColor:
            AppColors.primary,

        elevation: 0,

        iconTheme:
            const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: FutureBuilder<List<dynamic>>(
        future: _observationsFuture,

        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar o perfil:\n'
                '${snapshot.error}',

                textAlign:
                    TextAlign.center,
              ),
            );
          }

          final observations =
              snapshot.data ?? [];

          // TOTAL DE OBSERVAÇÕES
          final totalObservations =
              observations.length;

          // ESPÉCIES DISTINTAS
          final uniqueSpecies =
              observations
                  .map(
                    (observation) =>
                        observation[
                                'scientificName']
                            ?.toString()
                            .trim()
                            .toLowerCase(),
                  )
                  .where(
                    (species) =>
                        species != null &&
                        species.isNotEmpty,
                  )
                  .toSet()
                  .length;

          // OBSERVAÇÕES VERIFICADAS
          final verifiedObservations =
              observations
                  .where(_isVerified)
                  .length;

          // LOCAIS DISTINTOS
          final uniqueLocations =
              observations
                  .map(
                    (observation) =>
                        '${observation['latitude']},'
                        '${observation['longitude']}',
                  )
                  .toSet()
                  .length;

          // DIAS ATIVOS
          final activeDays =
              observations
                  .map(
                    (observation) {
                      final createdAt =
                          observation[
                              'createdAt'];

                      if (createdAt ==
                          null) {
                        return null;
                      }

                      final date =
                          DateTime.tryParse(
                        createdAt.toString(),
                      );

                      if (date == null) {
                        return null;
                      }

                      return '${date.year}-'
                          '${date.month}-'
                          '${date.day}';
                    },
                  )
                  .whereType<String>()
                  .toSet()
                  .length;

          // CONTAGEM POR ESPÉCIE
          final Map<String, int>
              speciesCount = {};

          for (final observation
              in observations) {
            final commonName =
                observation['commonName']
                        ?.toString()
                        .trim() ??
                    '';

            if (commonName.isNotEmpty) {
              speciesCount[
                      commonName] =
                  (speciesCount[
                              commonName] ??
                          0) +
                      1;
            }
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // HEADER
                Container(
                  width:
                      double.infinity,

                  padding:
                      const EdgeInsets.only(
                    bottom: 30,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        AppColors.primary,

                    borderRadius:
                        const BorderRadius
                            .only(
                      bottomLeft:
                          Radius.circular(
                        30,
                      ),

                      bottomRight:
                          Radius.circular(
                        30,
                      ),
                    ),
                  ),

                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 45,

                        backgroundColor:
                            Colors.white,

                        child: Icon(
                          Icons.person,

                          size: 50,

                          color:
                              Colors.grey,
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      Text(
                        userName,

                        style:
                            const TextStyle(
                          color:
                              Colors.white,

                          fontSize: 24,

                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      const Text(
                        "Observador registado",

                        style: TextStyle(
                          color: Colors
                              .white70,
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      ElevatedButton.icon(
                        onPressed: () {},

                        icon: const Icon(
                          Icons.share,
                        ),

                        label:
                            const Text(
                          "Partilhar perfil",
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding:
                      const EdgeInsets.all(
                    20,
                  ),

                  child: Column(
                    children: [
                      // ESTATÍSTICAS

                      Row(
                        children: [
                          Expanded(
                            child:
                                _statCard(
                              totalObservations
                                  .toString(),

                              "Observações",
                            ),
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          Expanded(
                            child:
                                _statCard(
                              uniqueSpecies
                                  .toString(),

                              "Espécies",
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Row(
                        children: [
                          Expanded(
                            child:
                                _statCard(
                              uniqueLocations
                                  .toString(),

                              "Locais",
                            ),
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          Expanded(
                            child:
                                _statCard(
                              activeDays
                                  .toString(),

                              "Dias ativos",
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 25,
                      ),

                      // ESTADO DAS OBSERVAÇÕES

                      _sectionCard(
                        "Resumo",

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceAround,

                          children: [
                            _summaryItem(
                              verifiedObservations
                                  .toString(),

                              "Verificadas",

                              Colors.green,
                            ),

                            _summaryItem(
                              (totalObservations -
                                      verifiedObservations)
                                  .toString(),

                              "Pendentes",

                              Colors.orange,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      // CONQUISTAS

                      _sectionCard(
                        "Conquistas",

                        Wrap(
                          spacing: 10,
                          runSpacing: 10,

                          children: [
                            _achievement(
                              Icons
                                  .my_location,

                              "Primeiro Registo",
                            ),

                            _achievement(
                              Icons.star,

                              "Observador Ativo",
                            ),

                            _achievement(
                              Icons
                                  .emoji_events,

                              "10 Espécies",
                            ),

                            _achievement(
                              Icons.verified,

                              "Verificador",
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      // ESPÉCIES

                      _sectionCard(
                        "Espécies registadas",

                        speciesCount.isEmpty
                            ? const Padding(
                                padding:
                                    EdgeInsets
                                        .all(
                                  20,
                                ),

                                child: Center(
                                  child: Text(
                                    "Ainda não existem espécies registadas.",

                                    style:
                                        TextStyle(
                                      color:
                                          Colors
                                              .grey,
                                    ),
                                  ),
                                ),
                              )
                            : Column(
                                children:
                                    speciesCount
                                        .entries
                                        .map(
                                  (entry) {
                                    return ListTile(
                                      leading:
                                          const Icon(
                                        Icons
                                            .eco_outlined,
                                      ),

                                      title:
                                          Text(
                                        entry.key,
                                      ),

                                      trailing:
                                          Text(
                                        "${entry.value}x",
                                      ),
                                    );
                                  },
                                ).toList(),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statCard(
    String value,
    String label,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(20),

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

              fontWeight:
                  FontWeight.bold,
            ),
          ),

          Text(label),
        ],
      ),
    );
  }

  Widget _summaryItem(
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,

          style: TextStyle(
            fontSize: 26,

            fontWeight:
                FontWeight.bold,

            color: color,
          ),
        ),

        const SizedBox(height: 5),

        Text(label),
      ],
    );
  }

  Widget _sectionCard(
    String title,
    Widget child,
  ) {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(15),

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

              fontWeight:
                  FontWeight.bold,
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

      padding:
          const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color:
            Colors.grey.shade100,

        borderRadius:
            BorderRadius.circular(15),
      ),

      child: Column(
        children: [
          Icon(
            icon,
            color:
                AppColors.primary,
          ),

          const SizedBox(height: 10),

          Text(
            title,

            textAlign:
                TextAlign.center,

            style: const TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
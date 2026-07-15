import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../services/api_service.dart';

class MyObservationsScreen extends StatefulWidget {
  const MyObservationsScreen({super.key});

  @override
  State<MyObservationsScreen> createState() =>
      _MyObservationsScreenState();
}

class _MyObservationsScreenState
    extends State<MyObservationsScreen> {
  late Future<List<dynamic>> _observationsFuture;

  String _searchText = '';
  String _selectedFilter = 'Todas';

  @override
  void initState() {
    super.initState();
    _observationsFuture = ApiService.getObservations();
  }

  bool _isVerified(dynamic observation) {
    final status =
        observation['status']?.toString().toLowerCase() ?? '';

    return status == 'verified' ||
        status == 'verificada' ||
        status == 'approved' ||
        status == 'aprovada';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F3),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7F3),
        elevation: 0,

        title: const Text(
          "As minhas observações",
          style: TextStyle(
            color: Colors.black87,
          ),
        ),

        centerTitle: true,
      ),

      body: FutureBuilder<List<dynamic>>(
        future: _observationsFuture,

        builder: (context, snapshot) {
          // LOADING
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ERRO
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Erro ao carregar observações:\n"
                "${snapshot.error}",
                textAlign: TextAlign.center,
              ),
            );
          }

          final observations = snapshot.data ?? [];

          // CONTAGENS
          final verifiedCount =
              observations.where(_isVerified).length;

          final pendingCount =
              observations.length - verifiedCount;

          // ESPÉCIES DISTINTAS
          final uniqueSpecies = observations
              .map(
                (observation) =>
                    observation['scientificName']
                        ?.toString()
                        .trim()
                        .toLowerCase(),
              )
              .where(
                (name) =>
                    name != null &&
                    name.isNotEmpty,
              )
              .toSet()
              .length;

          // PESQUISA + FILTROS
          final filteredObservations =
              observations.where(
            (observation) {
              final commonName =
                  observation['commonName']
                          ?.toString()
                          .toLowerCase() ??
                      '';

              final scientificName =
                  observation['scientificName']
                          ?.toString()
                          .toLowerCase() ??
                      '';

              final search =
                  _searchText.toLowerCase();

              final matchesSearch =
                  commonName.contains(search) ||
                      scientificName.contains(search);

              bool matchesFilter = true;

              if (_selectedFilter ==
                  'Verificadas') {
                matchesFilter =
                    _isVerified(observation);
              }

              if (_selectedFilter ==
                  'Pendentes') {
                matchesFilter =
                    !_isVerified(observation);
              }

              return matchesSearch &&
                  matchesFilter;
            },
          ).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Column(
              children: [
                // PESQUISA
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchText = value;
                    });
                  },

                  decoration: InputDecoration(
                    hintText:
                        "Pesquisar espécie...",

                    prefixIcon:
                        const Icon(Icons.search),

                    filled: true,
                    fillColor: Colors.white,

                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // FILTROS
                Row(
                  children: [
                    _filterButton(
                      "Todas",
                      "Todas (${observations.length})",
                    ),

                    const SizedBox(width: 10),

                    _filterButton(
                      "Verificadas",
                      "Verificadas ($verifiedCount)",
                    ),

                    const SizedBox(width: 10),

                    _filterButton(
                      "Pendentes",
                      "Pendentes ($pendingCount)",
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ESTATÍSTICAS
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        observations.length
                            .toString(),
                        "Total",
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: _statCard(
                        uniqueSpecies.toString(),
                        "Espécies",
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: _statCard(
                        verifiedCount.toString(),
                        "Verificadas",
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // SEM RESULTADOS
                if (filteredObservations.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(30),

                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 45,
                          color: Colors.grey,
                        ),

                        SizedBox(height: 10),

                        Text(
                          "Nenhuma observação encontrada.",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )

                // LISTA
                else
                  ...filteredObservations.map(
                    (observation) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom: 15,
                        ),

                        child: _observationCard(
                          observation['commonName'] ??
                              'Sem nome comum',

                          observation[
                                  'scientificName'] ??
                              'Espécie desconhecida',

                          observation['status'] ??
                              'Pending',

                          observation['imageUrl'],
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _filterButton(
    String filter,
    String text,
  ) {
    final selected =
        _selectedFilter == filter;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = filter;
          });
        },

        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 200),

          height: 40,

          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary
                : Colors.white,

            borderRadius:
                BorderRadius.circular(10),
          ),

          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,

              style: TextStyle(
                color: selected
                    ? Colors.white
                    : Colors.black87,

                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard(
    String value,
    String label,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: AppColors.primary,

        borderRadius:
            BorderRadius.circular(15),
      ),

      child: Column(
        children: [
          Text(
            value,

            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,

              fontWeight:
                  FontWeight.bold,
            ),
          ),

          Text(
            label,

            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _observationCard(
    String commonName,
    String scientificName,
    String status,
    String? imageUrl,
  ) {
    final isVerified =
        status.toLowerCase() ==
                'verified' ||
            status.toLowerCase() ==
                'verificada' ||
            status.toLowerCase() ==
                'approved' ||
            status.toLowerCase() ==
                'aprovada';

    return Container(
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),

            child: SizedBox(
              width: 70,
              height: 70,

              child: imageUrl != null &&
                      imageUrl.isNotEmpty
                  ? Image.network(
                      '${ApiService.baseUrl.replaceFirst('/api', '')}$imageUrl',

                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,

                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return Container(
                          color: Colors.grey.shade300,

                          child: const Icon(
                            Icons.broken_image_outlined,
                            size: 35,
                            color: Colors.grey,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey.shade300,

                      child: const Icon(
                        Icons.image_outlined,
                        size: 35,
                        color: Colors.grey,
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
                  commonName,

                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                Text(
                  scientificName,

                  style: const TextStyle(
                    color: Colors.grey,

                    fontStyle:
                        FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  isVerified
                      ? "Verificada"
                      : "Pendente",

                  style: TextStyle(
                    color: isVerified
                        ? Colors.green
                        : Colors.orange,
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
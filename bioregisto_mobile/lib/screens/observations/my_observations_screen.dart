import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../services/api_service.dart';
import 'observation_detail_screen.dart';

class MyObservationsScreen extends StatefulWidget {
  const MyObservationsScreen({
    super.key,
  });

  @override
  State<MyObservationsScreen> createState() =>
      _MyObservationsScreenState();
}

class _MyObservationsScreenState
    extends State<MyObservationsScreen> {
  late Future<List<dynamic>>
      _observationsFuture;

  String _searchText = '';
  String _selectedFilter = 'Todas';

  @override
  void initState() {
    super.initState();

    _loadObservations();
  }

  void _loadObservations() {
    _observationsFuture =
        ApiService.getObservations();
  }

  Future<void> _refreshObservations() async {
    setState(() {
      _loadObservations();
    });

    await _observationsFuture;
  }

  String _getStatus(
    dynamic observation,
  ) {
    return observation['status']
            ?.toString()
            .trim()
            .toLowerCase() ??
        'pending';
  }

  bool _isValidated(
    dynamic observation,
  ) {
    return _getStatus(observation) ==
        'validated';
  }

  bool _isRejected(
    dynamic observation,
  ) {
    return _getStatus(observation) ==
        'rejected';
  }

  bool _isPending(
    dynamic observation,
  ) {
    return _getStatus(observation) ==
        'pending';
  }

  String? _getImageUrl(
    dynamic imageUrl,
  ) {
    if (imageUrl == null ||
        imageUrl.toString().isEmpty) {
      return null;
    }

    final value =
        imageUrl.toString();

    if (value.startsWith('http')) {
      return value;
    }

    return '${ApiService.baseUrl.replaceFirst('/api', '')}$value';
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F7F3),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFFF4F7F3),

        elevation: 0,

        title: const Text(
          'As minhas observações',

          style: TextStyle(
            color: Colors.black87,
          ),
        ),

        centerTitle: true,

        actions: [
          IconButton(
            tooltip:
                'Atualizar observações',

            onPressed: () {
              setState(() {
                _loadObservations();
              });
            },

            icon: Icon(
              Icons.refresh,
              color:
                  AppColors.primary,
            ),
          ),

          const SizedBox(
            width: 5,
          ),
        ],
      ),

      body:
          FutureBuilder<List<dynamic>>(
        future: _observationsFuture,

        builder: (
          context,
          snapshot,
        ) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return Center(
              child:
                  CircularProgressIndicator(
                color:
                    AppColors.primary,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(
                  30,
                ),

                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,

                  children: [
                    const Icon(
                      Icons
                          .error_outline,

                      size: 50,

                      color:
                          Colors.grey,
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    const Text(
                      'Não foi possível carregar as observações.',

                      textAlign:
                          TextAlign.center,
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _loadObservations();
                        });
                      },

                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            AppColors
                                .primary,

                        foregroundColor:
                            Colors.white,
                      ),

                      icon: const Icon(
                        Icons.refresh,
                      ),

                      label:
                          const Text(
                        'Tentar novamente',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final observations =
              snapshot.data ?? [];

          // CONTAGENS
          final validatedCount =
              observations
                  .where(
                    _isValidated,
                  )
                  .length;

          final pendingCount =
              observations
                  .where(
                    _isPending,
                  )
                  .length;

          final rejectedCount =
              observations
                  .where(
                    _isRejected,
                  )
                  .length;

          // ESPÉCIES DISTINTAS
          final uniqueSpecies =
              observations
                  .map(
                    (
                      observation,
                    ) =>
                        observation[
                                'scientificName']
                            ?.toString()
                            .trim()
                            .toLowerCase(),
                  )
                  .where(
                    (name) =>
                        name !=
                            null &&
                        name
                            .isNotEmpty,
                  )
                  .toSet()
                  .length;

          // PESQUISA + FILTROS
          final filteredObservations =
              observations.where(
            (observation) {
              final commonName =
                  observation[
                              'commonName']
                          ?.toString()
                          .toLowerCase() ??
                      '';

              final scientificName =
                  observation[
                              'scientificName']
                          ?.toString()
                          .toLowerCase() ??
                      '';

              final search =
                  _searchText
                      .toLowerCase();

              final matchesSearch =
                  commonName.contains(
                        search,
                      ) ||
                      scientificName
                          .contains(
                        search,
                      );

              bool matchesFilter =
                  true;

              if (_selectedFilter ==
                  'Validadas') {
                matchesFilter =
                    _isValidated(
                  observation,
                );
              } else if (
                  _selectedFilter ==
                      'Pendentes') {
                matchesFilter =
                    _isPending(
                  observation,
                );
              } else if (
                  _selectedFilter ==
                      'Rejeitadas') {
                matchesFilter =
                    _isRejected(
                  observation,
                );
              }

              return matchesSearch &&
                  matchesFilter;
            },
          ).toList();

          return RefreshIndicator(
            onRefresh:
                _refreshObservations,

            child:
                SingleChildScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(),

              padding:
                  const EdgeInsets.all(
                20,
              ),

              child: Column(
                children: [
                  // PESQUISA
                  TextField(
                    onChanged: (
                      value,
                    ) {
                      setState(() {
                        _searchText =
                            value;
                      });
                    },

                    decoration:
                        InputDecoration(
                      hintText:
                          'Pesquisar espécie...',

                      prefixIcon:
                          const Icon(
                        Icons.search,
                      ),

                      filled: true,

                      fillColor:
                          Colors.white,

                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          15,
                        ),

                        borderSide:
                            BorderSide
                                .none,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // FILTROS
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,

                    children: [
                      _filterButton(
                        'Todas',
                        'Todas (${observations.length})',
                      ),

                      _filterButton(
                        'Validadas',
                        'Validadas ($validatedCount)',
                      ),

                      _filterButton(
                        'Pendentes',
                        'Pendentes ($pendingCount)',
                      ),

                      _filterButton(
                        'Rejeitadas',
                        'Rejeitadas ($rejectedCount)',
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // ESTATÍSTICAS
                  Row(
                    children: [
                      Expanded(
                        child:
                            _statCard(
                          observations
                              .length
                              .toString(),

                          'Total',
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

                          'Espécies',
                        ),
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child:
                            _statCard(
                          validatedCount
                              .toString(),

                          'Validadas',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  // SEM RESULTADOS
                  if (filteredObservations
                      .isEmpty)
                    const Padding(
                      padding:
                          EdgeInsets.all(
                        30,
                      ),

                      child: Column(
                        children: [
                          Icon(
                            Icons
                                .search_off,

                            size: 45,

                            color:
                                Colors.grey,
                          ),

                          SizedBox(
                            height: 10,
                          ),

                          Text(
                            'Nenhuma observação encontrada.',

                            textAlign:
                                TextAlign
                                    .center,

                            style:
                                TextStyle(
                              color:
                                  Colors
                                      .grey,
                            ),
                          ),
                        ],
                      ),
                    )

                  // LISTA
                  else
                    ...filteredObservations
                        .map(
                      (observation) {
                        return Padding(
                          padding:
                              const EdgeInsets
                                  .only(
                            bottom: 15,
                          ),

                          child:
                              _observationCard(
                                observation: observation,
                            commonName:
                                observation[
                                        'commonName'] ??
                                    'Sem nome comum',

                            scientificName:
                                observation[
                                        'scientificName'] ??
                                    'Espécie desconhecida',

                            status:
                                observation[
                                        'status'] ??
                                    'Pending',

                            imageUrl:
                                observation[
                                    'imageUrl'],
                          ),
                        );
                      },
                    ),
                ],
              ),
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
        _selectedFilter ==
            filter;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter =
              filter;
        });
      },

      child: AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 200,
        ),

        padding:
            const EdgeInsets
                .symmetric(
          horizontal: 15,
          vertical: 11,
        ),

        decoration:
            BoxDecoration(
          color: selected
              ? AppColors.primary
              : Colors.white,

          borderRadius:
              BorderRadius.circular(
            10,
          ),

          border: Border.all(
            color: selected
                ? AppColors.primary
                : Colors.grey
                    .shade200,
          ),
        ),

        child: Text(
          text,

          textAlign:
              TextAlign.center,

          style: TextStyle(
            color: selected
                ? Colors.white
                : Colors.black87,

            fontSize: 12,

            fontWeight:
                selected
                    ? FontWeight
                        .w600
                    : FontWeight
                        .normal,
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
      padding:
          const EdgeInsets
              .symmetric(
        horizontal: 8,
        vertical: 15,
      ),

      decoration:
          BoxDecoration(
        color:
            AppColors.primary,

        borderRadius:
            BorderRadius.circular(
          15,
        ),
      ),

      child: Column(
        children: [
          Text(
            value,

            style:
                const TextStyle(
              color:
                  Colors.white,

              fontSize: 24,

              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 3,
          ),

          Text(
            label,

            textAlign:
                TextAlign.center,

            style:
                const TextStyle(
              color:
                  Colors.white,

              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _observationCard({
  required dynamic observation,
  required String commonName,
  required String scientificName,
  required String status,
  dynamic imageUrl,
}) {
    final normalizedStatus =
        status
            .trim()
            .toLowerCase();

    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (normalizedStatus ==
        'validated') {
      statusText =
          'Validada';

      statusColor =
          Colors.green;

      statusIcon =
          Icons.check_circle;
    } else if (
        normalizedStatus ==
            'rejected') {
      statusText =
          'Rejeitada';

      statusColor =
          Colors.red;

      statusIcon =
          Icons.cancel;
    } else {
      statusText =
          'Pendente';

      statusColor =
          Colors.orange;

      statusIcon =
          Icons.access_time;
    }

    final fullImageUrl =
        _getImageUrl(
      imageUrl,
    );

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

    child: Padding(
      padding:
          const EdgeInsets.all(
        15,
      ),

      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                BorderRadius
                    .circular(
              15,
            ),

            child: Container(
              width: 70,
              height: 70,

              color:
                  Colors.grey
                      .shade200,

              child: fullImageUrl !=
                      null
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

                          size: 32,

                          color:
                              Colors.grey,
                        );
                      },
                    )
                  : const Icon(
                      Icons
                          .image_outlined,

                      size: 35,

                      color:
                          Colors.grey,
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
                  commonName,

                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight
                            .bold,

                    fontSize: 16,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  scientificName,

                  style:
                      const TextStyle(
                    color:
                        Colors.grey,

                    fontStyle:
                        FontStyle
                            .italic,
                  ),
                ),

                const SizedBox(
                  height: 9,
                ),

                Row(
                  children: [
                    Icon(
                      statusIcon,

                      size: 17,

                      color:
                          statusColor,
                    ),

                    const SizedBox(
                      width: 6,
                    ),

                    Text(
                      statusText,

                      style:
                          TextStyle(
                        color:
                            statusColor,

                        fontWeight:
                            FontWeight
                                .w600,
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
    );
  }
}
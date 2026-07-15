import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../services/api_service.dart';
import '../../utils/app_colors.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() =>
      _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late Future<List<dynamic>> _observationsFuture;

  final MapController _mapController =
      MapController();

  final TextEditingController _searchController =
    TextEditingController();

  String _selectedFilter = 'Todas';
  String _searchQuery = '';  

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _observationsFuture =
        ApiService.getMapObservations();
  }

  bool _isValidated(dynamic observation) {
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

  String _statusText(dynamic observation) {
    return _isValidated(observation)
        ? 'Validada'
        : 'Pendente';
  }

  Color _statusColor(dynamic observation) {
    return _isValidated(observation)
        ? Colors.green
        : Colors.orange;
  }

  String? _getImageUrl(dynamic observation) {
    final imageUrl =
        observation['imageUrl']?.toString();

    if (imageUrl == null ||
        imageUrl.isEmpty) {
      return null;
    }

    return '${ApiService.baseUrl.replaceFirst('/api', '')}$imageUrl';
  }

  List<dynamic> _getFilteredObservations(
  List<dynamic> observations,
) {
  return observations.where((observation) {
    // PESQUISA
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

    final matchesSearch =
        commonName.contains(
          _searchQuery.toLowerCase(),
        ) ||
        scientificName.contains(
          _searchQuery.toLowerCase(),
        );

    if (!matchesSearch) {
      return false;
    }

    // FILTRO
    switch (_selectedFilter) {
      case 'Minhas':
        final currentUserId =
            ApiService.currentUser?['id'];

        return observation['userId'] ==
            currentUserId;

      case 'Validadas':
        return _isValidated(observation);

      case 'Pendentes':
        return !_isValidated(observation);

      default:
        return true;
    }
  }).toList();
}

  void _showObservationDetails(
    dynamic observation,
  ) {
    final imageUrl =
        _getImageUrl(observation);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent,

      builder: (context) {
        return Container(
          padding:
              const EdgeInsets.all(20),

          decoration:
              const BoxDecoration(
            color: Colors.white,

            borderRadius:
                BorderRadius.vertical(
              top: Radius.circular(25),
            ),
          ),

          child: SafeArea(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Center(
                  child: Container(
                    width: 45,
                    height: 5,

                    decoration:
                        BoxDecoration(
                      color: Colors
                          .grey.shade300,

                      borderRadius:
                          BorderRadius
                              .circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                if (imageUrl != null)
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),

                    child: Image.network(
                      imageUrl,

                      width:
                          double.infinity,

                      height: 200,

                      fit: BoxFit.cover,

                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return Container(
                          height: 200,

                          color: Colors
                              .grey.shade200,

                          child:
                              const Center(
                            child: Icon(
                              Icons
                                  .broken_image_outlined,

                              size: 50,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                if (imageUrl != null)
                  const SizedBox(
                    height: 20,
                  ),

                Text(
                  observation[
                          'commonName'] ??
                      'Sem nome comum',

                  style:
                      const TextStyle(
                    fontSize: 22,

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  observation[
                          'scientificName'] ??
                      'Espécie desconhecida',

                  style:
                      const TextStyle(
                    color: Colors.grey,

                    fontStyle:
                        FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 15),

                Row(
                  children: [
                    Icon(
                      _isValidated(
                              observation)
                          ? Icons.verified
                          : Icons
                              .schedule,

                      color: _statusColor(
                        observation,
                      ),
                    ),

                    const SizedBox(
                      width: 8,
                    ),

                    Text(
                      _statusText(
                        observation,
                      ),

                      style: TextStyle(
                        color:
                            _statusColor(
                          observation,
                        ),

                        fontWeight:
                            FontWeight
                                .w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Colors.grey,
                    ),

                    const SizedBox(
                      width: 8,
                    ),

                    Expanded(
                      child: Text(
                        'Lat: ${observation['latitude']}  '
                        'Lng: ${observation['longitude']}',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F7F3),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFFF4F7F3),

        elevation: 0,

        title: const Text(
          'Mapa de Biodiversidade',

          style: TextStyle(
            color: Colors.black87,
          ),
        ),

        centerTitle: true,
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
                'Não foi possível carregar '
                'as observações.\n'
                '${snapshot.error}',

                textAlign:
                    TextAlign.center,
              ),
            );
          }

          final observations =
              snapshot.data ?? [];

          final filteredObservations =
              _getFilteredObservations(
            observations,
          );

          return SingleChildScrollView(
            padding:
                const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                // PESQUISA
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim();
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
                          BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

              const SizedBox(height: 15),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,

              child: Row(
                children: [
                  _mainFilterChip('Todas'),
                  _mainFilterChip('Minhas'),
                  _mainFilterChip('Validadas'),
                  _mainFilterChip('Pendentes'),
                ],
              ),
            ),

                // FILTROS TAXONÓMICOS
                SingleChildScrollView(
                  scrollDirection:
                      Axis.horizontal,

                  child: Row(
                    children: [
                      _filterChip(
                        'Aves',
                      ),

                      _filterChip(
                        'Mamíferos',
                      ),

                      _filterChip(
                        'Insetos',
                      ),

                      _filterChip(
                        'Plantas',
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                // MAPA REAL
                Container(
                  width:
                      double.infinity,

                  height: 400,

                  clipBehavior:
                      Clip.antiAlias,

                  decoration:
                      BoxDecoration(
                    borderRadius:
                        BorderRadius
                            .circular(
                      20,
                    ),
                  ),

                  child:
                      filteredObservations.isEmpty
                          ? Container(
                              color: Colors
                                  .grey
                                  .shade200,

                              child:
                                  const Center(
                                child: Text(
                                  'Ainda não existem observações.',
                                ),
                              ),
                            )
                          : FlutterMap(
                              mapController:
                                  _mapController,

                              options:
                                  MapOptions(
                                initialCenter:
                                    LatLng(
                                  filteredObservations
                                      .first[
                                          'latitude'],

                                  filteredObservations
                                      .first[
                                          'longitude'],
                                ),

                                initialZoom:
                                    12,
                              ),

                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                                  userAgentPackageName:
                                      'com.example.bioregisto_mobile',
                                ),

                                MarkerLayer(
                                  markers:
                                      filteredObservations
                                          .map(
                                    (observation) {
                                      return Marker(
                                        point:
                                            LatLng(
                                          observation[
                                              'latitude'],

                                          observation[
                                              'longitude'],
                                        ),

                                        width:
                                            50,

                                        height:
                                            50,

                                        child:
                                            GestureDetector(
                                          onTap:
                                              () {
                                            _showObservationDetails(
                                              observation,
                                            );
                                          },

                                          child:
                                              Icon(
                                            Icons
                                                .location_on,

                                            size:
                                                42,

                                            color:
                                                _statusColor(
                                              observation,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ).toList(),
                                ),
                              ],
                            ),
                ),

                const SizedBox(
                  height: 15,
                ),

                // LEGENDA
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,

                  children: [
                    _legendItem(
                      Colors.green,
                      'Validada',
                    ),

                    const SizedBox(
                      width: 25,
                    ),

                    _legendItem(
                      Colors.orange,
                      'Pendente',
                    ),
                  ],
                ),

                const SizedBox(
                  height: 30,
                ),

                Text(
                  'Observações (${filteredObservations.length})',

                  style:
                      const TextStyle(
                    fontSize: 20,

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                if (filteredObservations.isEmpty)
                  const Center(
                    child: Padding(
                      padding:
                          EdgeInsets.all(
                        30,
                      ),

                      child: Text(
                        'Ainda não existem observações registadas.',
                      ),
                    ),
                  )
                else
                  ...filteredObservations.map(
                    (observation) =>
                        Padding(
                      padding:
                          const EdgeInsets
                              .only(
                        bottom: 10,
                      ),

                      child:
                          _observationTile(
                        observation,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _filterChip(
    String text,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
        right: 10,
      ),

      child: Chip(
        label: Text(text),

        avatar: const Icon(
          Icons.lock_outline,
          size: 16,
        ),
      ),
    );
  }

  Widget _legendItem(
    Color color,
    String text,
  ) {
    return Row(
      children: [
        Icon(
          Icons.location_on,
          color: color,
          size: 20,
        ),

        const SizedBox(width: 5),

        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _mainFilterChip(String text) {
  final selected =
      _selectedFilter == text;

  return Padding(
    padding: const EdgeInsets.only(
      right: 8,
    ),

    child: ChoiceChip(
      label: Text(text),

      selected: selected,

      onSelected: (_) {
        setState(() {
          _selectedFilter = text;
        });
      },

      selectedColor:
          AppColors.primary,

      labelStyle: TextStyle(
        color: selected
            ? Colors.white
            : Colors.black87,
      ),

      showCheckmark: false,
    ),
  );
}

  Widget _observationTile(
    dynamic observation,
  ) {
    final imageUrl =
        _getImageUrl(observation);

    return InkWell(
      onTap: () {
        _mapController.move(
          LatLng(
            observation['latitude'],
            observation['longitude'],
          ),
          16,
        );

        _showObservationDetails(
          observation,
        );
      },

      borderRadius:
          BorderRadius.circular(15),

      child: Container(
        padding:
            const EdgeInsets.all(12),

        decoration:
            BoxDecoration(
          color: Colors.white,

          borderRadius:
              BorderRadius.circular(
            15,
          ),
        ),

        child: Row(
          children: [
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(
                12,
              ),

              child: SizedBox(
                width: 60,
                height: 60,

                child: imageUrl != null
                    ? Image.network(
                        imageUrl,

                        fit: BoxFit.cover,

                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return Container(
                            color: Colors
                                .grey
                                .shade200,

                            child:
                                const Icon(
                              Icons
                                  .broken_image_outlined,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors
                            .grey
                            .shade200,

                        child:
                            const Icon(
                          Icons
                              .image_outlined,
                        ),
                      ),
              ),
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [
                  Text(
                    observation[
                            'commonName'] ??
                        'Sem nome comum',

                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    observation[
                            'scientificName'] ??
                        '',

                    style:
                        const TextStyle(
                      color:
                          Colors.grey,

                      fontSize: 12,

                      fontStyle:
                          FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            Text(
              _statusText(
                observation,
              ),

              style: TextStyle(
                color: _statusColor(
                  observation,
                ),

                fontSize: 12,

                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
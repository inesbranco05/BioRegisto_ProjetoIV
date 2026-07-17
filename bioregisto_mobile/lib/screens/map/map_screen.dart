import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  String _selectedDateFilter = 'Todas';
  String _selectedLocationName = '';
  LatLng? _selectedLocation;

  double _selectedRadius = 25;

  bool _isSearchingLocation = false;

  List<dynamic> _locationResults = [];

  @override
  void initState() {
    super.initState();

    _loadObservations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadObservations() {
    _observationsFuture =
        ApiService.getMapObservations();
  }

  Future<void> _refreshObservations() async {
    setState(() {
      _loadObservations();
    });

    await _observationsFuture;
  }

  // =========================
  // ESTADOS
  // =========================

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

  bool _isPending(
    dynamic observation,
  ) {
    return _getStatus(observation) ==
        'pending';
  }

  bool _isRejected(
    dynamic observation,
  ) {
    return _getStatus(observation) ==
        'rejected';
  }

  String _statusText(
    dynamic observation,
  ) {
    if (_isValidated(observation)) {
      return 'Validada';
    }

    return 'Pendente';
  }

  Color _statusColor(
    dynamic observation,
  ) {
    if (_isValidated(observation)) {
      return Colors.green;
    }

    return Colors.orange;
  }

  IconData _statusIcon(
    dynamic observation,
  ) {
    if (_isValidated(observation)) {
      return Icons.verified;
    }

    return Icons.schedule;
  }

  // =========================
  // IMAGEM
  // =========================

  String? _getImageUrl(
    dynamic observation,
  ) {
    final imageUrl =
        observation['imageUrl']
            ?.toString();

    if (imageUrl == null ||
        imageUrl.isEmpty) {
      return null;
    }

    if (imageUrl.startsWith('http')) {
      return imageUrl;
    }

    return '${ApiService.baseUrl.replaceFirst('/api', '')}$imageUrl';
  }

  // =========================
  // UTILIZADOR ATUAL
  // =========================

  bool _isMyObservation(
    dynamic observation,
  ) {
    final currentUserId =
        ApiService.currentUser?['id'];

    if (currentUserId == null) {
      return false;
    }

    return observation['userId']
            ?.toString() ==
        currentUserId.toString();
  }

  // =========================
  // FILTROS
  // =========================

  List<dynamic> _getFilteredObservations(
    List<dynamic> observations,
  ) {
    return observations.where(
      (observation) {
        // Nunca mostrar rejeitadas no mapa.
        if (_isRejected(observation)) {
          return false;
        }

        // PESQUISA
        final commonName =
            observation['commonName']
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
            _searchQuery
                .trim()
                .toLowerCase();

        final matchesSearch =
            commonName.contains(
                  search,
                ) ||
                scientificName
                    .contains(
                  search,
                );

        if (!matchesSearch) {
          return false;
        }
// FILTRO DE DATA
if (_selectedDateFilter != 'Todas') {
  final createdAt =
      observation['createdAt']
          ?.toString();

  if (createdAt == null) {
    return false;
  }

  final observationDate =
      DateTime.tryParse(
    createdAt,
  );

  if (observationDate == null) {
    return false;
  }

  final now =
      DateTime.now();

  if (_selectedDateFilter ==
      'Hoje') {
    final isToday =
        observationDate.year ==
                now.year &&
            observationDate.month ==
                now.month &&
            observationDate.day ==
                now.day;

    if (!isToday) {
      return false;
    }
  }

  if (_selectedDateFilter ==
      'Últimos 7 dias') {
    final limit =
        now.subtract(
      const Duration(
        days: 7,
      ),
    );

    if (observationDate.isBefore(
      limit,
    )) {
      return false;
    }
  }

  if (_selectedDateFilter ==
      'Últimos 30 dias') {
    final limit =
        now.subtract(
      const Duration(
        days: 30,
      ),
    );

    if (observationDate.isBefore(
      limit,
    )) {
      return false;
    }
  }
}

// FILTRO DE LOCALIZAÇÃO
if (_selectedLocation != null) {
  final latitude =
      double.tryParse(
    observation['latitude']
            ?.toString() ??
        '',
  );

  final longitude =
      double.tryParse(
    observation['longitude']
            ?.toString() ??
        '',
  );

  if (latitude == null ||
      longitude == null) {
    return false;
  }

  const distance =
      Distance();

  final distanceInMeters =
      distance.as(
    LengthUnit.Meter,
    _selectedLocation!,
    LatLng(
      latitude,
      longitude,
    ),
  );

  final distanceInKm =
      distanceInMeters / 1000;

  if (distanceInKm >
      _selectedRadius) {
    return false;
  }
}
        // FILTROS
      switch (_selectedFilter) {
  case 'Minhas':
    return _isMyObservation(
      observation,
    );

  case 'Validadas':
    return _isValidated(
      observation,
    );

  case 'Pendentes':
    return _isPending(
      observation,
    );

  case 'Todas':
  default:
    return true;
}
      },
    ).toList();
  }

  // =========================
  // DETALHES
  // =========================

  void _showObservationDetails(
    dynamic observation,
  ) {
    final imageUrl =
        _getImageUrl(
      observation,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent,

      builder: (context) {
        return Container(
          padding:
              const EdgeInsets.all(
            20,
          ),

          decoration:
              const BoxDecoration(
            color: Colors.white,

            borderRadius:
                BorderRadius.vertical(
              top:
                  Radius.circular(
                25,
              ),
            ),
          ),

          child: SafeArea(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,

              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [
                Center(
                  child: Container(
                    width: 45,
                    height: 5,

                    decoration:
                        BoxDecoration(
                      color: Colors
                          .grey
                          .shade300,

                      borderRadius:
                          BorderRadius
                              .circular(
                        10,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                if (imageUrl != null)
                  ClipRRect(
                    borderRadius:
                        BorderRadius
                            .circular(
                      18,
                    ),

                    child:
                        Image.network(
                      imageUrl,

                      width:
                          double.infinity,

                      height: 200,

                      fit:
                          BoxFit.cover,

                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return Container(
                          height: 200,

                          color: Colors
                              .grey
                              .shade200,

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

                const SizedBox(
                  height: 5,
                ),

                Text(
                  observation[
                          'scientificName'] ??
                      'Espécie desconhecida',

                  style:
                      const TextStyle(
                    color:
                        Colors.grey,

                    fontStyle:
                        FontStyle.italic,
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                Row(
                  children: [
                    Icon(
                      _statusIcon(
                        observation,
                      ),

                      color:
                          _statusColor(
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

                      style:
                          TextStyle(
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

                const SizedBox(
                  height: 15,
                ),

                Row(
                  children: [
                    const Icon(
                      Icons
                          .location_on_outlined,

                      color:
                          Colors.grey,
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

                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
 // =========================
  // PESQUISA- LOCALIZAÇÃO
  // =========================

Future<void> _searchLocation(
  String query,
  StateSetter setModalState,
) async {
  if (query.trim().length < 3) {
    setModalState(() {
      _locationResults = [];
    });

    return;
  }

  setModalState(() {
    _isSearchingLocation = true;
  });

  try {
    final uri = Uri.https(
      'nominatim.openstreetmap.org',
      '/search',
      {
        'q': query,
        'format': 'json',
        'limit': '5',
        'countrycodes': 'pt',
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'User-Agent':
            'BioRegisto/1.0',
      },
    );

    if (response.statusCode == 200) {
      final results =
          jsonDecode(response.body);

      setModalState(() {
        _locationResults =
            results is List
                ? results
                : [];
      });
    }
  } catch (error) {
    setModalState(() {
      _locationResults = [];
    });
  } finally {
    setModalState(() {
      _isSearchingLocation =
          false;
    });
  }
}

   // =========================
  // PAINEL DE FILTROS
  // =========================

 void _showFilters() {
  String temporaryDateFilter =
      _selectedDateFilter;

  LatLng? temporaryLocation =
      _selectedLocation;

  String temporaryLocationName =
      _selectedLocationName;

  double temporaryRadius =
      _selectedRadius;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,

    builder: (
      bottomSheetContext,
    ) {
      return StatefulBuilder(
        builder: (
          context,
          setModalState,
        ) {
          return Container(
            padding:
                const EdgeInsets.all(
              24,
            ),

            decoration:
                const BoxDecoration(
              color: Colors.white,

              borderRadius:
                  BorderRadius.vertical(
                top: Radius.circular(
                  25,
                ),
              ),
            ),

            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,

                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    Center(
                      child: Container(
                        width: 45,
                        height: 5,

                        decoration:
                            BoxDecoration(
                          color: Colors
                              .grey
                              .shade300,

                          borderRadius:
                              BorderRadius
                                  .circular(
                            10,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    const Text(
                      'Filtrar observações',

                      style: TextStyle(
                        fontSize: 22,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    // DATA
                    const Text(
                      'Data',

                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,

                      children: [
                        'Todas',
                        'Hoje',
                        'Últimos 7 dias',
                        'Últimos 30 dias',
                      ].map(
                        (filter) {
                          final selected =
                              temporaryDateFilter ==
                                  filter;

                          return ChoiceChip(
                            label: Text(
                              filter,
                            ),

                            selected:
                                selected,

                            selectedColor:
                                AppColors
                                    .primary
                                    .withOpacity(
                              0.15,
                            ),

                            onSelected: (_) {
                              setModalState(
                                () {
                                  temporaryDateFilter =
                                      filter;
                                },
                              );
                            },
                          );
                        },
                      ).toList(),
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    // LOCALIZAÇÃO
                    const Text(
                      'Localização',

                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    TextField(
                      decoration:
                          InputDecoration(
                        hintText:
                            'Pesquisar cidade ou localidade...',

                        prefixIcon:
                            const Icon(
                          Icons.search,
                        ),

                        filled: true,

                        fillColor:
                            Colors
                                .grey
                                .shade100,

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

                      onChanged: (
                        value,
                      ) {
                        _searchLocation(
                          value,
                          setModalState,
                        );
                      },
                    ),

                    if (_isSearchingLocation)
                      const Padding(
                        padding:
                            EdgeInsets.all(
                          15,
                        ),

                        child: Center(
                          child:
                              CircularProgressIndicator(),
                        ),
                      ),

                    if (_locationResults
                        .isNotEmpty)
                      Container(
                        margin:
                            const EdgeInsets
                                .only(
                          top: 8,
                        ),

                        constraints:
                            const BoxConstraints(
                          maxHeight: 180,
                        ),

                        decoration:
                            BoxDecoration(
                          color: Colors
                              .grey
                              .shade50,

                          borderRadius:
                              BorderRadius
                                  .circular(
                            15,
                          ),
                        ),

                        child:
                            ListView.builder(
                          shrinkWrap: true,

                          itemCount:
                              _locationResults
                                  .length,

                          itemBuilder: (
                            context,
                            index,
                          ) {
                            final location =
                                _locationResults[
                                    index];

                            return ListTile(
                              leading:
                                  const Icon(
                                Icons
                                    .location_on_outlined,
                              ),

                              title: Text(
                                location[
                                        'display_name'] ??
                                    '',

                                maxLines: 2,

                                overflow:
                                    TextOverflow
                                        .ellipsis,
                              ),

                              onTap: () {
                                final latitude =
                                    double.tryParse(
                                  location['lat']
                                          ?.toString() ??
                                      '',
                                );

                                final longitude =
                                    double.tryParse(
                                  location['lon']
                                          ?.toString() ??
                                      '',
                                );

                                if (latitude ==
                                        null ||
                                    longitude ==
                                        null) {
                                  return;
                                }

                                setModalState(
                                  () {
                                    temporaryLocation =
                                        LatLng(
                                      latitude,
                                      longitude,
                                    );

                                    temporaryLocationName =
                                        location[
                                                'display_name']
                                            ?.toString() ??
                                        '';

                                    _locationResults =
                                        [];
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),

                    // LOCALIZAÇÃO SELECIONADA
                    if (temporaryLocation !=
                        null) ...[
                      const SizedBox(
                        height: 12,
                      ),

                      Container(
                        width:
                            double.infinity,

                        padding:
                            const EdgeInsets
                                .all(
                          12,
                        ),

                        decoration:
                            BoxDecoration(
                          color: AppColors
                              .primary
                              .withOpacity(
                            0.08,
                          ),

                          borderRadius:
                              BorderRadius
                                  .circular(
                            15,
                          ),
                        ),

                        child: Row(
                          children: [
                            Icon(
                              Icons
                                  .location_on,

                              color: AppColors
                                  .primary,
                            ),

                            const SizedBox(
                              width: 8,
                            ),

                            Expanded(
                              child: Text(
                                temporaryLocationName,

                                maxLines: 2,

                                overflow:
                                    TextOverflow
                                        .ellipsis,
                              ),
                            ),

                            IconButton(
                              onPressed:
                                  () {
                                setModalState(
                                  () {
                                    temporaryLocation =
                                        null;

                                    temporaryLocationName =
                                        '';

                                    _locationResults =
                                        [];
                                  },
                                );
                              },

                              icon:
                                  const Icon(
                                Icons.close,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      // RAIO
                      const Text(
                        'Raio da pesquisa',

                        style:
                            TextStyle(
                          fontSize: 16,

                          fontWeight:
                              FontWeight
                                  .w600,
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,

                        children: [
                          5.0,
                          25.0,
                          50.0,
                        ].map(
                          (radius) {
                            final selected =
                                temporaryRadius ==
                                    radius;

                            return ChoiceChip(
                              label: Text(
                                '${radius.toInt()} km',
                              ),

                              selected:
                                  selected,

                              selectedColor:
                                  AppColors
                                      .primary
                                      .withOpacity(
                                0.15,
                              ),

                              onSelected:
                                  (_) {
                                setModalState(
                                  () {
                                    temporaryRadius =
                                        radius;
                                  },
                                );
                              },
                            );
                          },
                        ).toList(),
                      ),
                    ],

                    const SizedBox(
                      height: 30,
                    ),

                    // APLICAR
                    SizedBox(
                      width:
                          double.infinity,

                      child:
                          ElevatedButton(
                        onPressed: () {
                          setState(
                            () {
                              _selectedDateFilter =
                                  temporaryDateFilter;

                              _selectedLocation =
                                  temporaryLocation;

                              _selectedLocationName =
                                  temporaryLocationName;

                              _selectedRadius =
                                  temporaryRadius;
                            },
                          );

                          if (temporaryLocation !=
                              null) {
                            _mapController
                                .move(
                              temporaryLocation!,
                              11,
                            );
                          }

                          Navigator.pop(
                            bottomSheetContext,
                          );
                        },

                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              AppColors
                                  .primary,

                          foregroundColor:
                              Colors.white,

                          padding:
                              const EdgeInsets
                                  .symmetric(
                            vertical: 15,
                          ),
                        ),

                        child:
                            const Text(
                          'Aplicar filtros',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(
        0xFFF4F7F3,
      ),

      appBar: AppBar(
        backgroundColor:
            const Color(
          0xFFF4F7F3,
        ),

        elevation: 0,

        title: const Text(
          'Mapa de Biodiversidade',

          style: TextStyle(
            color:
                Colors.black87,
          ),
        ),

        centerTitle: true,

        actions: [
          IconButton(
            tooltip:
                'Atualizar mapa',

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
        future:
            _observationsFuture,

        builder: (
          context,
          snapshot,
        ) {
          if (snapshot
                  .connectionState ==
              ConnectionState
                  .waiting) {
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
                    const EdgeInsets
                        .all(
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
                          TextAlign
                              .center,
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

                      icon:
                          const Icon(
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

          final filteredObservations =
              _getFilteredObservations(
            observations,
          );

          return RefreshIndicator(
            onRefresh:
                _refreshObservations,

            child:
                SingleChildScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(),

              padding:
                  const EdgeInsets
                      .all(
                20,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [
                  // PESQUISA
               Row(
  children: [
    Expanded(
      child: TextField(
        controller:
            _searchController,

        onChanged: (
          value,
        ) {
          setState(() {
            _searchQuery =
                value;
          });
        },

        decoration:
            InputDecoration(
          hintText:
              'Pesquisar espécie.',

          prefixIcon:
              const Icon(
            Icons.search,
          ),

          suffixIcon:
              _searchQuery
                      .isNotEmpty
                  ? IconButton(
                      onPressed:
                          () {
                        _searchController
                            .clear();

                        setState(
                          () {
                            _searchQuery =
                                '';
                          },
                        );
                      },

                      icon:
                          const Icon(
                        Icons.close,
                      ),
                    )
                  : null,

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
    ),

    const SizedBox(
      width: 10,
    ),

   Material(
  color:
      _selectedDateFilter !=
              'Todas'
          ? AppColors.primary
          : Colors.white,

  borderRadius:
      BorderRadius.circular(
    15,
  ),

  child: InkWell(
    onTap: _showFilters,

    borderRadius:
        BorderRadius.circular(
      15,
    ),

    child: SizedBox(
      width: 56,
      height: 56,

      child: Icon(
        Icons.tune,

        color:
            _selectedDateFilter !=
                    'Todas'
                ? Colors.white
                : AppColors.primary,
      ),
    ),
  ),
),
  ],
),

                  const SizedBox(
                    height: 15,
                  ),

                  // FILTROS
                  SingleChildScrollView(
                    scrollDirection:
                        Axis.horizontal,

                    child: Row(
                      children: [
                        _mainFilterChip(
                          'Todas',
                        ),

                        _mainFilterChip(
                          'Minhas',
                        ),

                        _mainFilterChip(
                          'Validadas',
                        ),

                        _mainFilterChip(
                          'Pendentes',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // MAPA
                  ClipRRect(
                    borderRadius:
                        BorderRadius
                            .circular(
                      20,
                    ),

                    child: SizedBox(
                      height: 430,

                      child:
                          filteredObservations
                                  .isEmpty
                              ? Container(
                                  color: Colors
                                      .grey
                                      .shade200,

                                  child:
                                      const Center(
                                    child:
                                        Padding(
                                      padding:
                                          EdgeInsets
                                              .all(
                                        20,
                                      ),

                                      child:
                                          Text(
                                        'Não existem observações para apresentar com estes filtros.',

                                        textAlign:
                                            TextAlign
                                                .center,
                                      ),
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
                                      (filteredObservations.first[
                                                  'latitude']
                                              as num)
                                          .toDouble(),

                                      (filteredObservations.first[
                                                  'longitude']
                                              as num)
                                          .toDouble(),
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
                                        (
                                          observation,
                                        ) {
                                          return Marker(
                                            point:
                                                LatLng(
                                              (observation['latitude']
                                                      as num)
                                                  .toDouble(),

                                              (observation['longitude']
                                                      as num)
                                                  .toDouble(),
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
                          FontWeight
                              .bold,
                    ),
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  if (filteredObservations
                      .isEmpty)
                    const Center(
                      child: Padding(
                        padding:
                            EdgeInsets.all(
                          30,
                        ),

                        child: Text(
                          'Nenhuma observação encontrada.',
                        ),
                      ),
                    )
                  else
                    ...filteredObservations
                        .map(
                      (
                        observation,
                      ) =>
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
            ),
          );
        },
      ),
    );
  }

  // =========================
  // FILTRO
  // =========================

  Widget _mainFilterChip(
    String text,
  ) {
    final selected =
        _selectedFilter ==
            text;

    return Padding(
      padding:
          const EdgeInsets.only(
        right: 8,
      ),

      child: ChoiceChip(
        label:
            Text(text),

        selected:
            selected,

        onSelected: (_) {
          setState(() {
            _selectedFilter =
                text;
          });
        },

        selectedColor:
            AppColors.primary,

        labelStyle:
            TextStyle(
          color: selected
              ? Colors.white
              : Colors.black87,
        ),

        showCheckmark:
            false,
      ),
    );
  }

  // =========================
  // LEGENDA
  // =========================

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

        const SizedBox(
          width: 5,
        ),

        Text(
          text,

          style:
              const TextStyle(
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // =========================
  // CARTÃO DA OBSERVAÇÃO
  // =========================

  Widget _observationTile(
    dynamic observation,
  ) {
    final imageUrl =
        _getImageUrl(
      observation,
    );

    return InkWell(
      onTap: () {
        _mapController.move(
          LatLng(
            (observation['latitude']
                    as num)
                .toDouble(),

            (observation['longitude']
                    as num)
                .toDouble(),
          ),

          16,
        );

        _showObservationDetails(
          observation,
        );
      },

      borderRadius:
          BorderRadius.circular(
        15,
      ),

      child: Container(
        padding:
            const EdgeInsets.all(
          12,
        ),

        decoration:
            BoxDecoration(
          color:
              Colors.white,

          borderRadius:
              BorderRadius.circular(
            15,
          ),
        ),

        child: Row(
          children: [
            ClipRRect(
              borderRadius:
                  BorderRadius
                      .circular(
                12,
              ),

              child: SizedBox(
                width: 60,
                height: 60,

                child: imageUrl !=
                        null
                    ? Image.network(
                        imageUrl,

                        fit:
                            BoxFit.cover,

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
                          FontWeight
                              .bold,
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
                          FontStyle
                              .italic,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              width: 8,
            ),

            Row(
              mainAxisSize:
                  MainAxisSize.min,

              children: [
                Icon(
                  _statusIcon(
                    observation,
                  ),

                  size: 16,

                  color:
                      _statusColor(
                    observation,
                  ),
                ),

                const SizedBox(
                  width: 4,
                ),

                Text(
                  _statusText(
                    observation,
                  ),

                  style:
                      TextStyle(
                    color:
                        _statusColor(
                      observation,
                    ),

                    fontSize: 12,

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
    );
  }
}
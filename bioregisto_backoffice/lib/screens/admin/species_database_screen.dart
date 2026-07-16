import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../utils/app_colors.dart';

class SpeciesDatabaseScreen
    extends StatefulWidget {
  const SpeciesDatabaseScreen({
    super.key,
  });

  @override
  State<SpeciesDatabaseScreen>
      createState() =>
          _SpeciesDatabaseScreenState();
}

class _SpeciesDatabaseScreenState
    extends State<SpeciesDatabaseScreen> {
  List<dynamic> _species = [];
  List<dynamic> _filteredSpecies = [];

  bool _isLoading = true;

  final TextEditingController
      _searchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSpecies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSpecies() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final species =
          await ApiService
              .getSpeciesDatabase();

      if (!mounted) return;

      setState(() {
        _species = species;
        _filteredSpecies = species;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível carregar as espécies.',
          ),
        ),
      );
    }
  }

  void _filterSpecies(
    String value,
  ) {
    final query =
        value.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredSpecies = _species;
        return;
      }

      _filteredSpecies =
          _species.where((item) {
        final values = [
          item['commonName'],
          item['species'],
          item['genus'],
          item['family'],
          item['order'],
          item['class'],
          item['phylum'],
          item['kingdom'],
        ];

        return values.any(
          (value) =>
              value
                  ?.toString()
                  .toLowerCase()
                  .contains(query) ??
              false,
        );
      }).toList();
    });
  }

  String _value(
    dynamic value,
  ) {
    if (value == null ||
        value.toString().isEmpty) {
      return '—';
    }

    return value.toString();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          AppColors.background,

      appBar: AppBar(
        backgroundColor:
            AppColors.background,

        foregroundColor:
            Colors.black87,

        elevation: 0,

        title: const Text(
          'Base de Dados de Espécies',
        ),

        actions: [
          IconButton(
            onPressed: _loadSpecies,
            tooltip: 'Atualizar',
            icon: const Icon(
              Icons.refresh,
            ),
          ),

          const SizedBox(width: 20),
        ],
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(30),

        child: Container(
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
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [
                      const Text(
                        'Espécies registadas',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      Text(
                        '${_species.length} espécies na base de dados',
                        style:
                            const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    width: 350,

                    child: TextField(
                      controller:
                          _searchController,

                      onChanged:
                          _filterSpecies,

                      decoration:
                          InputDecoration(
                        hintText:
                            'Pesquisar espécie ou taxonomia...',

                        prefixIcon:
                            const Icon(
                          Icons.search,
                        ),

                        filled: true,

                        fillColor:
                            Colors.grey
                                .shade50,

                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            12,
                          ),

                          borderSide:
                              BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              Expanded(
                child: _isLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(),
                      )
                    : _filteredSpecies
                            .isEmpty
                        ? const Center(
                            child: Text(
                              'Não foram encontradas espécies.',
                              style:
                                  TextStyle(
                                color:
                                    Colors.grey,
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            child:
                                SingleChildScrollView(
                              scrollDirection:
                                  Axis.horizontal,

                              child: DataTable(
                                headingRowColor:
                                    WidgetStatePropertyAll(
                                  AppColors
                                      .primary
                                      .withOpacity(
                                    0.08,
                                  ),
                                ),

                                columns:
                                    const [
                                      DataColumn(
                                        label: Text(
                                          'Nome comum',
                                        ),
                                      ),
                                  DataColumn(
                                    label: Text(
                                      'Espécie',
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Género',
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Família',
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Ordem',
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Classe',
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Filo',
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Reino',
                                    ),
                                  ),
                                ],

                                rows:
                                    _filteredSpecies
                                        .map(
                                  (item) {
                                    return DataRow(
                                      cells: [
                                          DataCell(
                                            Text(
                                              _value(
                                                item['commonName'],
                                              ),
                                            ),
                                          ),
                                        DataCell(
                                          Text(
                                            _value(
                                              item[
                                                  'species'],
                                            ),
                                            style:
                                                const TextStyle(
                                              fontStyle:
                                                  FontStyle
                                                      .italic,
                                              fontWeight:
                                                  FontWeight
                                                      .w600,
                                            ),
                                          ),
                                        ),

                                        DataCell(
                                          Text(
                                            _value(
                                              item[
                                                  'genus'],
                                            ),
                                          ),
                                        ),

                                        DataCell(
                                          Text(
                                            _value(
                                              item[
                                                  'family'],
                                            ),
                                          ),
                                        ),

                                        DataCell(
                                          Text(
                                            _value(
                                              item[
                                                  'order'],
                                            ),
                                          ),
                                        ),

                                        DataCell(
                                          Text(
                                            _value(
                                              item[
                                                  'class'],
                                            ),
                                          ),
                                        ),

                                        DataCell(
                                          Text(
                                            _value(
                                              item[
                                                  'phylum'],
                                            ),
                                          ),
                                        ),

                                        DataCell(
                                          Text(
                                            _value(
                                              item[
                                                  'kingdom'],
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ).toList(),
                              ),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../utils/app_colors.dart';

class ObservationsManagementScreen
    extends StatefulWidget {
  const ObservationsManagementScreen({
    super.key,
  });

  @override
  State<ObservationsManagementScreen>
      createState() =>
          _ObservationsManagementScreenState();
}

class _ObservationsManagementScreenState
    extends State<ObservationsManagementScreen> {
  List<dynamic> _observations = [];

  bool _isLoading = true;

  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();

    _loadObservations();
  }

  Future<void> _loadObservations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final observations =
          await ApiService
              .getAdminObservations();

      if (!mounted) return;

      setState(() {
        _observations = observations;
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
            'Não foi possível carregar as observações.',
          ),
        ),
      );
    }
  }

  List<dynamic> get _filteredObservations {
    if (_selectedFilter == 'All') {
      return _observations;
    }

    return _observations.where(
      (observation) {
        return observation['status']
                ?.toString()
                .toLowerCase() ==
            _selectedFilter.toLowerCase();
      },
    ).toList();
  }

  int _countStatus(
    String status,
  ) {
    return _observations.where(
      (observation) {
        return observation['status']
                ?.toString()
                .toLowerCase() ==
            status.toLowerCase();
      },
    ).length;
  }

  String _statusLabel(
    String? status,
  ) {
    switch (status
        ?.toLowerCase()) {
      case 'validated':
        return 'Aprovada';

      case 'rejected':
        return 'Rejeitada';

      case 'pending':
        return 'Pendente';

      default:
        return status ?? '—';
    }
  }

  Color _statusColor(
    String? status,
  ) {
    switch (status
        ?.toLowerCase()) {
      case 'validated':
        return Colors.green;

      case 'rejected':
        return Colors.red;

      case 'pending':
        return Colors.orange;

      default:
        return Colors.grey;
    }
  }

  String _formatDate(
    dynamic value,
  ) {
    if (value == null) {
      return '—';
    }

    final date =
        DateTime.tryParse(
      value.toString(),
    );

    if (date == null) {
      return '—';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final filtered =
        _filteredObservations;

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
          'Monitorização de Observações',
        ),

        actions: [
          IconButton(
            onPressed:
                _loadObservations,

            tooltip: 'Atualizar',

            icon: const Icon(
              Icons.refresh,
            ),
          ),

          const SizedBox(width: 20),
        ],
      ),

      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.all(
                30,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [
                  // RESUMO
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,

                    children: [
                      _summaryCard(
                        title: 'Total',
                        value:
                            _observations
                                .length,
                        icon:
                            Icons
                                .visibility_outlined,
                      ),

                      _summaryCard(
                        title: 'Pendentes',
                        value:
                            _countStatus(
                          'Pending',
                        ),
                        icon:
                            Icons
                                .schedule_outlined,
                      ),

                      _summaryCard(
                        title: 'Aprovadas',
                        value:
                            _countStatus(
                          'Validated',
                        ),
                        icon:
                            Icons
                                .check_circle_outline,
                      ),

                      _summaryCard(
                        title: 'Rejeitadas',
                        value:
                            _countStatus(
                          'Rejected',
                        ),
                        icon:
                            Icons
                                .cancel_outlined,
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  Container(
                    width:
                        double.infinity,

                    padding:
                        const EdgeInsets
                            .all(25),

                    decoration:
                        BoxDecoration(
                      color:
                          Colors.white,

                      borderRadius:
                          BorderRadius
                              .circular(
                        20,
                      ),
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [
                        const Text(
                          'Todas as observações',

                          style:
                              TextStyle(
                            fontSize: 22,

                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        Wrap(
                          spacing: 10,

                          children: [
                            _filterChip(
                              'Todas',
                              'All',
                            ),

                            _filterChip(
                              'Pendentes',
                              'Pending',
                            ),

                            _filterChip(
                              'Aprovadas',
                              'Validated',
                            ),

                            _filterChip(
                              'Rejeitadas',
                              'Rejected',
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 25,
                        ),

                        if (filtered
                            .isEmpty)
                          const Padding(
                            padding:
                                EdgeInsets
                                    .all(
                              40,
                            ),

                            child: Center(
                              child: Text(
                                'Não existem observações neste estado.',

                                style:
                                    TextStyle(
                                  color:
                                      Colors
                                          .grey,
                                ),
                              ),
                            ),
                          )
                        else
                          SingleChildScrollView(
                            scrollDirection:
                                Axis
                                    .horizontal,

                            child:
                                DataTable(
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
                                  label:
                                      Text(
                                    'Espécie',
                                  ),
                                ),

                                DataColumn(
                                  label:
                                      Text(
                                    'Nome comum',
                                  ),
                                ),

                                DataColumn(
                                  label:
                                      Text(
                                    'Utilizador',
                                  ),
                                ),

                                DataColumn(
                                  label:
                                      Text(
                                    'Data',
                                  ),
                                ),

                                DataColumn(
                                  label:
                                      Text(
                                    'Estado',
                                  ),
                                ),
                              ],

                              rows:
                                  filtered
                                      .map(
                                (
                                  observation,
                                ) {
                                  final status =
                                      observation[
                                              'status']
                                          ?.toString();

                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          observation[
                                                  'scientificName'] ??
                                              '—',

                                          style:
                                              const TextStyle(
                                            fontStyle:
                                                FontStyle
                                                    .italic,
                                          ),
                                        ),
                                      ),

                                      DataCell(
                                        Text(
                                          observation[
                                                  'commonName'] ??
                                              '—',
                                        ),
                                      ),

                                      DataCell(
                                        Text(
                                          observation[
                                                  'userName'] ??
                                              '—',
                                        ),
                                      ),

                                      DataCell(
                                        Text(
                                          _formatDate(
                                            observation[
                                                'createdAt'],
                                          ),
                                        ),
                                      ),

                                      DataCell(
                                        Container(
                                          padding:
                                              const EdgeInsets
                                                  .symmetric(
                                            horizontal:
                                                10,
                                            vertical:
                                                5,
                                          ),

                                          decoration:
                                              BoxDecoration(
                                            color:
                                                _statusColor(
                                              status,
                                            ).withOpacity(
                                              0.10,
                                            ),

                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                              20,
                                            ),
                                          ),

                                          child:
                                              Text(
                                            _statusLabel(
                                              status,
                                            ),

                                            style:
                                                TextStyle(
                                              color:
                                                  _statusColor(
                                                status,
                                              ),

                                              fontWeight:
                                                  FontWeight
                                                      .w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
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
            ),
    );
  }

  Widget _summaryCard({
    required String title,
    required int value,
    required IconData icon,
  }) {
    return Container(
      width: 220,
      padding:
          const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(18),
      ),

      child: Row(
        children: [
          Container(
            padding:
                const EdgeInsets.all(
              12,
            ),

            decoration:
                BoxDecoration(
              color:
                  AppColors.primary
                      .withOpacity(
                0.10,
              ),

              borderRadius:
                  BorderRadius
                      .circular(
                12,
              ),
            ),

            child: Icon(
              icon,
              color:
                  AppColors.primary,
            ),
          ),

          const SizedBox(
            width: 15,
          ),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,

            children: [
              Text(
                value.toString(),

                style:
                    const TextStyle(
                  fontSize: 25,

                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              Text(
                title,

                style:
                    const TextStyle(
                  color:
                      Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterChip(
    String label,
    String value,
  ) {
    final selected =
        _selectedFilter == value;

    return ChoiceChip(
      label: Text(label),

      selected: selected,

      selectedColor:
          AppColors.primary
              .withOpacity(0.15),

      labelStyle: TextStyle(
        color: selected
            ? AppColors.primary
            : Colors.black87,

        fontWeight: selected
            ? FontWeight.w600
            : FontWeight.normal,
      ),

      onSelected: (_) {
        setState(() {
          _selectedFilter =
              value;
        });
      },
    );
  }
}
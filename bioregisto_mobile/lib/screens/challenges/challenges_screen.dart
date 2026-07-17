import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../utils/app_colors.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({
    super.key,
  });

  @override
  State<ChallengesScreen> createState() =>
      _ChallengesScreenState();
}

class _ChallengesScreenState
    extends State<ChallengesScreen> {
  List<dynamic> _items = [];

  bool _isLoading = true;

  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();

    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final items =
          await ApiService
              .getEventChallenges();

      if (!mounted) return;

      setState(() {
        // No mobile mostramos apenas
        // eventos e desafios ativos.
        _items = items
            .where(
              (item) =>
                  item['isActive'] ==
                  true,
            )
            .toList();

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
            'Não foi possível carregar os eventos e desafios.',
          ),
        ),
      );
    }
  }

  List<dynamic> get _filteredItems {
    if (_selectedFilter == 'All') {
      return _items;
    }

    return _items
        .where(
          (item) =>
              item['type'] ==
              _selectedFilter,
        )
        .toList();
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
    )?.toLocal();

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
    final filteredItems =
        _filteredItems;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F7F3),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFFD39B73),

        elevation: 0,

        iconTheme:
            const IconThemeData(
          color: Colors.white,
        ),

        actions: [
          IconButton(
            tooltip: 'Atualizar',

            onPressed: _loadItems,

            icon: const Icon(
              Icons.refresh,
            ),
          ),

          const SizedBox(
            width: 8,
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _loadItems,

        child: ListView(
          children: [
            // HEADER
            Container(
              width:
                  double.infinity,

              padding:
                  const EdgeInsets.all(
                25,
              ),

              decoration:
                  const BoxDecoration(
                color:
                    Color(0xFFD39B73),

                borderRadius:
                    BorderRadius.only(
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

              child: const Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [
                  Text(
                    'Eventos e Desafios',

                    style: TextStyle(
                      color:
                          Colors.white,

                      fontSize: 28,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  SizedBox(
                    height: 8,
                  ),

                  Text(
                    'Participa em iniciativas e descobre a biodiversidade à tua volta.',

                    style: TextStyle(
                      color:
                          Colors.white70,

                      height: 1.4,
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
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [
                  const Text(
                    'Explora e participa',

                    style: TextStyle(
                      fontSize: 22,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  const Text(
                    'Consulta os eventos e desafios disponíveis na comunidade BioRegisto.',

                    style: TextStyle(
                      color:
                          Colors.grey,

                      height: 1.4,
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
                      _filterChip(
                        'Todos',
                        'All',
                      ),

                      _filterChip(
                        'Eventos',
                        'Event',
                      ),

                      _filterChip(
                        'Desafios',
                        'Challenge',
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  if (_isLoading)
                    Padding(
                      padding:
                          const EdgeInsets
                              .all(
                        50,
                      ),

                      child: Center(
                        child:
                            CircularProgressIndicator(
                          color:
                              AppColors
                                  .primary,
                        ),
                      ),
                    )
                  else if (filteredItems
                      .isEmpty)
                    _emptyState()
                  else
                    ...filteredItems.map(
                      (item) {
                        return Padding(
                          padding:
                              const EdgeInsets
                                  .only(
                            bottom: 15,
                          ),

                          child:
                              _itemCard(
                            item,
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(
    String label,
    String value,
  ) {
    final selected =
        _selectedFilter ==
            value;

    return ChoiceChip(
      label: Text(label),

      selected: selected,

      selectedColor:
          AppColors.primary
              .withOpacity(
        0.15,
      ),

      backgroundColor:
          Colors.white,

      labelStyle: TextStyle(
        color: selected
            ? AppColors.primary
            : Colors.black87,

        fontWeight: selected
            ? FontWeight.w600
            : FontWeight.normal,
      ),

      side: BorderSide(
        color: selected
            ? AppColors.primary
            : Colors.grey.shade300,
      ),

      onSelected: (_) {
        setState(() {
          _selectedFilter =
              value;
        });
      },
    );
  }

  Widget _itemCard(
    dynamic item,
  ) {
    final bool isChallenge =
        item['type'] ==
            'Challenge';

    final startDate =
        _formatDate(
      item['startDate'],
    );

    final endDate =
        _formatDate(
      item['endDate'],
    );

    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.all(
        20,
      ),

      decoration:
          BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          20,
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black
                    .withOpacity(
              0.04,
            ),

            blurRadius: 10,

            offset:
                const Offset(
              0,
              3,
            ),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,

        children: [
          // TIPO
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets
                        .all(
                  10,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      AppColors
                          .primary
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
                  isChallenge
                      ? Icons
                          .emoji_events_outlined
                      : Icons
                          .event_outlined,

                  color:
                      AppColors.primary,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      AppColors
                          .primary
                          .withOpacity(
                    0.10,
                  ),

                  borderRadius:
                      BorderRadius
                          .circular(
                    20,
                  ),
                ),

                child: Text(
                  isChallenge
                      ? 'DESAFIO'
                      : 'EVENTO',

                  style: TextStyle(
                    color:
                        AppColors.primary,

                    fontSize: 11,

                    fontWeight:
                        FontWeight.bold,

                    letterSpacing:
                        0.8,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 18,
          ),

          // TÍTULO
          Text(
            item['title'] ??
                'Sem título',

            style:
                const TextStyle(
              fontSize: 19,

              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          // DESCRIÇÃO
          Text(
            item['description'] ??
                '',

            style:
                const TextStyle(
              color:
                  Colors.black54,

              height: 1.5,
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          const Divider(),

          const SizedBox(
            height: 12,
          ),

          // DATAS
          Row(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,

            children: [
              Icon(
                Icons
                    .calendar_today_outlined,

                size: 18,

                color:
                    AppColors.primary,
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    const Text(
                      'Período',

                      style:
                          TextStyle(
                        fontSize: 12,

                        color:
                            Colors.grey,
                      ),
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      '$startDate - $endDate',

                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    String message;

    if (_selectedFilter ==
        'Event') {
      message =
          'Não existem eventos disponíveis.';
    } else if (_selectedFilter ==
        'Challenge') {
      message =
          'Não existem desafios disponíveis.';
    } else {
      message =
          'Não existem eventos ou desafios disponíveis.';
    }

    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.all(
        45,
      ),

      decoration:
          BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),

      child: Column(
        children: [
          Icon(
            Icons
                .emoji_events_outlined,

            size: 55,

            color:
                Colors.grey.shade400,
          ),

          const SizedBox(
            height: 15,
          ),

          Text(
            message,

            textAlign:
                TextAlign.center,

            style:
                const TextStyle(
              color:
                  Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../utils/app_colors.dart';

class EventsChallengesManagementScreen
    extends StatefulWidget {
  const EventsChallengesManagementScreen({
    super.key,
  });

  @override
  State<EventsChallengesManagementScreen>
      createState() =>
          _EventsChallengesManagementScreenState();
}

class _EventsChallengesManagementScreenState
    extends State<
        EventsChallengesManagementScreen> {
  List<dynamic> _items = [];

  bool _isLoading = true;

  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final items =
          await ApiService
              .getEventChallenges();

      if (!mounted) return;

      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Não foi possível carregar os eventos e desafios.',
      );
    }
  }

  List<dynamic> get _filteredItems {
    if (_filter == 'All') {
      return _items;
    }

    return _items
        .where(
          (item) =>
              item['type'] == _filter,
        )
        .toList();
  }

  Future<void> _showCreateDialog() async {
    final titleController =
        TextEditingController();

    final descriptionController =
        TextEditingController();

    String type = 'Challenge';

    DateTime startDate =
        DateTime.now();

    DateTime endDate =
        DateTime.now().add(
      const Duration(days: 30),
    );

    final created =
        await showDialog<bool>(
      context: context,

      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Text(
                'Criar evento ou desafio',
              ),

              content: SizedBox(
                width: 500,

                child:
                    SingleChildScrollView(
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,

                    children: [
                      DropdownButtonFormField<
                          String>(
                        value: type,

                        decoration:
                            const InputDecoration(
                          labelText: 'Tipo',
                          border:
                              OutlineInputBorder(),
                        ),

                        items: const [
                          DropdownMenuItem(
                            value:
                                'Challenge',
                            child: Text(
                              'Desafio',
                            ),
                          ),

                          DropdownMenuItem(
                            value: 'Event',
                            child: Text(
                              'Evento',
                            ),
                          ),
                        ],

                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }

                          setDialogState(() {
                            type = value;
                          });
                        },
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      TextField(
                        controller:
                            titleController,

                        decoration:
                            const InputDecoration(
                          labelText:
                              'Título',
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      TextField(
                        controller:
                            descriptionController,

                        minLines: 3,
                        maxLines: 5,

                        decoration:
                            const InputDecoration(
                          labelText:
                              'Descrição',
                          alignLabelWithHint:
                              true,
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      _dateSelector(
                        label:
                            'Data de início',
                        date: startDate,

                        onPressed:
                            () async {
                          final selected =
                              await showDatePicker(
                            context:
                                dialogContext,

                            initialDate:
                                startDate,

                            firstDate:
                                DateTime(
                              2020,
                            ),

                            lastDate:
                                DateTime(
                              2100,
                            ),
                          );

                          if (selected !=
                              null) {
                            setDialogState(
                              () {
                                startDate =
                                    selected;
                              },
                            );
                          }
                        },
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      _dateSelector(
                        label:
                            'Data de fim',
                        date: endDate,

                        onPressed:
                            () async {
                          final selected =
                              await showDatePicker(
                            context:
                                dialogContext,

                            initialDate:
                                endDate,

                            firstDate:
                                DateTime(
                              2020,
                            ),

                            lastDate:
                                DateTime(
                              2100,
                            ),
                          );

                          if (selected !=
                              null) {
                            setDialogState(
                              () {
                                endDate =
                                    selected;
                              },
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      false,
                    );
                  },

                  child: const Text(
                    'Cancelar',
                  ),
                ),

                ElevatedButton(
                  onPressed: () async {
                    final title =
                        titleController
                            .text
                            .trim();

                    final description =
                        descriptionController
                            .text
                            .trim();

                    if (title.isEmpty ||
                        description
                            .isEmpty) {
                      return;
                    }

                    final result =
                        await ApiService
                            .createEventChallenge(
                      title: title,

                      description:
                          description,

                      type: type,

                      startDate:
                          startDate,

                      endDate:
                          endDate,
                    );

                    if (!dialogContext
                        .mounted) {
                      return;
                    }

                    if (result[
                            'success'] !=
                        true) {
                      ScaffoldMessenger.of(
                        dialogContext,
                      ).showSnackBar(
                        SnackBar(
                          content: Text(
                            result[
                                    'message'] ??
                                'Não foi possível criar.',
                          ),
                        ),
                      );

                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                      true,
                    );
                  },

                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        AppColors.primary,

                    foregroundColor:
                        Colors.white,
                  ),

                  child: const Text(
                    'Criar',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    descriptionController.dispose();

    if (created == true) {
      _showMessage(
        'Criado com sucesso.',
      );

      await _loadItems();
    }
  }

Future<void> _showEditDialog(
  dynamic item,
) async {
  final titleController =
      TextEditingController(
    text: item['title'] ?? '',
  );

  final descriptionController =
      TextEditingController(
    text: item['description'] ?? '',
  );

  String type =
      item['type'] ?? 'Challenge';

  DateTime startDate =
      DateTime.parse(
        item['startDate'],
      ).toLocal();

  DateTime endDate =
      DateTime.parse(
        item['endDate'],
      ).toLocal();

  final updated =
      await showDialog<bool>(
    context: context,

    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (
          context,
          setDialogState,
        ) {
          return AlertDialog(
            title: const Text(
              'Editar evento ou desafio',
            ),

            content: SizedBox(
              width: 500,

              child:
                  SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,

                  children: [
                    DropdownButtonFormField<
                        String>(
                      value: type,

                      decoration:
                          const InputDecoration(
                        labelText: 'Tipo',

                        border:
                            OutlineInputBorder(),
                      ),

                      items: const [
                        DropdownMenuItem(
                          value:
                              'Challenge',

                          child: Text(
                            'Desafio',
                          ),
                        ),

                        DropdownMenuItem(
                          value: 'Event',

                          child: Text(
                            'Evento',
                          ),
                        ),
                      ],

                      onChanged: (value) {
                        if (value ==
                            null) {
                          return;
                        }

                        setDialogState(
                          () {
                            type = value;
                          },
                        );
                      },
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    TextField(
                      controller:
                          titleController,

                      decoration:
                          const InputDecoration(
                        labelText:
                            'Título',

                        border:
                            OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    TextField(
                      controller:
                          descriptionController,

                      minLines: 3,
                      maxLines: 5,

                      decoration:
                          const InputDecoration(
                        labelText:
                            'Descrição',

                        alignLabelWithHint:
                            true,

                        border:
                            OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    _dateSelector(
                      label:
                          'Data de início',

                      date: startDate,

                      onPressed:
                          () async {
                        final selected =
                            await showDatePicker(
                          context:
                              dialogContext,

                          initialDate:
                              startDate,

                          firstDate:
                              DateTime(
                            2020,
                          ),

                          lastDate:
                              DateTime(
                            2100,
                          ),
                        );

                        if (selected !=
                            null) {
                          setDialogState(
                            () {
                              startDate =
                                  selected;
                            },
                          );
                        }
                      },
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    _dateSelector(
                      label:
                          'Data de fim',

                      date: endDate,

                      onPressed:
                          () async {
                        final selected =
                            await showDatePicker(
                          context:
                              dialogContext,

                          initialDate:
                              endDate,

                          firstDate:
                              DateTime(
                            2020,
                          ),

                          lastDate:
                              DateTime(
                            2100,
                          ),
                        );

                        if (selected !=
                            null) {
                          setDialogState(
                            () {
                              endDate =
                                  selected;
                            },
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                    false,
                  );
                },

                child: const Text(
                  'Cancelar',
                ),
              ),

              ElevatedButton(
                onPressed: () async {
                  final title =
                      titleController
                          .text
                          .trim();

                  final description =
                      descriptionController
                          .text
                          .trim();

                  if (title.isEmpty ||
                      description.isEmpty) {
                    return;
                  }

                  final result =
                      await ApiService
                          .updateEventChallenge(
                    id: item['id'],

                    title: title,

                    description:
                        description,

                    type: type,

                    startDate:
                        startDate,

                    endDate:
                        endDate,

                    isActive:
                        item[
                                'isActive'] ==
                            true,
                  );

                  if (!dialogContext
                      .mounted) {
                    return;
                  }

                  if (result[
                          'success'] !=
                      true) {
                    ScaffoldMessenger
                            .of(
                      dialogContext,
                    ).showSnackBar(
                      SnackBar(
                        content: Text(
                          result[
                                  'message'] ??
                              'Não foi possível atualizar.',
                        ),
                      ),
                    );

                    return;
                  }

                  Navigator.pop(
                    dialogContext,
                    true,
                  );
                },

                style:
                    ElevatedButton
                        .styleFrom(
                  backgroundColor:
                      AppColors.primary,

                  foregroundColor:
                      Colors.white,
                ),

                child: const Text(
                  'Guardar alterações',
                ),
              ),
            ],
          );
        },
      );
    },
  );

  titleController.dispose();
  descriptionController.dispose();

  if (updated == true) {
    _showMessage(
      'Atualizado com sucesso.',
    );

    await _loadItems();
  }
}

  Widget _dateSelector({
    required String label,
    required DateTime date,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,

      borderRadius:
          BorderRadius.circular(12),

      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,

          border:
              const OutlineInputBorder(),

          suffixIcon: const Icon(
            Icons.calendar_month_outlined,
          ),
        ),

        child: Text(
          _formatDate(date),
        ),
      ),
    );
  }

  Future<void> _toggleStatus(
    dynamic item,
  ) async {
    final result =
        await ApiService
            .toggleEventChallengeStatus(
      item['id'],
    );

    if (!mounted) return;

    if (result['success'] != true) {
      _showMessage(
        result['message'] ??
            'Não foi possível alterar o estado.',
      );

      return;
    }

    await _loadItems();
  }

  String _formatDate(
    dynamic value,
  ) {
    DateTime? date;

    if (value is DateTime) {
      date = value;
    } else if (value != null) {
      date =
          DateTime.tryParse(
        value.toString(),
      )?.toLocal();
    }

    if (date == null) {
      return '—';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final items =
        _filteredItems;

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
          'Eventos e Desafios',
        ),

        actions: [
          IconButton(
            onPressed: _loadItems,

            tooltip: 'Atualizar',

            icon: const Icon(
              Icons.refresh,
            ),
          ),

          const SizedBox(width: 8),

          Padding(
            padding:
                const EdgeInsets.only(
              right: 25,
            ),

            child:
                ElevatedButton.icon(
              onPressed:
                  _showCreateDialog,

              icon: const Icon(
                Icons.add,
              ),

              label: const Text(
                'Criar',
              ),

              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    AppColors.primary,

                foregroundColor:
                    Colors.white,
              ),
            ),
          ),
        ],
      ),

      body: _isLoading
          ? Center(
              child:
                  CircularProgressIndicator(
                color:
                    AppColors.primary,
              ),
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
                  Wrap(
                    spacing: 10,

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

                  if (items.isEmpty)
                    Container(
                      width:
                          double.infinity,

                      padding:
                          const EdgeInsets
                              .all(
                        50,
                      ),

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

                      child:
                          const Center(
                        child: Text(
                          'Ainda não existem eventos ou desafios.',
                        ),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,

                      children:
                          items.map(
                        (item) {
                          return _itemCard(
                            item,
                          );
                        },
                      ).toList(),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _itemCard(
    dynamic item,
  ) {
    final isChallenge =
        item['type'] ==
            'Challenge';

    final isActive =
        item['isActive'] ==
            true;

    return Container(
      width: 360,

      padding:
          const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(18),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Icon(
                isChallenge
                    ? Icons
                        .emoji_events_outlined
                    : Icons
                        .event_outlined,

                color:
                    AppColors.primary,
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child: Text(
                  isChallenge
                      ? 'Desafio'
                      : 'Evento',

                  style: TextStyle(
                    color:
                        AppColors.primary,

                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),

IconButton(
  tooltip: 'Editar',

  onPressed: () {
    _showEditDialog(
      item,
    );
  },

  icon: Icon(
    Icons.edit_outlined,

    color:
        AppColors.primary,
  ),
),

              Switch(
                value: isActive,

                activeColor:
                    AppColors.primary,

                onChanged: (_) {
                  _toggleStatus(
                    item,
                  );
                },
              ),
            ],
          ),

          const SizedBox(
            height: 15,
          ),

          Text(
            item['title'] ?? '—',

            style:
                const TextStyle(
              fontSize: 19,

              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          Text(
            item['description'] ??
                '',

            style:
                const TextStyle(
              color:
                  Colors.black54,

              height: 1.4,
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          Row(
            children: [
              const Icon(
                Icons
                    .calendar_today_outlined,

                size: 16,

                color:
                    Colors.grey,
              ),

              const SizedBox(
                width: 7,
              ),

              Text(
                '${_formatDate(item['startDate'])} - ${_formatDate(item['endDate'])}',

                style:
                    const TextStyle(
                  color:
                      Colors.grey,

                  fontSize: 13,
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
        _filter == value;

    return ChoiceChip(
      label: Text(label),

      selected: selected,

      selectedColor:
          AppColors.primary
              .withOpacity(0.15),

      onSelected: (_) {
        setState(() {
          _filter = value;
        });
      },
    );
  }
}
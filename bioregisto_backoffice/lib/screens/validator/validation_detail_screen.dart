import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../utils/app_colors.dart';

class ValidationDetailScreen extends StatefulWidget {
  final dynamic observation;

  const ValidationDetailScreen({
    super.key,
    required this.observation,
  });

  @override
  State<ValidationDetailScreen> createState() =>
      _ValidationDetailScreenState();
}

class _ValidationDetailScreenState
    extends State<ValidationDetailScreen> {
  bool _isLoadingTaxonomy = true;
  bool _isSubmitting = false;

  List<dynamic> _kingdoms = [];
  List<dynamic> _phyla = [];
  List<dynamic> _classes = [];
  List<dynamic> _orders = [];
  List<dynamic> _families = [];
  List<dynamic> _genera = [];
  List<dynamic> _species = [];

  dynamic _selectedKingdom;
  dynamic _selectedPhylum;
  dynamic _selectedClass;
  dynamic _selectedOrder;
  dynamic _selectedFamily;
  dynamic _selectedGenus;
  dynamic _selectedSpecies;

  late final TextEditingController
    _commonNameController;

late final TextEditingController
    _scientificNameController;

final TextEditingController
    _notesController =
        TextEditingController();

 @override
void initState() {
  super.initState();

  _commonNameController =
      TextEditingController(
    text: widget.observation[
            'commonName'] ??
        '',
  );

  _scientificNameController =
      TextEditingController(
    text: widget.observation[
            'scientificName'] ??
        '',
  );

  _loadKingdoms();
}

@override
void dispose() {
  _commonNameController.dispose();
  _scientificNameController.dispose();
  _notesController.dispose();

  super.dispose();
}

  Future<void> _loadKingdoms() async {
    try {
      final data =
          await ApiService.getRootTaxa();

      if (!mounted) return;

      setState(() {
        _kingdoms = data;
        _isLoadingTaxonomy = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoadingTaxonomy = false;
      });

      _showMessage(
        'Não foi possível carregar a taxonomia.',
      );
    }
  }

  Future<List<dynamic>> _loadChildren(
    int parentId,
  ) async {
    return ApiService.getTaxonChildren(
      parentId,
    );
  }

  Future<void> _selectKingdom(
    dynamic value,
  ) async {
    setState(() {
      _selectedKingdom = value;

      _selectedPhylum = null;
      _selectedClass = null;
      _selectedOrder = null;
      _selectedFamily = null;
      _selectedGenus = null;
      _selectedSpecies = null;

      _phyla = [];
      _classes = [];
      _orders = [];
      _families = [];
      _genera = [];
      _species = [];
    });

    if (value == null) return;

    final children =
        await _loadChildren(value['id']);

    if (!mounted) return;

    setState(() {
      _phyla = children;
    });
  }

  Future<void> _selectPhylum(
    dynamic value,
  ) async {
    setState(() {
      _selectedPhylum = value;

      _selectedClass = null;
      _selectedOrder = null;
      _selectedFamily = null;
      _selectedGenus = null;
      _selectedSpecies = null;

      _classes = [];
      _orders = [];
      _families = [];
      _genera = [];
      _species = [];
    });

    if (value == null) return;

    final children =
        await _loadChildren(value['id']);

    if (!mounted) return;

    setState(() {
      _classes = children;
    });
  }

  Future<void> _selectClass(
    dynamic value,
  ) async {
    setState(() {
      _selectedClass = value;

      _selectedOrder = null;
      _selectedFamily = null;
      _selectedGenus = null;
      _selectedSpecies = null;

      _orders = [];
      _families = [];
      _genera = [];
      _species = [];
    });

    if (value == null) return;

    final children =
        await _loadChildren(value['id']);

    if (!mounted) return;

    setState(() {
      _orders = children;
    });
  }

  Future<void> _selectOrder(
    dynamic value,
  ) async {
    setState(() {
      _selectedOrder = value;

      _selectedFamily = null;
      _selectedGenus = null;
      _selectedSpecies = null;

      _families = [];
      _genera = [];
      _species = [];
    });

    if (value == null) return;

    final children =
        await _loadChildren(value['id']);

    if (!mounted) return;

    setState(() {
      _families = children;
    });
  }

  Future<void> _selectFamily(
    dynamic value,
  ) async {
    setState(() {
      _selectedFamily = value;

      _selectedGenus = null;
      _selectedSpecies = null;

      _genera = [];
      _species = [];
    });

    if (value == null) return;

    final children =
        await _loadChildren(value['id']);

    if (!mounted) return;

    setState(() {
      _genera = children;
    });
  }

  Future<void> _selectGenus(
    dynamic value,
  ) async {
    setState(() {
      _selectedGenus = value;
      _selectedSpecies = null;
      _species = [];
    });

    if (value == null) return;

    final children =
        await _loadChildren(value['id']);

    if (!mounted) return;

    setState(() {
      _species = children;
    });
  }

 Future<void> _approve() async {
  if (_selectedSpecies == null) {
    _showMessage(
      'Selecione a classificação taxonómica completa.',
    );
    return;
  }

  final commonName =
      _commonNameController.text.trim();

  final scientificName =
      _scientificNameController.text.trim();

  if (commonName.isEmpty ||
      scientificName.isEmpty) {
    _showMessage(
      'Indique o nome comum e o nome científico.',
    );
    return;
  }

  setState(() {
    _isSubmitting = true;
  });

  final result =
      await ApiService.approveObservation(
    observationId:
        widget.observation['id'],

    taxonId:
        _selectedSpecies['id'],

    commonName:
        commonName,

    scientificName:
        scientificName,

    notes:
        _notesController.text.trim(),
  );

  if (!mounted) return;

  setState(() {
    _isSubmitting = false;
  });

  if (result['success'] == true) {
    _showMessage(
      'Observação validada com sucesso.',
    );

    Navigator.pop(
      context,
      true,
    );

    return;
  }

  _showMessage(
    result['message'] ??
        'Não foi possível validar a observação.',
  );
}

 Future<void> _reject() async {
  final reasonController =
      TextEditingController();

  final rejectionNotesController =
      TextEditingController(
    text: _notesController.text,
  );

  final dialogResult =
      await showDialog<
          Map<String, String>?>(
    context: context,

    builder: (dialogContext) {
      return AlertDialog(
        title: const Text(
          'Rejeitar observação',
        ),

        content: SizedBox(
          width: 500,

          child: Column(
            mainAxisSize:
                MainAxisSize.min,

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              const Text(
                'Indique o motivo pelo qual esta observação está a ser rejeitada.',
              ),

              const SizedBox(
                height: 20,
              ),

              TextField(
                controller:
                    reasonController,

                maxLines: 3,

                decoration:
                    const InputDecoration(
                  labelText:
                      'Justificação *',

                  hintText:
                      'Ex.: A fotografia não permite identificar a espécie.',

                  border:
                      OutlineInputBorder(),

                  alignLabelWithHint:
                      true,
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              TextField(
                controller:
                    rejectionNotesController,

                maxLines: 3,

                decoration:
                    const InputDecoration(
                  labelText:
                      'Notas adicionais',

                  border:
                      OutlineInputBorder(),

                  alignLabelWithHint:
                      true,
                ),
              ),
            ],
          ),
        ),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(
                dialogContext,
              );
            },

            child: const Text(
              'Cancelar',
            ),
          ),

          ElevatedButton(
            onPressed: () {
              final reason =
                  reasonController
                      .text
                      .trim();

              if (reason.isEmpty) {
                ScaffoldMessenger.of(
                  dialogContext,
                ).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'A justificação é obrigatória.',
                    ),
                  ),
                );

                return;
              }

              Navigator.pop(
                dialogContext,
                {
                  'reason': reason,
                  'notes':
                      rejectionNotesController
                          .text
                          .trim(),
                },
              );
            },

            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  Colors.red,

              foregroundColor:
                  Colors.white,
            ),

            child: const Text(
              'Confirmar rejeição',
            ),
          ),
        ],
      );
    },
  );

  reasonController.dispose();
  rejectionNotesController.dispose();

  if (dialogResult == null) {
    return;
  }

  setState(() {
    _isSubmitting = true;
  });

  final result =
      await ApiService.rejectObservation(
    observationId:
        widget.observation['id'],

    reason:
        dialogResult['reason']!,

    notes:
        dialogResult['notes'],
  );

  if (!mounted) return;

  setState(() {
    _isSubmitting = false;
  });

  if (result['success'] == true) {
    _showMessage(
      'Observação rejeitada com sucesso.',
    );

    Navigator.pop(
      context,
      true,
    );

    return;
  }

  _showMessage(
    result['message'] ??
        'Não foi possível rejeitar a observação.',
  );
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
  Widget build(BuildContext context) {
    final observation =
        widget.observation;

    final imageUrl =
        ApiService.getImageUrl(
      observation['imageUrl'],
    );

    return Scaffold(
      backgroundColor:
          AppColors.background,

      appBar: AppBar(
        backgroundColor:
            AppColors.background,
        elevation: 0,
        foregroundColor:
            Colors.black87,
        title: const Text(
          'Validar observação',
        ),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(30),

        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // DADOS DA OBSERVAÇÃO
            Expanded(
              child: _observationPanel(
                observation,
                imageUrl,
              ),
            ),

            const SizedBox(width: 30),

            // CLASSIFICAÇÃO
            Expanded(
              child:
                  _taxonomyPanel(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _observationPanel(
    dynamic observation,
    String imageUrl,
  ) {
    return Container(
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
          const Text(
            'Dados submetidos',
            style: TextStyle(
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            height: 320,
            clipBehavior:
                Clip.antiAlias,

            decoration: BoxDecoration(
              color:
                  Colors.grey.shade200,
              borderRadius:
                  BorderRadius.circular(
                16,
              ),
            ),

            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,

                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return const Icon(
                        Icons
                            .broken_image_outlined,
                        size: 60,
                      );
                    },
                  )
                : const Icon(
                    Icons.image_outlined,
                    size: 60,
                  ),
          ),

          const SizedBox(height: 25),

          _informationRow(
            'Nome comum',
            observation[
                    'commonName'] ??
                'Não indicado',
          ),

          _informationRow(
            'Nome científico proposto',
            observation[
                    'scientificName'] ??
                'Não indicado',
          ),

          _informationRow(
            'Latitude',
            observation['latitude']
                ?.toString() ??
                '-',
          ),

          _informationRow(
            'Longitude',
            observation['longitude']
                ?.toString() ??
                '-',
          ),

          _informationRow(
            'Estado',
            'Pendente de validação',
          ),
        ],
      ),
    );
  }

  Widget _taxonomyPanel() {
    return Container(
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
          const Text(
            'Classificação taxonómica',
            style: TextStyle(
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Confirme a identificação da observação selecionando a classificação taxonómica completa.',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 25),

          TextField(
  controller:
      _commonNameController,

  decoration:
      InputDecoration(
    labelText:
        'Nome comum validado',

    helperText:
        'Pode corrigir o nome submetido pelo observador.',

    border:
        OutlineInputBorder(
      borderRadius:
          BorderRadius.circular(
        12,
      ),
    ),
  ),
),

const SizedBox(height: 16),

TextField(
  controller:
      _scientificNameController,

  decoration:
      InputDecoration(
    labelText:
        'Nome científico validado',

    helperText:
        'Corrija a identificação, se necessário.',

    border:
        OutlineInputBorder(
      borderRadius:
          BorderRadius.circular(
        12,
      ),
    ),
  ),
),

const SizedBox(height: 25),

          if (_isLoadingTaxonomy)
            const Center(
              child:
                  CircularProgressIndicator(),
            )
          else ...[
            _taxonDropdown(
  label: 'Reino',
  items: _kingdoms,
  value: _selectedKingdom,
  onChanged: _selectKingdom,

  onAdd: () async {
    final taxon =
        await _createTaxonDuringValidation(
      rank: 'Kingdom',
      label: 'Reino',
    );

    if (taxon == null) return;

    setState(() {
      _kingdoms.add(taxon);
    });

    await _selectKingdom(taxon);
  },
),

         _taxonDropdown(
  label: 'Filo',
  items: _phyla,
  value: _selectedPhylum,

  onChanged:
      _selectedKingdom == null
          ? null
          : _selectPhylum,

  onAdd:
      _selectedKingdom == null
          ? null
          : () async {
              final taxon =
                  await _createTaxonDuringValidation(
                rank: 'Phylum',
                label: 'Filo',
                parentId:
                    _selectedKingdom['id'],
              );

              if (taxon == null) return;

              setState(() {
                _phyla.add(taxon);
              });

              await _selectPhylum(
                taxon,
              );
            },
),

           _taxonDropdown(
  label: 'Classe',
  items: _classes,
  value: _selectedClass,

  onChanged:
      _selectedPhylum == null
          ? null
          : _selectClass,

  onAdd:
      _selectedPhylum == null
          ? null
          : () async {
              final taxon =
                  await _createTaxonDuringValidation(
                rank: 'Class',
                label: 'Classe',
                parentId:
                    _selectedPhylum['id'],
              );

              if (taxon == null) return;

              setState(() {
                _classes.add(taxon);
              });

              await _selectClass(taxon);
            },
),

          _taxonDropdown(
  label: 'Ordem',
  items: _orders,
  value: _selectedOrder,

  onChanged:
      _selectedClass == null
          ? null
          : _selectOrder,

  onAdd:
      _selectedClass == null
          ? null
          : () async {
              final taxon =
                  await _createTaxonDuringValidation(
                rank: 'Order',
                label: 'Ordem',
                parentId:
                    _selectedClass['id'],
              );

              if (taxon == null) return;

              setState(() {
                _orders.add(taxon);
              });

              await _selectOrder(taxon);
            },
),

           _taxonDropdown(
  label: 'Família',
  items: _families,
  value: _selectedFamily,

  onChanged:
      _selectedOrder == null
          ? null
          : _selectFamily,

  onAdd:
      _selectedOrder == null
          ? null
          : () async {
              final taxon =
                  await _createTaxonDuringValidation(
                rank: 'Family',
                label: 'Família',
                parentId:
                    _selectedOrder['id'],
              );

              if (taxon == null) return;

              setState(() {
                _families.add(taxon);
              });

              await _selectFamily(taxon);
            },
),

           _taxonDropdown(
  label: 'Género',
  items: _genera,
  value: _selectedGenus,

  onChanged:
      _selectedFamily == null
          ? null
          : _selectGenus,

  onAdd:
      _selectedFamily == null
          ? null
          : () async {
              final taxon =
                  await _createTaxonDuringValidation(
                rank: 'Genus',
                label: 'Género',
                parentId:
                    _selectedFamily['id'],
              );

              if (taxon == null) return;

              setState(() {
                _genera.add(taxon);
              });

              await _selectGenus(taxon);
            },
),

           _taxonDropdown(
  label: 'Espécie',
  items: _species,
  value: _selectedSpecies,

  onChanged:
      _selectedGenus == null
          ? null
          : (value) {
              setState(() {
                _selectedSpecies = value;
              });
            },

  onAdd:
      _selectedGenus == null
          ? null
          : () async {
              final taxon =
                  await _createTaxonDuringValidation(
                rank: 'Species',
                label: 'Espécie',
                parentId:
                    _selectedGenus['id'],
              );

              if (taxon == null) return;

              setState(() {
                _species.add(taxon);
                _selectedSpecies = taxon;
              });
            },
),

            const SizedBox(height: 10),

TextField(
  controller:
      _notesController,

  maxLines: 4,

  decoration:
      InputDecoration(
    labelText:
        'Notas de validação',

    hintText:
        'Adicione informações relevantes sobre a validação...',

    alignLabelWithHint:
        true,

    border:
        OutlineInputBorder(
      borderRadius:
          BorderRadius.circular(
        12,
      ),
    ),
  ),
),

const SizedBox(height: 25),

Row(
              children: [
                Expanded(
                  child:
                      OutlinedButton.icon(
                    onPressed:
                        _isSubmitting
                            ? null
                            : _reject,

                    style:
                        OutlinedButton
                            .styleFrom(
                      foregroundColor:
                          Colors.red,

                      padding:
                          const EdgeInsets
                              .symmetric(
                        vertical: 18,
                      ),
                    ),

                    icon: const Icon(
                      Icons.close,
                    ),

                    label: const Text(
                      'Rejeitar',
                    ),
                  ),
                ),

                const SizedBox(
                  width: 15,
                ),

                Expanded(
                  child:
                      ElevatedButton.icon(
                    onPressed:
                        _isSubmitting
                            ? null
                            : _approve,

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
                        vertical: 18,
                      ),
                    ),

                    icon: const Icon(
                      Icons.verified,
                    ),

                    label:
                        _isSubmitting
                            ? const Text(
                                'A processar...',
                              )
                            : const Text(
                                'Validar observação',
                              ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

Future<dynamic> _createTaxonDuringValidation({
  required String rank,
  required String label,
  int? parentId,
}) async {
  final controller =
      TextEditingController();

  final name = await showDialog<String>(
    context: context,

    builder: (dialogContext) {
      return AlertDialog(
        title: Text(
          'Adicionar $label',
        ),

        content: SizedBox(
          width: 420,

          child: TextField(
            controller: controller,
            autofocus: true,

            decoration: InputDecoration(
              labelText: 'Nome',
              hintText:
                  rank == 'Species'
                      ? 'Ex.: Passer domesticus'
                      : null,

              border:
                  const OutlineInputBorder(),
            ),
          ),
        ),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(
                dialogContext,
              );
            },

            child:
                const Text('Cancelar'),
          ),

          ElevatedButton(
            onPressed: () {
              final value =
                  controller.text.trim();

              if (value.isNotEmpty) {
                Navigator.pop(
                  dialogContext,
                  value,
                );
              }
            },

            child:
                const Text('Adicionar'),
          ),
        ],
      );
    },
  );

  controller.dispose();

  if (name == null) {
    return null;
  }

  final result =
      await ApiService.createTaxon(
    name: name,
    rank: rank,
    parentId: parentId,
  );

  if (!mounted) {
    return null;
  }

  if (result['success'] != true) {
    _showMessage(
      result['message'] ??
          'Não foi possível criar o táxon.',
    );

    return null;
  }

  _showMessage(
    '$label criado com sucesso.',
  );

  return result['taxon'];
}

Widget _taxonDropdown({
  required String label,
  required List<dynamic> items,
  required dynamic value,
  required ValueChanged<dynamic>? onChanged,
  VoidCallback? onAdd,
}) {
  return Padding(
    padding: const EdgeInsets.only(
      bottom: 16,
    ),

    child: Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Expanded(
          child:
              DropdownButtonFormField<dynamic>(
            value: value,

            decoration: InputDecoration(
              labelText: label,

              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(12),
              ),
            ),

            items: items.map((taxon) {
              return DropdownMenuItem<dynamic>(
                value: taxon,

                child: Text(
                  taxon['name'].toString(),
                ),
              );
            }).toList(),

            onChanged: onChanged,
          ),
        ),

        if (onAdd != null) ...[
          const SizedBox(width: 8),

          SizedBox(
            height: 56,

            child: IconButton.filled(
              onPressed: onAdd,

              tooltip:
                  'Adicionar $label',

              style: IconButton.styleFrom(
                backgroundColor:
                    AppColors.primary,
                foregroundColor:
                    Colors.white,
              ),

              icon: const Icon(
                Icons.add,
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

  Widget _informationRow(
    String label,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 15,
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Text(
            label,
            style:
                const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,
            style:
                const TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
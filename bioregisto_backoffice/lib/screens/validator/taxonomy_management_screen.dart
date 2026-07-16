import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../utils/app_colors.dart';

class TaxonomyManagementScreen extends StatefulWidget {
  const TaxonomyManagementScreen({super.key});

  @override
  State<TaxonomyManagementScreen> createState() =>
      _TaxonomyManagementScreenState();
}

class _TaxonomyManagementScreenState
    extends State<TaxonomyManagementScreen> {
  List<dynamic> _roots = [];

  final Map<int, List<dynamic>> _children = {};
  final Set<int> _expandedIds = {};
  final Set<int> _loadingIds = {};

  dynamic _selectedTaxon;

  bool _isLoading = true;

  final TextEditingController _searchController =
      TextEditingController();

  static const Map<String, String> _rankLabels = {
    'Kingdom': 'Reino',
    'Phylum': 'Filo',
    'Class': 'Classe',
    'Order': 'Ordem',
    'Family': 'Família',
    'Genus': 'Género',
    'Species': 'Espécie',
  };

  static const Map<String, String> _nextRanks = {
    'Kingdom': 'Phylum',
    'Phylum': 'Class',
    'Class': 'Order',
    'Order': 'Family',
    'Family': 'Genus',
    'Genus': 'Species',
  };

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadRoots();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRoots() async {
    try {
      final roots =
          await ApiService.getRootTaxa();

      if (!mounted) return;

      setState(() {
        _roots = roots;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Não foi possível carregar a taxonomia.',
      );
    }
  }

  Future<void> _toggleTaxon(
    dynamic taxon,
  ) async {
    final int id = taxon['id'];
    final String rank = taxon['rank'];

    // Espécie é o último nível.
    if (rank == 'Species') {
      setState(() {
        _selectedTaxon = taxon;
      });

      return;
    }

    setState(() {
      _selectedTaxon = taxon;
    });

    if (_expandedIds.contains(id)) {
      setState(() {
        _expandedIds.remove(id);
      });

      return;
    }

    // Se os filhos ainda não foram carregados,
    // vamos buscá-los à API.
    if (!_children.containsKey(id)) {
      setState(() {
        _loadingIds.add(id);
      });

      try {
        final children =
            await ApiService
                .getTaxonChildren(id);

        if (!mounted) return;

        setState(() {
          _children[id] = children;
          _expandedIds.add(id);
          _loadingIds.remove(id);
        });
      } catch (error) {
        if (!mounted) return;

        setState(() {
          _loadingIds.remove(id);
        });

        _showMessage(
          'Não foi possível carregar os níveis seguintes.',
        );
      }

      return;
    }

    setState(() {
      _expandedIds.add(id);
    });
  }

  Future<void> _addRoot() async {
    await _showAddDialog(
      rank: 'Kingdom',
      parentId: null,
    );
  }

  Future<void> _addChild(
    dynamic parent,
  ) async {
    final String parentRank =
        parent['rank'];

    final nextRank =
        _nextRanks[parentRank];

    if (nextRank == null) {
      return;
    }

    await _showAddDialog(
      rank: nextRank,
      parentId: parent['id'],
    );
  }

Future<void> _showAddDialog({
  required String rank,
  required int? parentId,
}) async {
  final nameController =
      TextEditingController();

  final commonNameController =
      TextEditingController();

  final label =
      _rankLabels[rank] ?? rank;

  final result =
      await showDialog<Map<String, String?>>(
    context: context,

    builder: (dialogContext) {
      return AlertDialog(
        title: Text(
          'Adicionar $label',
        ),

        content: SizedBox(
          width: 450,

          child: Column(
            mainAxisSize:
                MainAxisSize.min,

            children: [
              TextField(
                controller:
                    nameController,

                autofocus: true,

                decoration:
                    InputDecoration(
                  labelText:
                      rank == 'Species'
                          ? 'Nome científico'
                          : 'Nome do $label',

                  hintText:
                      rank == 'Species'
                          ? 'Ex.: Passer domesticus'
                          : null,

                  border:
                      const OutlineInputBorder(),
                ),
              ),

              // O nome comum só faz sentido
              // quando estamos a criar uma espécie.
              if (rank ==
                  'Species') ...[
                const SizedBox(
                  height: 16,
                ),

                TextField(
                  controller:
                      commonNameController,

                  decoration:
                      const InputDecoration(
                    labelText:
                        'Nome comum',

                    hintText:
                        'Ex.: Pardal-comum',

                    border:
                        OutlineInputBorder(),
                  ),
                ),
              ],
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
              final name =
                  nameController
                      .text
                      .trim();

              if (name.isEmpty) {
                return;
              }

              Navigator.pop(
                dialogContext,
                {
                  'name': name,

                  'commonName':
                      rank == 'Species'
                          ? commonNameController
                              .text
                              .trim()
                          : null,
                },
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
              'Adicionar',
            ),
          ),
        ],
      );
    },
  );

  nameController.dispose();
  commonNameController.dispose();

  if (result == null) {
    return;
  }

  final name =
      result['name']!;

  final commonName =
      result['commonName'];

  final apiResult =
      await ApiService.createTaxon(
    name: name,
    rank: rank,
    parentId: parentId,

    commonName:
        commonName == null ||
                commonName.isEmpty
            ? null
            : commonName,
  );

  if (!mounted) return;

  if (apiResult['success'] != true) {
    _showMessage(
      apiResult['message'] ??
          'Não foi possível criar o táxon.',
    );

    return;
  }

  _showMessage(
    '$label criado com sucesso.',
  );

  // Se criámos um Reino,
  // atualizar os elementos raiz.
  if (parentId == null) {
    await _loadRoots();
    return;
  }

  // Atualizar os filhos do táxon
  // onde o novo elemento foi criado.
  try {
    final updatedChildren =
        await ApiService
            .getTaxonChildren(
      parentId,
    );

    if (!mounted) return;

    setState(() {
      _children[parentId] =
          updatedChildren;

      _expandedIds.add(
        parentId,
      );
    });
  } catch (error) {
    _showMessage(
      'O táxon foi criado, mas não foi possível atualizar a árvore.',
    );
  }
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

Future<void> _editTaxon() async {
  if (_selectedTaxon == null) {
    return;
  }

  final controller =
      TextEditingController(
    text: _selectedTaxon['name'] ?? '',
  );

  final commonNameController =
      TextEditingController(
    text:
        _selectedTaxon['commonName'] ?? '',
  );

  final bool isSpecies =
      _selectedTaxon['rank'] == 'Species';

  final result =
      await showDialog<
          Map<String, String?>>(
    context: context,

    builder: (dialogContext) {
      return AlertDialog(
        title: const Text(
          'Editar taxonomia',
        ),

        content: SizedBox(
          width: 450,

          child: Column(
            mainAxisSize:
                MainAxisSize.min,

            children: [
              TextField(
                controller: controller,
                autofocus: true,

                decoration:
                    InputDecoration(
                  labelText:
                      isSpecies
                          ? 'Nome científico'
                          : 'Nome',

                  border:
                      const OutlineInputBorder(),
                ),
              ),

              // O nome comum aparece
              // apenas para espécies.
              if (isSpecies) ...[
                const SizedBox(
                  height: 16,
                ),

                TextField(
                  controller:
                      commonNameController,

                  decoration:
                      const InputDecoration(
                    labelText:
                        'Nome comum',

                    hintText:
                        'Ex.: Pardal-comum',

                    border:
                        OutlineInputBorder(),
                  ),
                ),
              ],
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
              final name =
                  controller.text.trim();

              if (name.isEmpty) {
                return;
              }

              Navigator.pop(
                dialogContext,
                {
                  'name': name,

                  'commonName':
                      isSpecies
                          ? commonNameController
                              .text
                              .trim()
                          : null,
                },
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

  // Guardamos os valores antes
  // de libertar os controllers.
  final newName =
      result?['name'];

  final newCommonName =
      result?['commonName'];

  controller.dispose();
  commonNameController.dispose();

  // O utilizador cancelou.
  if (result == null ||
      newName == null) {
    return;
  }

  final id =
      _selectedTaxon['id'];

  final apiResult =
      await ApiService.updateTaxon(
    id: id,

    name: newName,

    commonName:
        isSpecies &&
                newCommonName != null &&
                newCommonName.isNotEmpty
            ? newCommonName
            : null,
  );

  if (!mounted) return;

  if (apiResult['success'] != true) {
    _showMessage(
      apiResult['message'] ??
          'Não foi possível atualizar o táxon.',
    );

    return;
  }

  final updatedTaxon =
      apiResult['taxon'];

  setState(() {
    _selectedTaxon =
        updatedTaxon;

    // Atualizar se for um Reino.
    final rootIndex =
        _roots.indexWhere(
      (taxon) =>
          taxon['id'] == id,
    );

    if (rootIndex != -1) {
      _roots[rootIndex] =
          updatedTaxon;
    }

    // Atualizar se estiver numa
    // lista de filhos.
    for (final entry
        in _children.entries) {
      final childIndex =
          entry.value.indexWhere(
        (taxon) =>
            taxon['id'] == id,
      );

      if (childIndex != -1) {
        entry.value[childIndex] =
            updatedTaxon;
      }
    }
  });

  _showMessage(
    'Táxon atualizado com sucesso.',
  );
}

  Widget _buildTaxonNode(
    dynamic taxon,
    int depth,
  ) {
    final int id = taxon['id'];
    final String rank = taxon['rank'];

    final bool expanded =
        _expandedIds.contains(id);

    final bool loading =
        _loadingIds.contains(id);

    final bool selected =
        _selectedTaxon?['id'] == id;

    final bool canExpand =
        rank != 'Species';

    final children =
        _children[id] ?? [];

    return Column(
      children: [
        InkWell(
          onTap: () {
            _toggleTaxon(taxon);
          },

          borderRadius:
              BorderRadius.circular(10),

          child: Container(
            margin:
                const EdgeInsets.only(
              bottom: 4,
            ),

            padding:
                const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 12,
            ),

            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary
                      .withOpacity(0.10)
                  : Colors.transparent,

              borderRadius:
                  BorderRadius.circular(
                10,
              ),
            ),

            child: Row(
              children: [
                SizedBox(
                  width:
                      depth * 24,
                ),

                SizedBox(
                  width: 30,

                  child: loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,

                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : canExpand
                          ? Icon(
                              expanded
                                  ? Icons
                                      .keyboard_arrow_down
                                  : Icons
                                      .chevron_right,

                              color:
                                  AppColors.primary,
                            )
                          : Icon(
                              Icons.eco_outlined,
                              size: 20,
                              color:
                                  AppColors.primary,
                            ),
                ),

                const SizedBox(
                  width: 6,
                ),

                Expanded(
                  child: Text(
                    taxon['name'] ??
                        '',

                    style:
                        TextStyle(
                      fontWeight:
                          selected
                              ? FontWeight
                                  .w600
                              : FontWeight
                                  .normal,
                    ),
                  ),
                ),

                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        Colors.grey.shade100,

                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),

                  child: Text(
                    _rankLabels[rank] ??
                        rank,

                    style:
                        const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        if (expanded)
          ...children.map(
            (child) =>
                _buildTaxonNode(
              child,
              depth + 1,
            ),
          ),
      ],
    );
  }

  bool _matchesSearch(
  dynamic taxon,
) {
  if (_searchQuery.isEmpty) {
    return true;
  }

  final name =
      (taxon['name'] ?? '')
          .toString()
          .toLowerCase();

  final rank =
      (_rankLabels[taxon['rank']] ??
              taxon['rank'] ??
              '')
          .toString()
          .toLowerCase();

  return name.contains(_searchQuery) ||
      rank.contains(_searchQuery);
}

bool _containsMatch(
  List<dynamic> taxa,
) {
  for (final taxon in taxa) {
    if (_matchesSearch(taxon)) {
      return true;
    }

    final children =
        _children[taxon['id']] ?? [];

    if (_containsMatch(children)) {
      return true;
    }
  }

  return false;
}

  @override
  Widget build(BuildContext context) {
    final nextRank =
        _selectedTaxon == null
            ? null
            : _nextRanks[
                _selectedTaxon['rank']];

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
          'Gestão da Taxonomia',
        ),

        actions: [
          Padding(
            padding:
                const EdgeInsets.only(
              right: 25,
            ),

            child:
                ElevatedButton.icon(
              onPressed: _addRoot,

              icon:
                  const Icon(Icons.add),

              label: const Text(
                'Adicionar Reino',
              ),

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.primary,
                foregroundColor:
                    Colors.white,
              ),
            ),
          ),
        ],
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(30),

        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // ÁRVORE
            Expanded(
              flex: 3,

              child: Container(
                height:
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
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'Estrutura taxonómica',

                      style:
                          TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                TextField(
  controller: _searchController,

  onChanged: (value) {
    setState(() {
      _searchQuery =
          value.trim().toLowerCase();
    });
  },

  decoration: InputDecoration(
    hintText:
        'Pesquisar na taxonomia...',
    prefixIcon:
        const Icon(Icons.search),
    filled: true,
    fillColor:
        Colors.grey.shade50,
    border: OutlineInputBorder(
      borderRadius:
          BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  ),
),

                    const SizedBox(
                      height: 20,
                    ),

                    Expanded(
                      child: _isLoading
                          ? const Center(
                              child:
                                  CircularProgressIndicator(),
                            )
                          : ListView(
  children: _roots
      .where((root) {
        if (_searchQuery.isEmpty) {
          return true;
        }

        if (_matchesSearch(root)) {
          return true;
        }

        final children =
            _children[root['id']] ?? [];

        return _containsMatch(
          children,
        );
      })
      .map(
        (root) =>
            _buildTaxonNode(
          root,
          0,
        ),
      )
      .toList(),
),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 25),

            // PAINEL LATERAL
            Expanded(
              flex: 2,

              child: Container(
                padding:
                    const EdgeInsets.all(
                  25,
                ),

                decoration:
                    BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),

                child:
                    _selectedTaxon ==
                            null
                        ? const Column(
                            mainAxisSize:
                                MainAxisSize
                                    .min,

                            children: [
                              Icon(
                                Icons
                                    .account_tree_outlined,
                                size: 55,
                                color:
                                    Colors.grey,
                              ),

                              SizedBox(
                                height: 15,
                              ),

                              Text(
                                'Selecione um elemento da árvore para gerir a taxonomia.',
                                textAlign:
                                    TextAlign
                                        .center,
                                style:
                                    TextStyle(
                                  color:
                                      Colors.grey,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisSize:
                                MainAxisSize
                                    .min,

                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [
                              Text(
                                _selectedTaxon[
                                        'name'] ??
                                    '',

                                style:
                                    const TextStyle(
                                  fontSize: 24,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),

                              const SizedBox(
                                height: 8,
                              ),

                              Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal:
                                      12,
                                  vertical: 6,
                                ),

                                decoration:
                                    BoxDecoration(
                                  color: AppColors
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
                                  _rankLabels[
                                          _selectedTaxon[
                                              'rank']] ??
                                      _selectedTaxon[
                                          'rank'],

                                  style:
                                      TextStyle(
                                    color:
                                        AppColors
                                            .primary,
                                    fontWeight:
                                        FontWeight
                                            .w600,
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height: 30,
                              ),

SizedBox(
  width: double.infinity,

  child: OutlinedButton.icon(
    onPressed: _editTaxon,

    icon: const Icon(
      Icons.edit_outlined,
    ),

    label: const Text(
      'Editar nome',
    ),

    style:
        OutlinedButton.styleFrom(
      foregroundColor:
          AppColors.primary,

      side: BorderSide(
        color:
            AppColors.primary,
      ),

      padding:
          const EdgeInsets.all(16),
    ),
  ),
),

const SizedBox(height: 12),

                              if (nextRank !=
                                  null)
                                SizedBox(
                                  width: double
                                      .infinity,

                                  child:
                                      ElevatedButton
                                          .icon(
                                    onPressed:
                                        () {
                                      _addChild(
                                        _selectedTaxon,
                                      );
                                    },

                                    icon:
                                        const Icon(
                                      Icons.add,
                                    ),

                                    label:
                                        Text(
                                      'Adicionar ${_rankLabels[nextRank]}',
                                    ),

                                    style:
                                        ElevatedButton
                                            .styleFrom(
                                      backgroundColor:
                                          AppColors
                                              .primary,
                                      foregroundColor:
                                          Colors
                                              .white,
                                      padding:
                                          const EdgeInsets
                                              .all(
                                        16,
                                      ),
                                    ),
                                  ),
                                ),

                              if (nextRank ==
                                  null)
                                const Text(
                                  'Este é o último nível da classificação taxonómica.',
                                  style:
                                      TextStyle(
                                    color:
                                        Colors.grey,
                                  ),
                                ),
                            ],
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../utils/app_colors.dart';
import 'validation_detail_screen.dart';

class PendingObservationsScreen
    extends StatefulWidget {
  const PendingObservationsScreen({
    super.key,
  });

  @override
  State<PendingObservationsScreen>
      createState() =>
          _PendingObservationsScreenState();
}

class _PendingObservationsScreenState
    extends State<PendingObservationsScreen> {
  late Future<List<dynamic>>
      _observationsFuture;

  @override
  void initState() {
    super.initState();

    _observationsFuture =
        ApiService.getPendingObservations();
  }

  Future<void> _refresh() async {
    setState(() {
      _observationsFuture =
          ApiService.getPendingObservations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,

      appBar: AppBar(
        backgroundColor:
            AppColors.background,

        elevation: 0,

        title: const Text(
          'Observações pendentes',
          style: TextStyle(
            color: Colors.black87,
          ),
        ),

        iconTheme: const IconThemeData(
          color: Colors.black87,
        ),
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
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,

                children: [
                  const Text(
                    'Não foi possível carregar as observações.',
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  ElevatedButton(
                    onPressed: _refresh,

                    child: const Text(
                      'Tentar novamente',
                    ),
                  ),
                ],
              ),
            );
          }

          final observations =
              snapshot.data ?? [];

          if (observations.isEmpty) {
            return const Center(
              child: Text(
                'Não existem observações pendentes.',
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,

            child: ListView.builder(
              padding:
                  const EdgeInsets.all(
                30,
              ),

              itemCount:
                  observations.length,

              itemBuilder: (
                context,
                index,
              ) {
                final observation =
                    observations[index];

                return Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 15,
                  ),

                  child:
                      _observationCard(
                    observation,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _observationCard(
    dynamic observation,
  ) {
    final imageUrl =
        ApiService.getImageUrl(
      observation['imageUrl'],
    );

    return Container(
      padding:
          const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          18,
        ),
      ),

      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                BorderRadius.circular(
              14,
            ),

            child: SizedBox(
              width: 100,
              height: 100,

              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,

                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return _placeholder();
                      },
                    )
                  : _placeholder(),
            ),
          ),

          const SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  observation[
                          'commonName'] ??
                      'Sem nome comum',

                  style:
                      const TextStyle(
                    fontSize: 18,

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
                    color: Colors.grey,

                    fontStyle:
                        FontStyle.italic,
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                const Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 18,
                      color:
                          Colors.orange,
                    ),

                    SizedBox(width: 5),

                    Text(
                      'Pendente de validação',

                      style: TextStyle(
                        color:
                            Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          ElevatedButton.icon(
           onPressed: () async {
              final changed =
                  await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ValidationDetailScreen(
                    observation: observation,
                  ),
                ),
              );

              if (changed == true) {
                _refresh();
              }
            },

            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  AppColors.primary,

              foregroundColor:
                  Colors.white,
            ),

            icon: const Icon(
              Icons.fact_check_outlined,
            ),

            label: const Text(
              'Validar',
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey.shade200,

      child: const Icon(
        Icons.image_outlined,
        size: 40,
        color: Colors.grey,
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../utils/app_colors.dart';

class ValidationHistoryScreen
    extends StatefulWidget {
  const ValidationHistoryScreen({
    super.key,
  });

  @override
  State<ValidationHistoryScreen>
      createState() =>
          _ValidationHistoryScreenState();
}

class _ValidationHistoryScreenState
    extends State<ValidationHistoryScreen> {
  late Future<List<dynamic>>
      _historyFuture;

  @override
  void initState() {
    super.initState();

    _historyFuture =
        ApiService.getValidationHistory();
  }

  Future<void> _refresh() async {
    setState(() {
      _historyFuture =
          ApiService.getValidationHistory();
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
        foregroundColor:
            Colors.black87,
        elevation: 0,

        title: const Text(
          'Histórico de validações',
        ),
      ),

      body:
          FutureBuilder<List<dynamic>>(
        future: _historyFuture,

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
                    'Não foi possível carregar o histórico.',
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  ElevatedButton.icon(
                    onPressed: _refresh,
                    icon: const Icon(
                      Icons.refresh,
                    ),
                    label: const Text(
                      'Tentar novamente',
                    ),
                  ),
                ],
              ),
            );
          }

          final history =
              snapshot.data ?? [];

          if (history.isEmpty) {
            return const Center(
              child: Text(
                'Ainda não realizou nenhuma validação.',
              ),
            );
          }

          return ListView.separated(
            padding:
                const EdgeInsets.all(30),

            itemCount: history.length,

            separatorBuilder:
                (context, index) =>
                    const SizedBox(
              height: 15,
            ),

            itemBuilder:
                (context, index) {
              return _historyCard(
                history[index],
              );
            },
          );
        },
      ),
    );
  }

  Widget _historyCard(
    dynamic observation,
  ) {
    final validated =
        observation['status'] ==
            'Validated';

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
            BorderRadius.circular(18),
      ),

      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                BorderRadius.circular(12),

            child: SizedBox(
              width: 85,
              height: 85,

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

          const SizedBox(width: 18),

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
                    fontSize: 17,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  observation[
                          'scientificName'] ??
                      'Sem nome científico',

                  style:
                      const TextStyle(
                    color: Colors.grey,
                    fontStyle:
                        FontStyle.italic,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                Row(
                  children: [
                    Icon(
                      validated
                          ? Icons.verified
                          : Icons.cancel,

                      size: 18,

                      color: validated
                          ? Colors.green
                          : Colors.red,
                    ),

                    const SizedBox(
                      width: 6,
                    ),

                    Text(
                      validated
                          ? 'Validada'
                          : 'Rejeitada',

                      style: TextStyle(
                        color: validated
                            ? Colors.green
                            : Colors.red,

                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                if (observation[
                        'validationNotes'] !=
                    null) ...[
                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    'Notas: ${observation['validationNotes']}',
                  ),
                ],

                if (!validated &&
                    observation[
                            'rejectionReason'] !=
                        null) ...[
                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    'Justificação: ${observation['rejectionReason']}',
                    style:
                        const TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ],
              ],
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
        color: Colors.grey,
      ),
    );
  }
}
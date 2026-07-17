import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../utils/app_colors.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {
  late Future<List<dynamic>>
      _observationsFuture;

  @override
  void initState() {
    super.initState();

    _observationsFuture =
        ApiService.getObservations();
  }

  // =========================
  // ESTADOS DAS OBSERVAÇÕES
  // =========================

  String _getStatus(
    dynamic observation,
  ) {
    return observation['status']
            ?.toString()
            .trim()
            .toLowerCase() ??
        '';
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

  @override
  Widget build(
    BuildContext context,
  ) {
    final user =
        ApiService.currentUser;

    final userName =
        user?['name']?.toString() ??
            'Utilizador';

    final userEmail =
        user?['email']?.toString() ??
            '';

            final profileImageUrl =
    user?['profileImageUrl']
        ?.toString();

final fullProfileImageUrl =
    profileImageUrl != null &&
            profileImageUrl.isNotEmpty
        ? profileImageUrl.startsWith('http')
            ? profileImageUrl
            : '${ApiService.baseUrl.replaceFirst('/api', '')}$profileImageUrl'
        : null;

    return Scaffold(
      backgroundColor:
          const Color(
        0xFFF4F7F3,
      ),

      appBar: AppBar(
        backgroundColor:
            AppColors.primary,

        elevation: 0,

        iconTheme:
            const IconThemeData(
          color: Colors.white,
        ),

        title:
            const Text(
          'Perfil',

          style: TextStyle(
            color:
                Colors.white,
          ),
        ),

        centerTitle: true,
      ),

      body:
          FutureBuilder<List<dynamic>>(
        future:
            _observationsFuture,

        builder: (
          context,
          snapshot,
        ) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
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
                    const EdgeInsets.all(
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
                      'Não foi possível carregar os dados do perfil.',

                      textAlign:
                          TextAlign.center,
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _observationsFuture =
                              ApiService
                                  .getObservations();
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

          // =========================
          // ESTATÍSTICAS
          // =========================

          final totalObservations =
              observations.length;

          final validatedObservations =
              observations
                  .where(
                    _isValidated,
                  )
                  .length;

          final pendingObservations =
              observations
                  .where(
                    _isPending,
                  )
                  .length;

          final rejectedObservations =
              observations
                  .where(
                    _isRejected,
                  )
                  .length;

          // Espécies diferentes
          final uniqueSpecies =
              observations
                  .map(
                    (
                      observation,
                    ) =>
                        observation[
                                'scientificName']
                            ?.toString()
                            .trim()
                            .toLowerCase(),
                  )
                  .where(
                    (name) =>
                        name != null &&
                        name.isNotEmpty,
                  )
                  .toSet()
                  .length;

          // Locais diferentes
          final uniqueLocations =
              observations
                  .map(
                    (
                      observation,
                    ) {
                      final latitude =
                          observation[
                              'latitude'];

                      final longitude =
                          observation[
                              'longitude'];

                      if (latitude ==
                              null ||
                          longitude ==
                              null) {
                        return null;
                      }

                      return '$latitude,$longitude';
                    },
                  )
                  .whereType<String>()
                  .toSet()
                  .length;

          // Dias diferentes com atividade
          final activeDays =
              observations
                  .map(
                    (
                      observation,
                    ) {
                      final createdAt =
                          observation[
                              'createdAt'];

                      if (createdAt ==
                          null) {
                        return null;
                      }

                      final date =
                          DateTime
                              .tryParse(
                        createdAt
                            .toString(),
                      );

                      if (date ==
                          null) {
                        return null;
                      }

                      return '${date.year}-'
                          '${date.month}-'
                          '${date.day}';
                    },
                  )
                  .whereType<String>()
                  .toSet()
                  .length;

          // Contagem por espécie
          final Map<String, int>
              speciesCount = {};

          for (final observation
              in observations) {
            final commonName =
                observation[
                            'commonName']
                        ?.toString()
                        .trim() ??
                    '';

            final scientificName =
                observation[
                            'scientificName']
                        ?.toString()
                        .trim() ??
                    '';

            String speciesName;

            if (commonName
                .isNotEmpty) {
              speciesName =
                  commonName;
            } else if (
                scientificName
                    .isNotEmpty) {
              speciesName =
                  scientificName;
            } else {
              speciesName =
                  'Espécie desconhecida';
            }

            speciesCount[
                speciesName] =
                (speciesCount[
                            speciesName] ??
                        0) +
                    1;
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // =========================
                // HEADER
                // =========================

                Container(
                  width:
                      double.infinity,

                  padding:
                      const EdgeInsets
                          .only(
                    top: 15,
                    bottom: 30,
                    left: 20,
                    right: 20,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        AppColors.primary,

                    borderRadius:
                        const BorderRadius
                            .only(
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

                  child: Column(
                    children: [
                      CircleAvatar(
  radius: 45,
  backgroundColor: Colors.white,

  backgroundImage:
      fullProfileImageUrl != null
          ? NetworkImage(
              fullProfileImageUrl,
            )
          : null,

  child:
      fullProfileImageUrl == null
          ? const Icon(
              Icons.person,
              size: 50,
              color: Colors.grey,
            )
          : null,
),

                      const SizedBox(
                        height: 15,
                      ),

                      Text(
                        userName,

                        textAlign:
                            TextAlign
                                .center,

                        style:
                            const TextStyle(
                          color:
                              Colors.white,

                          fontSize: 24,

                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      Text(
                        userEmail,

                        textAlign:
                            TextAlign
                                .center,

                        style:
                            const TextStyle(
                          color:
                              Colors
                                  .white70,

                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(
  height: 20,
),

OutlinedButton.icon(
  onPressed: () async {
    final updated =
        await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const EditProfileScreen(),
      ),
    );

    if (updated == true &&
        mounted) {
      setState(() {
        // Reconstrói o perfil para
        // apresentar os novos dados.
      });
    }
  },

  style: OutlinedButton.styleFrom(
    foregroundColor:
        Colors.white,

    side: const BorderSide(
      color: Colors.white,
    ),
  ),

  icon: const Icon(
    Icons.edit_outlined,
  ),

  label: const Text(
    'Editar perfil',
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
                    children: [
                      // =========================
                      // ESTATÍSTICAS GERAIS
                      // =========================

                      Row(
                        children: [
                          Expanded(
                            child:
                                _statCard(
                              totalObservations
                                  .toString(),

                              'Observações',
                            ),
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          Expanded(
                            child:
                                _statCard(
                              uniqueSpecies
                                  .toString(),

                              'Espécies',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Row(
                        children: [
                          Expanded(
                            child:
                                _statCard(
                              uniqueLocations
                                  .toString(),

                              'Locais',
                            ),
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          Expanded(
                            child:
                                _statCard(
                              activeDays
                                  .toString(),

                              'Dias ativos',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 25,
                      ),

                      // =========================
                      // RESUMO DOS ESTADOS
                      // =========================

                      _sectionCard(
                        'Resumo',

                        Wrap(
                          alignment:
                              WrapAlignment
                                  .spaceAround,

                          spacing: 25,

                          runSpacing: 20,

                          children: [
                            _summaryItem(
                              validatedObservations
                                  .toString(),

                              'Validadas',

                              Colors.green,
                            ),

                            _summaryItem(
                              pendingObservations
                                  .toString(),

                              'Pendentes',

                              Colors.orange,
                            ),

                            _summaryItem(
                              rejectedObservations
                                  .toString(),

                              'Rejeitadas',

                              Colors.red,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      // =========================
                      // ESPÉCIES REGISTADAS
                      // =========================

                      _sectionCard(
                        'Espécies registadas',

                        speciesCount
                                .isEmpty
                            ? const Padding(
                                padding:
                                    EdgeInsets
                                        .all(
                                  20,
                                ),

                                child:
                                    Center(
                                  child:
                                      Text(
                                    'Ainda não existem espécies registadas.',

                                    textAlign:
                                        TextAlign
                                            .center,

                                    style:
                                        TextStyle(
                                      color:
                                          Colors
                                              .grey,
                                    ),
                                  ),
                                ),
                              )
                            : Column(
                                children:
                                    speciesCount
                                        .entries
                                        .map(
                                  (
                                    entry,
                                  ) {
                                    return ListTile(
                                      contentPadding:
                                          EdgeInsets
                                              .zero,

                                      leading:
                                          Container(
                                        width:
                                            42,

                                        height:
                                            42,

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
                                            12,
                                          ),
                                        ),

                                        child:
                                            Icon(
                                          Icons
                                              .eco_outlined,

                                          color:
                                              AppColors
                                                  .primary,
                                        ),
                                      ),

                                      title:
                                          Text(
                                        entry
                                            .key,

                                        style:
                                            const TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .w500,
                                        ),
                                      ),

                                      trailing:
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
                                          color: Colors
                                              .grey
                                              .shade100,

                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                            10,
                                          ),
                                        ),

                                        child:
                                            Text(
                                          '${entry.value}x',
                                        ),
                                      ),
                                    );
                                  },
                                ).toList(),
                              ),
                      ),

                      const SizedBox(
                        height: 25,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // =========================
  // CARTÃO DE ESTATÍSTICA
  // =========================

  Widget _statCard(
    String value,
    String label,
  ) {
    return Container(
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
            color: Colors.black
                .withOpacity(
              0.04,
            ),

            blurRadius: 10,

            offset:
                const Offset(
              0,
              4,
            ),
          ),
        ],
      ),

      child: Column(
        children: [
          Text(
            value,

            style:
                TextStyle(
              fontSize: 28,

              fontWeight:
                  FontWeight.bold,

              color:
                  AppColors.primary,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            label,

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

  // =========================
  // SECÇÃO
  // =========================

  Widget _sectionCard(
    String title,
    Widget child,
  ) {
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
            color: Colors.black
                .withOpacity(
              0.04,
            ),

            blurRadius: 10,

            offset:
                const Offset(
              0,
              4,
            ),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,

        children: [
          Text(
            title,

            style:
                const TextStyle(
              fontSize: 18,

              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          child,
        ],
      ),
    );
  }

  // =========================
  // RESUMO
  // =========================

  Widget _summaryItem(
    String value,
    String label,
    Color color,
  ) {
    return SizedBox(
      width: 75,

      child: Column(
        children: [
          Text(
            value,

            style:
                TextStyle(
              fontSize: 24,

              fontWeight:
                  FontWeight.bold,

              color: color,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            label,

            textAlign:
                TextAlign.center,

            style:
                const TextStyle(
              fontSize: 12,

              color:
                  Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
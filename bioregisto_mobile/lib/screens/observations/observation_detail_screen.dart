import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../utils/app_colors.dart';

class ObservationDetailScreen
    extends StatelessWidget {
  final dynamic observation;

  const ObservationDetailScreen({
    super.key,
    required this.observation,
  });

  String _getImageUrl() {
    final imageUrl =
        observation['imageUrl']
            ?.toString();

    if (imageUrl == null ||
        imageUrl.isEmpty) {
      return '';
    }

    if (imageUrl.startsWith('http')) {
      return imageUrl;
    }

    return '${ApiService.baseUrl.replaceFirst('/api', '')}$imageUrl';
  }

  @override
  Widget build(BuildContext context) {
    final commonName =
        observation['commonName']
                ?.toString()
                .trim() ??
            '';

    final scientificName =
        observation['scientificName']
                ?.toString()
                .trim() ??
            '';

    final status =
        observation['status']
                ?.toString()
                .toLowerCase() ??
            'pending';

    final imageUrl =
        _getImageUrl();

    final rejectionReason =
        observation['rejectionReason']
            ?.toString();

    final validationNotes =
        observation['validationNotes']
            ?.toString();

    final createdAt =
        DateTime.tryParse(
      observation['createdAt']
              ?.toString() ??
          '',
    );

    String statusText;
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'validated':
        statusText = 'Validada';
        statusColor = Colors.green;
        statusIcon =
            Icons.check_circle;
        break;

      case 'rejected':
        statusText = 'Rejeitada';
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;

      default:
        statusText = 'Pendente';
        statusColor = Colors.orange;
        statusIcon =
            Icons.access_time;
    }

    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F7F3),

      appBar: AppBar(
        backgroundColor:
            AppColors.primary,
        foregroundColor:
            Colors.white,
        title: const Text(
          'Detalhes da observação',
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // FOTO
            Container(
              width: double.infinity,
              height: 280,
              color:
                  Colors.grey.shade200,

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
                              .image_not_supported_outlined,
                          size: 70,
                          color: Colors.grey,
                        );
                      },
                    )
                  : const Icon(
                      Icons
                          .photo_camera_outlined,
                      size: 70,
                      color: Colors.grey,
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
                  // NOME
                  Text(
                    commonName.isNotEmpty
                        ? commonName
                        : 'Espécie desconhecida',

                    style:
                        const TextStyle(
                      fontSize: 26,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  if (scientificName
                      .isNotEmpty) ...[
                    const SizedBox(
                      height: 5,
                    ),

                    Text(
                      scientificName,

                      style:
                          TextStyle(
                        fontSize: 16,
                        fontStyle:
                            FontStyle
                                .italic,
                        color: Colors
                            .grey.shade600,
                      ),
                    ),
                  ],

                  const SizedBox(
                    height: 20,
                  ),

                  // ESTADO
                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),

                    decoration:
                        BoxDecoration(
                      color: statusColor
                          .withOpacity(
                        0.12,
                      ),

                      borderRadius:
                          BorderRadius
                              .circular(
                        20,
                      ),
                    ),

                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min,

                      children: [
                        Icon(
                          statusIcon,
                          color:
                              statusColor,
                          size: 20,
                        ),

                        const SizedBox(
                          width: 7,
                        ),

                        Text(
                          statusText,

                          style:
                              TextStyle(
                            color:
                                statusColor,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  // INFORMAÇÃO
                  _detailCard(
                    children: [
                      if (createdAt !=
                          null)
                        _detailRow(
                          Icons
                              .calendar_today_outlined,
                          'Data',
                          '${createdAt.day.toString().padLeft(2, '0')}/'
                              '${createdAt.month.toString().padLeft(2, '0')}/'
                              '${createdAt.year}',
                        ),

                      if (observation[
                                  'latitude'] !=
                              null &&
                          observation[
                                  'longitude'] !=
                              null)
                        _detailRow(
                          Icons
                              .location_on_outlined,
                          'Localização',
                          '${observation['latitude']}, '
                              '${observation['longitude']}',
                        ),
                    ],
                  ),

                  // MOTIVO DE REJEIÇÃO
                  if (status ==
                          'rejected' &&
                      rejectionReason !=
                          null &&
                      rejectionReason
                          .trim()
                          .isNotEmpty) ...[
                    const SizedBox(
                      height: 20,
                    ),

                    _messageCard(
                      title:
                          'Motivo da rejeição',
                      message:
                          rejectionReason,
                      icon:
                          Icons.info_outline,
                      color: Colors.red,
                    ),
                  ],

                  // NOTAS DO VALIDADOR
                  if (validationNotes !=
                          null &&
                      validationNotes
                          .trim()
                          .isNotEmpty) ...[
                    const SizedBox(
                      height: 20,
                    ),

                    _messageCard(
                      title:
                          'Notas do validador',
                      message:
                          validationNotes,
                      icon: Icons
                          .rate_review_outlined,
                      color:
                          AppColors.primary,
                    ),
                  ],

                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailCard({
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(18),
      ),

      child: Column(
        children: children,
      ),
    );
  }

  Widget _detailRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 8,
      ),

      child: Row(
        children: [
          Icon(
            icon,
            color:
                AppColors.primary,
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
                  label,

                  style:
                      const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(
                  height: 2,
                ),

                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageCard({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: color.withOpacity(
          0.08,
        ),

        borderRadius:
            BorderRadius.circular(18),
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Icon(
            icon,
            color: color,
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
                  title,

                  style:
                      TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    color: color,
                  ),
                ),

                const SizedBox(
                  height: 7,
                ),

                Text(message),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
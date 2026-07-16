import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../utils/app_colors.dart';

class NotificationsManagementScreen
    extends StatefulWidget {
  const NotificationsManagementScreen({
    super.key,
  });

  @override
  State<NotificationsManagementScreen>
      createState() =>
          _NotificationsManagementScreenState();
}

class _NotificationsManagementScreenState
    extends State<NotificationsManagementScreen> {
  final _titleController =
      TextEditingController();

  final _messageController =
      TextEditingController();

  List<dynamic> _notifications = [];

  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notifications =
          await ApiService
              .getNotifications();

      if (!mounted) return;

      setState(() {
        _notifications =
            notifications;

        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Não foi possível carregar as notificações.',
      );
    }
  }

  Future<void> _sendNotification() async {
    final title =
        _titleController.text.trim();

    final message =
        _messageController.text.trim();

    if (title.isEmpty ||
        message.isEmpty) {
      _showMessage(
        'Preencha o título e a mensagem.',
      );

      return;
    }

    setState(() {
      _isSending = true;
    });

    final result =
        await ApiService
            .createNotification(
      title: title,
      message: message,
    );

    if (!mounted) return;

    setState(() {
      _isSending = false;
    });

    if (result['success'] != true) {
      _showMessage(
        result['message'] ??
            'Não foi possível enviar a notificação.',
      );

      return;
    }

    _titleController.clear();
    _messageController.clear();

    _showMessage(
      'Notificação enviada com sucesso.',
    );

    await _loadNotifications();
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

    final localDate =
        date.toLocal();

    return '${localDate.day.toString().padLeft(2, '0')}/'
        '${localDate.month.toString().padLeft(2, '0')}/'
        '${localDate.year} '
        '${localDate.hour.toString().padLeft(2, '0')}:'
        '${localDate.minute.toString().padLeft(2, '0')}';
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
          'Notificações Globais',
        ),

        actions: [
          IconButton(
            onPressed:
                _loadNotifications,

            tooltip:
                'Atualizar',

            icon: const Icon(
              Icons.refresh,
            ),
          ),

          const SizedBox(
            width: 20,
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(30),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // FORMULÁRIO
            Container(
              width: double.infinity,

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

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [
                  Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets
                                .all(12),

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
                          Icons
                              .campaign_outlined,

                          color:
                              AppColors
                                  .primary,
                        ),
                      ),

                      const SizedBox(
                        width: 15,
                      ),

                      const Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [
                          Text(
                            'Enviar notificação global',

                            style:
                                TextStyle(
                              fontSize:
                                  21,

                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          SizedBox(
                            height: 3,
                          ),

                          Text(
                            'A mensagem ficará disponível para todos os utilizadores.',

                            style:
                                TextStyle(
                              color:
                                  Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  TextField(
                    controller:
                        _titleController,

                    enabled:
                        !_isSending,

                    decoration:
                        InputDecoration(
                      labelText:
                          'Título',

                      hintText:
                          'Ex.: Novo desafio disponível',

                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  TextField(
                    controller:
                        _messageController,

                    enabled:
                        !_isSending,

                    minLines: 4,
                    maxLines: 7,

                    decoration:
                        InputDecoration(
                      labelText:
                          'Mensagem',

                      hintText:
                          'Escreva a mensagem que pretende enviar aos utilizadores...',

                      alignLabelWithHint:
                          true,

                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  Align(
                    alignment:
                        Alignment.centerRight,

                    child:
                        ElevatedButton.icon(
                      onPressed:
                          _isSending
                              ? null
                              : _sendNotification,

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
                          horizontal: 25,
                          vertical: 18,
                        ),
                      ),

                      icon: _isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,

                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2,

                                color:
                                    Colors
                                        .white,
                              ),
                            )
                          : const Icon(
                              Icons.send,
                            ),

                      label: Text(
                        _isSending
                            ? 'A enviar...'
                            : 'Enviar notificação',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            // HISTÓRICO
            Container(
              width: double.infinity,

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

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [
                  const Text(
                    'Histórico de notificações',

                    style: TextStyle(
                      fontSize: 21,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  if (_isLoading)
                    const Padding(
                      padding:
                          EdgeInsets.all(
                        40,
                      ),

                      child: Center(
                        child:
                            CircularProgressIndicator(),
                      ),
                    )
                  else if (_notifications
                      .isEmpty)
                    const Padding(
                      padding:
                          EdgeInsets.all(
                        40,
                      ),

                      child: Center(
                        child: Text(
                          'Ainda não foram enviadas notificações.',

                          style:
                              TextStyle(
                            color:
                                Colors.grey,
                          ),
                        ),
                      ),
                    )
                  else
                    ..._notifications.map(
                      (notification) {
                        return Container(
                          margin:
                              const EdgeInsets
                                  .only(
                            bottom: 12,
                          ),

                          padding:
                              const EdgeInsets
                                  .all(
                            18,
                          ),

                          decoration:
                              BoxDecoration(
                            color:
                                Colors.grey
                                    .shade50,

                            borderRadius:
                                BorderRadius
                                    .circular(
                              14,
                            ),
                          ),

                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [
                              Icon(
                                Icons
                                    .notifications_outlined,

                                color:
                                    AppColors
                                        .primary,
                              ),

                              const SizedBox(
                                width: 15,
                              ),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,

                                  children: [
                                    Text(
                                      notification[
                                              'title'] ??
                                          'Sem título',

                                      style:
                                          const TextStyle(
                                        fontSize:
                                            16,

                                        fontWeight:
                                            FontWeight
                                                .w600,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 6,
                                    ),

                                    Text(
                                      notification[
                                              'message'] ??
                                          '',

                                      style:
                                          const TextStyle(
                                        height:
                                            1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(
                                width: 20,
                              ),

                              Text(
                                _formatDate(
                                  notification[
                                      'createdAt'],
                                ),

                                style:
                                    const TextStyle(
                                  color:
                                      Colors.grey,

                                  fontSize:
                                      12,
                                ),
                              ),
                            ],
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
}
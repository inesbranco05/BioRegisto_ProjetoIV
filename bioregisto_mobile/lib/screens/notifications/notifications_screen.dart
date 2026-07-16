import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../utils/app_colors.dart';

class NotificationsScreen
    extends StatefulWidget {
  const NotificationsScreen({
    super.key,
  });

  @override
  State<NotificationsScreen>
      createState() =>
          _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
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

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível carregar as notificações.',
          ),
        ),
      );
    }
  }

  String _formatDate(
    dynamic value,
  ) {
    if (value == null) {
      return '';
    }

    final date =
        DateTime.tryParse(
      value.toString(),
    );

    if (date == null) {
      return '';
    }

    final local =
        date.toLocal();

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year} às '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
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
          'Notificações',
        ),

        actions: [
          IconButton(
            onPressed:
                _loadNotifications,

            icon: const Icon(
              Icons.refresh,
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
          : _notifications.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,

                    children: [
                      Icon(
                        Icons
                            .notifications_none,
                        size: 65,
                        color:
                            Colors.grey,
                      ),

                      SizedBox(
                        height: 15,
                      ),

                      Text(
                        'Ainda não tens notificações.',
                        style:
                            TextStyle(
                          color:
                              Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh:
                      _loadNotifications,

                  child: ListView
                      .separated(
                    padding:
                        const EdgeInsets
                            .all(20),

                    itemCount:
                        _notifications
                            .length,

                    separatorBuilder:
                        (_, __) =>
                            const SizedBox(
                      height: 12,
                    ),

                    itemBuilder:
                        (context, index) {
                      final notification =
                          _notifications[
                              index];

                      return Container(
                        padding:
                            const EdgeInsets
                                .all(18),

                        decoration:
                            BoxDecoration(
                          color:
                              Colors.white,

                          borderRadius:
                              BorderRadius
                                  .circular(
                            16,
                          ),
                        ),

                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

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
                                Icons
                                    .notifications_outlined,

                                color:
                                    AppColors
                                        .primary,
                              ),
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
                                        'Notificação',

                                    style:
                                        const TextStyle(
                                      fontSize:
                                          16,

                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 7,
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

                                  const SizedBox(
                                    height: 10,
                                  ),

                                  Text(
                                    _formatDate(
                                      notification[
                                          'createdAt'],
                                    ),

                                    style:
                                        const TextStyle(
                                      fontSize:
                                          12,

                                      color:
                                          Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
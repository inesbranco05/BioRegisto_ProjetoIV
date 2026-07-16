import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../utils/app_colors.dart';

class UsersManagementScreen
    extends StatefulWidget {
  const UsersManagementScreen({
    super.key,
  });

  @override
  State<UsersManagementScreen> createState() =>
      _UsersManagementScreenState();
}

class _UsersManagementScreenState
    extends State<UsersManagementScreen> {
  List<dynamic> _users = [];
  List<dynamic> _filteredUsers = [];

  bool _isLoading = true;

  final TextEditingController
      _searchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final users =
          await ApiService.getUsers();

      if (!mounted) return;

      setState(() {
        _users = users;
        _filteredUsers = users;
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
            'Não foi possível carregar os utilizadores.',
          ),
        ),
      );
    }
  }

  void _filterUsers(String value) {
    final query =
        value.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _users;

        return;
      }

      _filteredUsers =
          _users.where((user) {
        final name =
            (user['name'] ?? '')
                .toString()
                .toLowerCase();

        final email =
            (user['email'] ?? '')
                .toString()
                .toLowerCase();

        final role =
            (user['role'] ?? '')
                .toString()
                .toLowerCase();

        return name.contains(query) ||
            email.contains(query) ||
            role.contains(query);
      }).toList();
    });
  }

  String _roleLabel(
    String role,
  ) {
    switch (role) {
      case 'Admin':
        return 'Administrador';

      case 'Validator':
        return 'Técnico';

      default:
        return 'Observador';
    }
  }

  IconData _roleIcon(
    String role,
  ) {
    switch (role) {
      case 'Admin':
        return Icons.admin_panel_settings_outlined;

      case 'Validator':
        return Icons.verified_user_outlined;

      default:
        return Icons.person_outline;
    }
  }

Future<void> _showUserDialog({
  dynamic user,
}) async {
  final isEditing = user != null;

  final nameController =
      TextEditingController(
    text: isEditing
        ? user['name']
        : '',
  );

  final emailController =
      TextEditingController(
    text: isEditing
        ? user['email']
        : '',
  );

  final passwordController =
      TextEditingController();

  String selectedRole =
      isEditing
          ? user['role']
          : 'Observer';

  final result =
      await showDialog<bool>(
    context: context,

    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (
          context,
          setDialogState,
        ) {
          return AlertDialog(
            title: Text(
              isEditing
                  ? 'Editar utilizador'
                  : 'Criar utilizador',
            ),

            content: SizedBox(
              width: 480,

              child: Column(
                mainAxisSize:
                    MainAxisSize.min,

                children: [
                  TextField(
                    controller:
                        nameController,

                    decoration:
                        const InputDecoration(
                      labelText: 'Nome',
                      border:
                          OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  TextField(
                    controller:
                        emailController,

                    decoration:
                        const InputDecoration(
                      labelText: 'Email',
                      border:
                          OutlineInputBorder(),
                    ),
                  ),

                  if (!isEditing) ...[
                    const SizedBox(
                      height: 16,
                    ),

                    TextField(
                      controller:
                          passwordController,

                      obscureText: true,

                      decoration:
                          const InputDecoration(
                        labelText:
                            'Palavra-passe',
                        border:
                            OutlineInputBorder(),
                      ),
                    ),
                  ],

                  const SizedBox(
                    height: 16,
                  ),

                  DropdownButtonFormField<String>(
                    value:
                        selectedRole,

                    decoration:
                        const InputDecoration(
                      labelText:
                          'Papel do utilizador',
                      border:
                          OutlineInputBorder(),
                    ),

                    items: const [
                      DropdownMenuItem(
                        value:
                            'Observer',
                        child: Text(
                          'Observador',
                        ),
                      ),

                      DropdownMenuItem(
                        value:
                            'Validator',
                        child: Text(
                          'Técnico (Validador)',
                        ),
                      ),
                    ],

                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedRole =
                              value;
                        });
                      }
                    },
                  ),
                ],
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
                  final name =
                      nameController
                          .text
                          .trim();

                  final email =
                      emailController
                          .text
                          .trim();

                  final password =
                      passwordController
                          .text;

                  if (name.isEmpty ||
                      email.isEmpty ||
                      (!isEditing &&
                          password
                              .isEmpty)) {
                    ScaffoldMessenger
                        .of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Preencha todos os campos obrigatórios.',
                        ),
                      ),
                    );

                    return;
                  }

                  Map<String, dynamic>
                      apiResult;

                  if (isEditing) {
                    apiResult =
                        await ApiService
                            .updateUser(
                      id: user['id'],
                      name: name,
                      email: email,
                      role:
                          selectedRole,
                    );
                  } else {
                    apiResult =
                        await ApiService
                            .createUser(
                      name: name,
                      email: email,
                      password:
                          password,
                      role:
                          selectedRole,
                    );
                  }

                  if (!context.mounted) {
                    return;
                  }

                  if (apiResult[
                          'success'] ==
                      true) {
                    Navigator.pop(
                      dialogContext,
                      true,
                    );

                    return;
                  }

                  ScaffoldMessenger
                      .of(context)
                      .showSnackBar(
                    SnackBar(
                      content: Text(
                        apiResult[
                                'message'] ??
                            'Ocorreu um erro.',
                      ),
                    ),
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

                child: Text(
                  isEditing
                      ? 'Guardar alterações'
                      : 'Criar utilizador',
                ),
              ),
            ],
          );
        },
      );
    },
  );

  nameController.dispose();
  emailController.dispose();
  passwordController.dispose();

  if (result == true) {
    await _loadUsers();
  }
}

Future<void> _changeUserStatus(
  dynamic user,
) async {
  final bool isActive =
      user['isActive'] ?? true;

  final action =
      isActive
          ? 'desativar'
          : 'reativar';

  final confirmed =
      await showDialog<bool>(
    context: context,

    builder: (dialogContext) {
      return AlertDialog(
        title: Text(
          isActive
              ? 'Desativar conta'
              : 'Reativar conta',
        ),

        content: Text(
          isActive
              ? 'Tem a certeza de que pretende desativar a conta de ${user['name']}? O utilizador deixará de conseguir iniciar sessão.'
              : 'Pretende reativar a conta de ${user['name']}?',
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
            onPressed: () {
              Navigator.pop(
                dialogContext,
                true,
              );
            },
            child: Text(
              isActive
                  ? 'Desativar'
                  : 'Reativar',
            ),
          ),
        ],
      );
    },
  );

  if (confirmed != true) {
    return;
  }

  final result =
      await ApiService.changeUserStatus(
    id: user['id'],
  );

  if (!mounted) return;

  if (result['success'] == true) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          'Conta ${action == 'desativar' ? 'desativada' : 'reativada'} com sucesso.',
        ),
      ),
    );

    await _loadUsers();

    return;
  }

  ScaffoldMessenger.of(context)
      .showSnackBar(
    SnackBar(
      content: Text(
        result['message'] ??
            'Não foi possível alterar o estado da conta.',
      ),
    ),
  );
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
          'Gestão de Utilizadores',
        ),

        actions: [
          Padding(
            padding:
                const EdgeInsets.only(
              right: 25,
            ),

            child:
                ElevatedButton.icon(
              onPressed: () {
                _showUserDialog();
              },

              icon:
                  const Icon(Icons.add),

              label: const Text(
                'Criar utilizador',
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

        child: Container(
          width: double.infinity,

          padding:
              const EdgeInsets.all(25),

          decoration: BoxDecoration(
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
              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,

                children: [
                  const Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [
                      Text(
                        'Utilizadores',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 5),

                      Text(
                        'Gerir as contas e os papéis dos utilizadores do BioRegisto.',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    width: 320,

                    child: TextField(
                      controller:
                          _searchController,

                      onChanged:
                          _filterUsers,

                      decoration:
                          InputDecoration(
                        hintText:
                            'Pesquisar utilizador...',

                        prefixIcon:
                            const Icon(
                          Icons.search,
                        ),

                        filled: true,

                        fillColor:
                            Colors.grey
                                .shade50,

                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            12,
                          ),

                          borderSide:
                              BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              Expanded(
                child: _isLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(),
                      )
                    : _filteredUsers
                            .isEmpty
                        ? const Center(
                            child: Text(
                              'Não foram encontrados utilizadores.',
                              style:
                                  TextStyle(
                                color:
                                    Colors.grey,
                              ),
                            ),
                          )
                        : ListView
                            .separated(
                            itemCount:
                                _filteredUsers
                                    .length,

                            separatorBuilder:
                                (
                              context,
                              index,
                            ) =>
                                    const Divider(
                              height: 1,
                            ),

                            itemBuilder:
                                (
                              context,
                              index,
                            ) {
                              final user =
                                  _filteredUsers[
                                      index];

                              final role =
                                  (user['role'] ??
                                          'Observer')
                                      .toString();

                              final bool isActive =
                                  user['isActive'] ?? true;

                              return ListTile(
                                contentPadding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal:
                                      10,
                                  vertical:
                                      8,
                                ),

                                leading:
                                    CircleAvatar(
                                  backgroundColor:
                                      AppColors
                                          .primary
                                          .withOpacity(
                                    0.10,
                                  ),

                                  child: Icon(
                                    _roleIcon(
                                      role,
                                    ),

                                    color:
                                        AppColors
                                            .primary,
                                  ),
                                ),

                                title: Text(
                                  user['name'] ??
                                      'Sem nome',

                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .w600,
                                  ),
                                ),

                                subtitle: Row(
                                  children: [
                                    Text(
                                      user['email'] ?? '',
                                    ),

                                    const SizedBox(width: 10),

                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),

                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? AppColors.primary
                                                .withOpacity(0.10)
                                            : Colors.red
                                                .withOpacity(0.08),

                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),

                                      child: Text(
                                        isActive
                                            ? 'Ativo'
                                            : 'Inativo',

                                        style: TextStyle(
                                          fontSize: 11,

                                          color: isActive
                                              ? AppColors.primary
                                              : Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                trailing:
                                    Row(
                                  mainAxisSize:
                                      MainAxisSize
                                          .min,

                                  children: [
                                    Container(
                                      padding:
                                          const EdgeInsets
                                              .symmetric(
                                        horizontal:
                                            12,
                                        vertical:
                                            6,
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
                                        _roleLabel(
                                          role,
                                        ),

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
                                      width: 15,
                                    ),

                                    IconButton(
                                     onPressed:
                                      role == 'Admin'
                                          ? null
                                          : () {
                                              _showUserDialog(
                                                user: user,
                                              );
                                            },

                                      tooltip:
                                          'Gerir utilizador',

                                      icon:
                                          const Icon(
                                        Icons
                                            .edit_outlined,
                                      ),
                                    ),
                                    if (role != 'Admin')
                                    PopupMenuButton<String>(
                                      tooltip: 'Mais opções',

                                      onSelected: (value) {
                                        if (value == 'status') {
                                          _changeUserStatus(user);
                                        }
                                      },

                                      itemBuilder: (context) => [
                                        PopupMenuItem<String>(
                                          value: 'status',

                                          child: Row(
                                            children: [
                                              Icon(
                                                isActive
                                                    ? Icons.block_outlined
                                                    : Icons
                                                        .check_circle_outline,

                                                color: isActive
                                                    ? Colors.red
                                                    : AppColors.primary,
                                              ),

                                              const SizedBox(width: 10),

                                              Text(
                                                isActive
                                                    ? 'Desativar conta'
                                                    : 'Reativar conta',
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
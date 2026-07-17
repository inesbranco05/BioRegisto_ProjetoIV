import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../utils/app_colors.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
  });

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {
  late final TextEditingController
      _nameController;

  late final TextEditingController
      _emailController;

  final _formKey =
      GlobalKey<FormState>();

  bool _isLoading = false;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();

    final user =
        ApiService.currentUser;

    _nameController =
        TextEditingController(
      text:
          user?['name']?.toString() ??
              '',
    );

    _emailController =
        TextEditingController(
      text:
          user?['email']?.toString() ??
              '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();

    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result =
        await ApiService.updateProfile(
      name:
          _nameController.text.trim(),

      email:
          _emailController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Perfil atualizado com sucesso.',
          ),
        ),
      );

      Navigator.pop(
        context,
        true,
      );

      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          result['message'] ??
              'Não foi possível atualizar o perfil.',
        ),
      ),
    );
  }
Future<void> _pickProfileImage() async {
  final picker =
      ImagePicker();

  final image =
      await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 85,
  );

  if (image == null) {
    return;
  }

  final bytes =
      await image.readAsBytes();

  if (!mounted) return;

  setState(() {
    _selectedImageBytes = bytes;
    _selectedImageName = image.name;
    _isUploadingImage = true;
  });

  final result =
      await ApiService.updateProfileImage(
    imageBytes: bytes,
    imageName: image.name,
  );

  if (!mounted) return;

  setState(() {
    _isUploadingImage = false;
  });

  if (result['success'] == true) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Fotografia atualizada com sucesso.',
        ),
      ),
    );

    return;
  }

  ScaffoldMessenger.of(context)
      .showSnackBar(
    SnackBar(
      content: Text(
        result['message'] ??
            'Não foi possível atualizar a fotografia.',
      ),
    ),
  );
}

  @override
  Widget build(
    BuildContext context,
  ) {

    final profileImageUrl =
    ApiService
        .currentUser?[
            'profileImageUrl']
        ?.toString();

final fullProfileImageUrl =
    profileImageUrl != null &&
            profileImageUrl.isNotEmpty
        ? profileImageUrl.startsWith(
            'http',
          )
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

        foregroundColor:
            Colors.white,

        title: const Text(
          'Editar perfil',
        ),

        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(
          20,
        ),

        child: Form(
          key: _formKey,

          child: Column(
            children: [
              const SizedBox(
                height: 15,
              ),

              Stack(
  clipBehavior: Clip.none,

  children: [
   CircleAvatar(
  radius: 55,

  backgroundColor:
      AppColors.primary.withOpacity(
    0.12,
  ),

  backgroundImage:
      _selectedImageBytes != null
          ? MemoryImage(
              _selectedImageBytes!,
            )
          : fullProfileImageUrl != null
              ? NetworkImage(
                  fullProfileImageUrl,
                )
              : null,

  child:
      _selectedImageBytes == null &&
              fullProfileImageUrl == null
          ? Icon(
              Icons.person,
              size: 60,
              color:
                  AppColors.primary,
            )
          : null,
),

    Positioned(
      right: -5,
      bottom: 0,

      child: Material(
        color: AppColors.primary,
        shape: const CircleBorder(),

        child: IconButton(
          tooltip:
              'Alterar fotografia',

          onPressed:
              _isUploadingImage
                  ? null
                  : _pickProfileImage,

          icon:
              _isUploadingImage
                  ? const SizedBox(
                      width: 20,
                      height: 20,

                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color:
                            Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons
                          .photo_camera_outlined,

                      color:
                          Colors.white,
                    ),
        ),
      ),
    ),
  ],
),

const SizedBox(
  height: 30,
),

              const SizedBox(
                height: 10,
              ),

              const SizedBox(
                height: 30,
              ),

              TextFormField(
                controller:
                    _nameController,

                decoration:
                    const InputDecoration(
                  labelText: 'Nome',

                  prefixIcon:
                      Icon(
                    Icons.person_outline,
                  ),

                  border:
                      OutlineInputBorder(),
                ),

                validator: (
                  value,
                ) {
                  if (value == null ||
                      value
                          .trim()
                          .isEmpty) {
                    return 'Introduza o seu nome.';
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 20,
              ),

              TextFormField(
                controller:
                    _emailController,

                keyboardType:
                    TextInputType
                        .emailAddress,

                decoration:
                    const InputDecoration(
                  labelText: 'Email',

                  prefixIcon:
                      Icon(
                    Icons.email_outlined,
                  ),

                  border:
                      OutlineInputBorder(),
                ),

                validator: (
                  value,
                ) {
                  if (value == null ||
                      value
                          .trim()
                          .isEmpty) {
                    return 'Introduza o seu email.';
                  }

                  final email =
                      value.trim();

                  if (!email.contains(
                    '@',
                  )) {
                    return 'Introduza um email válido.';
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 30,
              ),

              SizedBox(
                width:
                    double.infinity,

                height: 50,

                child:
                    ElevatedButton(
                  onPressed:
                      _isLoading
                          ? null
                          : _saveProfile,

                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        AppColors.primary,

                    foregroundColor:
                        Colors.white,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        15,
                      ),
                    ),
                  ),

                  child:
                      _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,

                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2,

                                color:
                                    Colors.white,
                              ),
                            )
                          : const Text(
                              'Guardar alterações',

                              style:
                                  TextStyle(
                                fontSize:
                                    16,

                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
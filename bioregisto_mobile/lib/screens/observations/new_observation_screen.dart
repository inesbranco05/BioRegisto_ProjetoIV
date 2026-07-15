import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../services/api_service.dart';
import 'my_observations_screen.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NewObservationScreen extends StatefulWidget {
  const NewObservationScreen({super.key});

  @override
  State<NewObservationScreen> createState() =>
      _NewObservationScreenState();
}

class _NewObservationScreenState
    extends State<NewObservationScreen> {
  final _scientificController = TextEditingController();
  final _commonController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  final MapController _mapController = MapController();

  final TextEditingController _locationSearchController =
    TextEditingController();

  bool _isSearchingLocation = false;

  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  bool _isPickingImage = false;

    bool _isLoading = false;

    double? _latitude;
    double? _longitude;

    bool _isLoadingLocation = false;
    String? _locationError;



  @override
  void dispose() {
    _scientificController.dispose();
    _commonController.dispose();
    _locationSearchController.dispose();
    super.dispose();
  }

  Future<void> _submitObservation() async {
    // Retirar espaços desnecessários
    final scientificName =
        _scientificController.text.trim();

    final commonName =
        _commonController.text.trim();

    // Validar campos obrigatórios
    if (scientificName.isEmpty ||
        commonName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Por favor, preencha todos os campos obrigatórios.",
          ),
        ),
      );

      return;
    }

    if (_latitude == null ||
      _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Por favor, defina a localização da observação.",
          ),
        ),
      );

      return;
    }

    // Ativar loading
    setState(() {
      _isLoading = true;
    });

    try {
      final success =
        await ApiService.createObservation(
        scientificName: scientificName,
        commonName: commonName,
        latitude: _latitude!,
        longitude: _longitude!,
        imageBytes: _selectedImageBytes,
        imageName: _selectedImage?.name,
      );

      if (!mounted) return;

      if (success) {
        // Mostrar mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Observação submetida com sucesso!",
            ),
          ),
        );

        // Abrir a lista de observações
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const MyObservationsScreen(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Não foi possível guardar a observação.",
            ),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Erro ao comunicar com o servidor: $error",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        _isPickingImage = true;
      });

      final image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image == null) {
        return;
      }

      final bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        _selectedImage = image;
        _selectedImageBytes = bytes;
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Não foi possível selecionar a fotografia: $error",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() {
          _locationError =
              'Os serviços de localização estão desativados.';
        });

        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission ==
          LocationPermission.denied) {
        permission =
            await Geolocator.requestPermission();
      }

      if (permission ==
          LocationPermission.denied) {
        setState(() {
          _locationError =
              'A permissão de localização foi recusada.';
        });

        return;
      }

      if (permission ==
          LocationPermission.deniedForever) {
        setState(() {
          _locationError =
              'A permissão de localização foi permanentemente recusada.';
        });

        return;
      }

      final position =
          await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _locationError =
            'Não foi possível obter a localização.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  Future<void> _searchLocation() async {
    final query =
        _locationSearchController.text.trim();

    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Escreva o nome de um local para pesquisar.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isSearchingLocation = true;
      _locationError = null;
    });

    try {
      final uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/search',
        {
          'q': query,
          'format': 'json',
          'limit': '1',
          'countrycodes': 'pt',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Erro na pesquisa da localização.',
        );
      }

      final List<dynamic> results =
          jsonDecode(response.body);

      if (results.isEmpty) {
        if (!mounted) return;

        setState(() {
          _locationError =
              'Não foi encontrado nenhum local com esse nome.';
        });

        return;
      }

      final latitude =
          double.parse(results.first['lat']);

      final longitude =
          double.parse(results.first['lon']);

      if (!mounted) return;

      setState(() {
        _latitude = latitude;
        _longitude = longitude;
      });

      // Espera que o mapa seja criado/atualizado.
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          try {
            _mapController.move(
              LatLng(
                latitude,
                longitude,
              ),
              16,
            );
          } catch (_) {
            // Na primeira criação, o initialCenter
            // já posiciona corretamente o mapa.
          }
        },
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _locationError =
            'Não foi possível pesquisar o local.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSearchingLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F7F3),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFFF4F7F3),

        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black54,
          ),

          onPressed: _isLoading
              ? null
              : () {
                  Navigator.pop(context);
                },
        ),

        title: const Text(
          "Nova Observação",

          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),

        centerTitle: true,

        actions: [
          TextButton(
            onPressed: _isLoading
                ? null
                : () {
                    Navigator.pop(context);
                  },

            child: const Text(
              "Cancelar",

              style: TextStyle(
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
           // FOTOGRAFIA
          Container(
            padding: const EdgeInsets.all(15),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  "Fotografia",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 15),

                // PRÉ-VISUALIZAÇÃO
                if (_selectedImageBytes != null) ...[
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),

                        child: Image.memory(
                          _selectedImageBytes!,
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                        ),
                      ),

                      Positioned(
                        top: 10,
                        right: 10,

                        child: CircleAvatar(
                          backgroundColor:
                              Colors.black.withOpacity(0.6),

                          child: IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                            ),

                            onPressed: () {
                              setState(() {
                                _selectedImage = null;
                                _selectedImageBytes = null;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

        const SizedBox(height: 15),
      ],

      if (_isPickingImage)
        const Padding(
          padding: EdgeInsets.all(30),

          child: Center(
            child: CircularProgressIndicator(),
          ),
        )
      else
        Row(
          children: [
            Expanded(
              child: _photoButton(
                "Câmara",
                Icons.camera_alt,
                _selectedImage != null,
                () {
                  _pickImage(
                    ImageSource.camera,
                  );
                },
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _photoButton(
                "Galeria",
                Icons.photo_library,
                false,
                () {
                  _pickImage(
                    ImageSource.gallery,
                  );
                },
              ),
            ),
          ],
        ),
    ],
  ),
),
            const SizedBox(height: 20),

            // ESPÉCIE CIENTÍFICA
            const Text(
              "Espécie (científico)",
            ),

            const SizedBox(height: 8),

            TextField(
              controller:
                  _scientificController,

              enabled: !_isLoading,

              decoration: InputDecoration(
                hintText:
                    "Ex: Passer domesticus",

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // NOME COMUM
            const Text(
              "Nome comum",
            ),

            const SizedBox(height: 8),

            TextField(
              controller:
                  _commonController,

              enabled: !_isLoading,

              decoration: InputDecoration(
                hintText:
                    "Ex: Pardal-comum",

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // LOCALIZAÇÃO
            const Text(
              "Localização",
            ),

            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),

              decoration: BoxDecoration(
                color: const Color(0xFFF0F5EF),
                borderRadius: BorderRadius.circular(15),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 18,
                        color: Color(0xFF6E916F),
                      ),

                      SizedBox(width: 5),

                      Text(
                        "Localização da observação",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  if (_isLoadingLocation)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_latitude != null &&
                      _longitude != null) ...[
                    Text(
                      "Latitude: ${_latitude!.toStringAsFixed(6)}",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),

                    Text(
                      "Longitude: ${_longitude!.toStringAsFixed(6)}",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextButton.icon(
                      onPressed: _getCurrentLocation,
                      icon: const Icon(
                        Icons.my_location,
                      ),
                      label: const Text(
                        "Voltar à minha localização atual",
                      ),
                    ),
                  ] else ...[
                    const Text(
                      "Ainda não foi definida uma localização.",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 10),

                    ElevatedButton.icon(
                      onPressed: _getCurrentLocation,
                      icon: const Icon(
                        Icons.my_location,
                      ),
                      label: const Text(
                        "Usar localização atual",
                      ),
                    ),
                  ],

                  if (_locationError != null) ...[
                    const SizedBox(height: 8),

                    Text(
                      _locationError!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 15),

        Container(
          padding: const EdgeInsets.all(15),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              const Text(
                'Pesquisar localização',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Pode pesquisar o local onde realizou a observação.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller:
                    _locationSearchController,

                onSubmitted: (_) {
                  _searchLocation();
                },

                decoration: InputDecoration(
                  hintText:
                      'Ex: Parque da Cidade, Viana do Castelo',

                  prefixIcon:
                      const Icon(Icons.search),

                  suffixIcon: _isSearchingLocation
                      ? const Padding(
                          padding:
                              EdgeInsets.all(14),
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : IconButton(
                          onPressed:
                              _searchLocation,

                          icon: const Icon(
                            Icons.arrow_forward,
                          ),
                        ),

                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),

            const SizedBox(height: 15),

            // MAPA IINTERATIVO
            Container(
              width: double.infinity,
              height: 250,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
              child: _latitude == null ||
                      _longitude == null
                  ? Container(
                      color: Colors.grey.shade200,
                      child: const Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 50,
                            color: Color(0xFF7D9DB4),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    )
                  : FlutterMap(
                      mapController: _mapController,

                      options: MapOptions(
                        initialCenter: LatLng(
                          _latitude!,
                          _longitude!,
                        ),

                        initialZoom: 16,

                        // Permite escolher outro ponto
                        // tocando diretamente no mapa.
                        onTap: (tapPosition, point) {
                          setState(() {
                            _latitude = point.latitude;
                            _longitude = point.longitude;
                          });
                        },
                      ),

                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                          userAgentPackageName:
                              'com.example.bioregisto_mobile',
                        ),

                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(
                                _latitude!,
                                _longitude!,
                              ),

                              width: 50,
                              height: 50,

                              child: const Icon(
                                Icons.location_on,
                                size: 45,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 30),

            // BOTÃO SUBMETER
            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : _submitObservation,

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.primary,

                  foregroundColor:
                      Colors.white,

                  disabledBackgroundColor:
                      AppColors.primary
                          .withOpacity(0.6),

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),
                ),

                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,

                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2.5,

                          color:
                              Colors.white,
                        ),
                      )
                    : const Text(
                        "Submeter Observação",

                        style: TextStyle(
                          fontSize: 16,

                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

 Widget _photoButton(
  String title,
  IconData icon,
  bool selected,
  VoidCallback onTap,
) {
  return InkWell(
    onTap: onTap,

    borderRadius: BorderRadius.circular(15),

    child: Container(
      height: 120,

      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFF6E916F)
            : Colors.white,

        border: Border.all(
          color: const Color(0xFF6E916F),
        ),

        borderRadius: BorderRadius.circular(15),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(
            icon,
            size: 35,

            color: selected
                ? Colors.white
                : const Color(0xFF6E916F),
          ),

          const SizedBox(height: 10),

          Text(
            title,

            style: TextStyle(
              color: selected
                  ? Colors.white
                  : const Color(0xFF6E916F),
            ),
          ),
        ],
      ),
    ),
  );
}
}
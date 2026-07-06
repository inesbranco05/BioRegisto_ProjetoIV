import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../services/api_service.dart';


class NewObservationScreen extends StatefulWidget {
  const NewObservationScreen({super.key});

  @override
  State<NewObservationScreen> createState() =>
      _NewObservationScreenState();
}

class _NewObservationScreenState
    extends State<NewObservationScreen> {

  final _scientificController =
    TextEditingController();

  final _commonController =
    TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F3),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7F3),
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black54,
          ),
          onPressed: () {
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
            onPressed: () {
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
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            // FOTO
            Container(
              padding: const EdgeInsets.all(15),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  const Text(
                    "Fotografia",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [

                      Expanded(
                        child: _photoButton(
                          "Câmara",
                          Icons.camera_alt,
                          true,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _photoButton(
                          "Galeria",
                          Icons.photo_library,
                          false,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ESPÉCIE
            const Text(
              "Espécie (científico)",
            ),

            const SizedBox(height: 8),

           TextField(
              controller:
                _scientificController,

              decoration: InputDecoration(
                hintText:
                    "Ex: Passer domesticus",

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
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

                decoration: InputDecoration(
                  hintText:
                      "Ex: Pardal-comum",

                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12),
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

                borderRadius:
                    BorderRadius.circular(15),
              ),

              child: const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Row(
                    children: [

                      Icon(
                        Icons.location_on,
                        size: 18,
                        color: Color(0xFF6E916F),
                      ),

                      SizedBox(width: 5),

                      Text(
                        "Parque Ecológico Urbano",
                      ),
                    ],
                  ),

                  SizedBox(height: 5),

                  Text(
                    "Lat: 41.693° N",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),

                  Text(
                    "Lng: -8.835° W",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // MAPA PLACEHOLDER
            Container(
              width: double.infinity,
              height: 180,

              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius:
                    BorderRadius.circular(15),
              ),

              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: const [

                  Icon(
                    Icons.location_on_outlined,
                    size: 50,
                    color: Color(0xFF7D9DB4),
                  ),

                  SizedBox(height: 10),

                  Text(
                    "Mapa Interativo",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // BOTÃO
            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                onPressed: () async {

                  final success =
                      await ApiService
                          .createObservation(
                    scientificName:
                        _scientificController.text,

                    commonName:
                        _commonController.text,
                  );

                  if (!mounted) return;

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? "Observação guardada!"
                            : "Erro ao guardar.",
                      ),
                    ),
                  );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.primary,

                  foregroundColor:
                      Colors.white,

                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                ),

                child: const Text(
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
  ) {
    return Container(
      height: 120,

      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFF6E916F)
            : Colors.white,

        border: Border.all(
          color: const Color(0xFF6E916F),
        ),

        borderRadius:
            BorderRadius.circular(15),
      ),

      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

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
    );
  }
}
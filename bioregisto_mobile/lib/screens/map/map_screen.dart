import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F3),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7F3),
        elevation: 0,

        title: const Text(
          "Mapa de Biodiversidade",
          style: TextStyle(
            color: Colors.black87,
          ),
        ),

        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            TextField(
              decoration: InputDecoration(
                hintText:
                    "Pesquisar espécie...",

                prefixIcon:
                    const Icon(Icons.search),

                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 15),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,

              child: Row(
                children: [

                  _filterChip("Aves"),
                  _filterChip("Mamíferos"),
                  _filterChip("Insetos"),
                  _filterChip("Plantas"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              height: 300,

              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius:
                    BorderRadius.circular(20),
              ),

              child: Stack(
                children: [

                  const Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      children: [

                        Icon(
                          Icons.map,
                          size: 70,
                          color: Colors.grey,
                        ),

                        SizedBox(height: 10),

                        Text(
                          "Mapa Interativo",
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    top: 80,
                    left: 120,
                    child: Icon(
                      Icons.location_on,
                      color:
                          AppColors.primary,
                      size: 35,
                    ),
                  ),

                  Positioned(
                    top: 180,
                    left: 220,
                    child: Icon(
                      Icons.location_on,
                      color: Colors.orange,
                      size: 35,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Observações Próximas",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            _observationTile(
              "Pardal-comum",
              "Aprovada",
              Colors.green,
            ),

            const SizedBox(height: 10),

            _observationTile(
              "Espécie desconhecida",
              "Pendente",
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String text) {
    return Container(
      margin:
          const EdgeInsets.only(right: 10),

      child: Chip(
        label: Text(text),
      ),
    );
  }

  Widget _observationTile(
    String species,
    String status,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(15),
      ),

      child: Row(
        children: [

          Icon(
            Icons.location_on,
            color: color,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(species),
          ),

          Text(
            status,
            style: TextStyle(
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
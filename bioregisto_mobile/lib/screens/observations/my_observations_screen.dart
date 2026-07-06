import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class MyObservationsScreen extends StatelessWidget {
  const MyObservationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F3),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7F3),
        elevation: 0,

        title: const Text(
          "As minhas observações",
          style: TextStyle(
            color: Colors.black87,
          ),
        ),

        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            TextField(
              decoration: InputDecoration(
                hintText: "Pesquisar espécie...",

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

            const SizedBox(height: 20),

            Row(
              children: [

                _filterButton(
                  "Todas (4)",
                  true,
                ),

                const SizedBox(width: 10),

                _filterButton(
                  "Verificadas (3)",
                  false,
                ),

                const SizedBox(width: 10),

                _filterButton(
                  "Pendentes (1)",
                  false,
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [

                Expanded(
                  child: _statCard(
                    "4",
                    "Total",
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _statCard(
                    "4",
                    "Espécies",
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _statCard(
                    "3",
                    "Verificadas",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            _observationCard(
              "Pardal-comum",
              "Passer domesticus",
              "Verificada",
            ),

            const SizedBox(height: 15),

            _observationCard(
              "Tentilhão-comum",
              "Fringilla coelebs",
              "Verificada",
            ),

            const SizedBox(height: 15),

            _observationCard(
              "Carvalho-alvarinho",
              "Quercus robur",
              "Verificada",
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterButton(
    String text,
    bool selected,
  ) {
    return Expanded(
      child: Container(
        height: 40,

        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : Colors.white,

          borderRadius:
              BorderRadius.circular(10),
        ),

        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,

            style: TextStyle(
              color: selected
                  ? Colors.white
                  : Colors.black87,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard(
    String value,
    String label,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius:
            BorderRadius.circular(15),
      ),

      child: Column(
        children: [

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _observationCard(
    String commonName,
    String scientificName,
    String status,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Row(
        children: [

          Container(
            width: 70,
            height: 70,

            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius:
                  BorderRadius.circular(15),
            ),

            child: const Icon(
              Icons.image,
              size: 35,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  commonName,
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                Text(
                  scientificName,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontStyle:
                        FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  status,
                  style: const TextStyle(
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
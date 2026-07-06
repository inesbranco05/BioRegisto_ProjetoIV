import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F3),

      appBar: AppBar(
        backgroundColor: const Color(0xFFD39B73),
        elevation: 0,

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            // HEADER
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(25),

              decoration: const BoxDecoration(
                color: Color(0xFFD39B73),

                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),

              child: const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    "Desafios",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    "Ganhe recompensas e suba na classificação",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                children: [

                  // ESTATÍSTICAS

                  Row(
                    children: [

                      Expanded(
                        child: _scoreCard(
                          "400",
                          "Os seus pontos",
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _scoreCard(
                          "4º",
                          "Classificação",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Desafios ativos",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  _challengeCard(
                    "Mês da Biodiversidade",
                    "Registe 20 espécies diferentes durante o mês.",
                    4,
                    20,
                  ),

                  const SizedBox(height: 15),

                  _challengeCard(
                    "Explorador do Parque",
                    "Visite 5 locais diferentes no Parque Ecológico.",
                    3,
                    5,
                  ),

                  const SizedBox(height: 15),

                  _challengeCard(
                    "Observador Ativo",
                    "Registe observações durante 7 dias seguidos.",
                    2,
                    7,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scoreCard(
    String value,
    String label,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Column(
        children: [

          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(label),
        ],
      ),
    );
  }

  Widget _challengeCard(
    String title,
    String description,
    int current,
    int total,
  ) {
    final progress = current / total;

    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(description),

          const SizedBox(height: 15),

          LinearProgressIndicator(
            value: progress,
            color: AppColors.primary,
            backgroundColor:
                Colors.grey.shade300,
          ),

          const SizedBox(height: 8),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "$current / $total",
            ),
          ),

          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,

            child: ElevatedButton(
              onPressed: () {},

              style: ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.primary,
                foregroundColor:
                    Colors.white,
              ),

              child: const Text(
                "Ver detalhes",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
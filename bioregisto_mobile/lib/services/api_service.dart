import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'http://localhost:5025/api';

  static Future<bool> createObservation({
    required String scientificName,
    required String commonName,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/Observations',
      ),

      headers: {
        'Content-Type':
            'application/json',
      },

      body: jsonEncode({
        'scientificName':
            scientificName,

        'commonName':
            commonName,

        'latitude': 41.693,

        'longitude': -8.832,

        'status': 'Pending',
      }),
    );

    return response.statusCode == 200;
  }
}
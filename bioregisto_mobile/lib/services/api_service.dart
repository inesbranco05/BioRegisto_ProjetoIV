import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';

class ApiService {
  static const String baseUrl =
      'http://localhost:5025/api';

  // Dados da sessão atual
  static String? authToken;
  static Map<String, dynamic>? currentUser;

  // =========================
  // CRIAR OBSERVAÇÃO
  // =========================

  static Future<bool> createObservation({
    required String scientificName,
    required String commonName,
    required double latitude,
    required double longitude,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/Observations'),
      );

      request.headers['Authorization'] =
          'Bearer $authToken';

      request.fields['scientificName'] =
          scientificName;

      request.fields['commonName'] =
          commonName;

      request.fields['latitude'] =
        latitude.toString();

      request.fields['longitude'] =
        longitude.toString();

      if (imageBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename:
                imageName ?? 'observation.jpg',
          ),
        );
      }

      final response =
          await request.send();

      return response.statusCode == 200;
    } catch (error) {
      return false;
    }
  }
  // =========================
  // OBTER OBSERVAÇÕES
  // =========================

  static Future<List<dynamic>>
      getObservations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/Observations'),
      headers: {
        if (authToken != null)
          'Authorization':
              'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Erro ao carregar observações',
    );
  }

  // =========================
  // OBTER OBSERVAÇÕES DA COMUNIDADE
  // =========================
  static Future<List<dynamic>>
    getMapObservations() async {
  final response = await http.get(
    Uri.parse(
      '$baseUrl/Observations/map',
    ),
    headers: {
      if (authToken != null)
      'Authorization':
          'Bearer $authToken',
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }

  throw Exception(
    'Erro ao carregar as observações do mapa',
  );
}

  // =========================
  // REGISTO
  // =========================

  static Future<String?> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Auth/register'),
        headers: {
          'Content-Type':
              'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return null;
      }

      final data =
          jsonDecode(response.body);

      return data['message'] ??
          'Não foi possível criar a conta.';
    } catch (error) {
      return 'Não foi possível comunicar com o servidor.';
    }
  }

  // =========================
  // LOGIN
  // =========================

  static Future<Map<String, dynamic>>
      loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Auth/login'),
        headers: {
          'Content-Type':
              'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data =
          jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Guardar JWT
        authToken = data['token'];

        // Guardar dados do utilizador
        currentUser =
            Map<String, dynamic>.from(
          data['user'],
        );

        final prefs =
          await SharedPreferences.getInstance();

        await prefs.setString(
          'authToken',
          authToken!,
        );

        await prefs.setString(
          'currentUser',
          jsonEncode(currentUser),
        );

                return {
          'success': true,
          'token': authToken,
          'user': currentUser,
        };
      }

      return {
        'success': false,
        'message':
            data['message'] ??
                'Não foi possível iniciar sessão.',
      };
    } catch (error) {
      return {
        'success': false,
        'message':
            'Não foi possível comunicar com o servidor.',
      };
    }
  }

  // =========================
  // LOGOUT
  // =========================

 static Future<void> logout() async {
  authToken = null;
  currentUser = null;

  final prefs =
      await SharedPreferences.getInstance();

  await prefs.remove('authToken');
  await prefs.remove('currentUser');
}

  // =========================
  // VERIFICAR LOGIN
  // =========================

  static bool get isLoggedIn =>
      authToken != null;

  static Future<bool> restoreSession() async {
    final prefs =
        await SharedPreferences.getInstance();

    final savedToken =
        prefs.getString('authToken');

    final savedUser =
        prefs.getString('currentUser');

    if (savedToken == null ||
        savedUser == null) {
      return false;
    }

    authToken = savedToken;

    currentUser =
        Map<String, dynamic>.from(
      jsonDecode(savedUser),
    );

    return true;
  }
}
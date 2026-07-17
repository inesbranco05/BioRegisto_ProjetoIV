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

  // =========================
  // NOTIFICAÇÕES
  // =========================

  static Future<List<dynamic>>
    getNotifications() async {
  final response = await http.get(
    Uri.parse(
      '$baseUrl/Notifications',
    ),
    headers: {
      'Authorization':
          'Bearer $authToken',
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }

  throw Exception(
    'Erro ao carregar notificações.',
  );
}

// =========================
  // EVENTOS E DESAFIOS
  // =========================

static Future<List<dynamic>>
    getEventChallenges() async {
  final response = await http.get(
    Uri.parse(
      '$baseUrl/EventChallenges',
    ),
    headers: {
      'Authorization':
          'Bearer $authToken',
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }

  throw Exception(
    'Erro ao carregar eventos e desafios.',
  );
}
// =========================
// ATUALIZAR PERFIL
// =========================

static Future<Map<String, dynamic>>
    updateProfile({
  required String name,
  required String email,
}) async {
  try {
    final response =
        await http.put(
      Uri.parse(
        '$baseUrl/Auth/profile',
      ),

      headers: {
        'Content-Type':
            'application/json',

        'Authorization':
            'Bearer $authToken',
      },

      body: jsonEncode({
        'name': name,
        'email': email,
      }),
    );

    final data =
        jsonDecode(response.body);

    if (response.statusCode == 200) {
      // Atualizar os dados
      // guardados na sessão.
      currentUser = Map<String, dynamic>
          .from(data);

      return {
        'success': true,
        'user': data,
      };
    }

    return {
      'success': false,
      'message':
          data['message'] ??
              'Não foi possível atualizar o perfil.',
    };
  } catch (error) {
    return {
      'success': false,
      'message':
          'Erro de ligação ao servidor.',
    };
  }
}

// =========================
// FOTO PERFIL
// =========================

static Future<Map<String, dynamic>>
    updateProfileImage({
  required Uint8List imageBytes,
  required String imageName,
}) async {
  try {
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse(
        '$baseUrl/Auth/profile/image',
      ),
    );

    request.headers['Authorization'] =
        'Bearer $authToken';

    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: imageName,
      ),
    );

    final streamedResponse =
        await request.send();

    final response =
        await http.Response.fromStream(
      streamedResponse,
    );

    final data =
        jsonDecode(response.body);

    if (response.statusCode == 200) {
      currentUser =
          Map<String, dynamic>.from(
        data,
      );

      return {
        'success': true,
        'user': data,
      };
    }

    return {
      'success': false,
      'message':
          data['message'] ??
              'Não foi possível atualizar a fotografia.',
    };
  } catch (error) {
    return {
      'success': false,
      'message':
          'Erro de ligação ao servidor.',
    };
  }
}
// =========================
// RECUPERAR PALAVRA-PASSE
// =========================

static Future<Map<String, dynamic>>
    forgotPassword({
  required String email,
}) async {
  try {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/Auth/forgot-password',
      ),
      headers: {
        'Content-Type':
            'application/json',
      },
      body: jsonEncode({
        'email': email.trim(),
      }),
    );

    final data =
        jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': data['message'],
      };
    }

    return {
      'success': false,
      'message':
          data['message'] ??
              'Não foi possível enviar o código.',
    };
  } catch (error) {
    return {
      'success': false,
      'message':
          'Erro de ligação ao servidor.',
    };
  }
}

// =========================
// REDEFINIR PALAVRA-PASSE
// =========================

static Future<Map<String, dynamic>>
    resetPassword({
  required String email,
  required String code,
  required String newPassword,
}) async {
  try {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/Auth/reset-password',
      ),
      headers: {
        'Content-Type':
            'application/json',
      },
      body: jsonEncode({
        'email': email.trim(),
        'code': code.trim(),
        'newPassword': newPassword,
      }),
    );

    final data =
        jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {
        'success': true,
        'message':
            data['message'] ??
                'Palavra-passe alterada com sucesso.',
      };
    }

    return {
      'success': false,
      'message':
          data['message'] ??
              'Não foi possível alterar a palavra-passe.',
    };
  } catch (error) {
    return {
      'success': false,
      'message':
          'Erro de ligação ao servidor.',
    };
  }
}
}
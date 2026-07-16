import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl =
      'http://localhost:5025/api';

  static String? authToken;

  static Map<String, dynamic>? currentUser;

  // =========================
  // LOGIN
  // =========================

  static Future<Map<String, dynamic>>
      login({
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

      if (response.statusCode != 200) {
        return {
          'success': false,
          'message':
              data['message'] ??
                  'Credenciais inválidas.',
        };
      }

      final user =
          Map<String, dynamic>.from(
        data['user'],
      );

      final role =
          user['role']?.toString();

      // Apenas Admin e Validator
      if (role != 'Admin' &&
          role != 'Validator') {
        return {
          'success': false,
          'message':
              'Esta conta não tem acesso ao backoffice.',
        };
      }

      authToken =
          data['token'];

      currentUser =
          user;

      final prefs =
          await SharedPreferences
              .getInstance();

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
        'user': currentUser,
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
        await SharedPreferences
            .getInstance();

    await prefs.remove(
      'authToken',
    );

    await prefs.remove(
      'currentUser',
    );
  }

  // =========================
// OBSERVAÇÕES PENDENTES
// =========================

static Future<List<dynamic>>
    getPendingObservations() async {
  final response = await http.get(
    Uri.parse(
      '$baseUrl/Validation/pending',
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
    'Não foi possível carregar as observações pendentes.',
  );
}

static String getImageUrl(
  String? imageUrl,
) {
  if (imageUrl == null ||
      imageUrl.isEmpty) {
    return '';
  }

  return '${baseUrl.replaceFirst('/api', '')}$imageUrl';
}

// =========================
// TAXONOMIA - RAÍZES
// =========================

static Future<List<dynamic>>
    getRootTaxa() async {
  final response = await http.get(
    Uri.parse(
      '$baseUrl/Taxonomy/roots',
    ),
    headers: {
      if (authToken != null)
        'Authorization':
            'Bearer $authToken',
    },
  );

  if (response.statusCode == 200) {
    return List<dynamic>.from(
      jsonDecode(response.body),
    );
  }

  throw Exception(
    'Não foi possível carregar a taxonomia.',
  );
}

// =========================
// TAXONOMIA - FILHOS
// =========================

static Future<List<dynamic>>
    getTaxonChildren(
  int parentId,
) async {
  final response = await http.get(
    Uri.parse(
      '$baseUrl/Taxonomy/$parentId/children',
    ),
    headers: {
      if (authToken != null)
        'Authorization':
            'Bearer $authToken',
    },
  );

  if (response.statusCode == 200) {
    return List<dynamic>.from(
      jsonDecode(response.body),
    );
  }

  throw Exception(
    'Não foi possível carregar o nível taxonómico seguinte.',
  );
}
// =========================
// TAXONOMIA - CRIAR
// =========================

static Future<Map<String, dynamic>> createTaxon({
  required String name,
  required String rank,
  int? parentId,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/Taxonomy'),
      headers: {
        'Content-Type': 'application/json',
        if (authToken != null)
          'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'name': name,
        'rank': rank,
        'parentId': parentId,
      }),
    );

    if (response.statusCode == 200) {
      return {
        'success': true,
        'taxon': jsonDecode(response.body),
      };
    }

    final data = jsonDecode(response.body);

    return {
      'success': false,
      'message':
          data['message'] ??
          'Não foi possível criar o táxon.',
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
// TAXONOMIA - EDITAR
// =========================
static Future<Map<String, dynamic>>
    updateTaxon({
  required int id,
  required String name,
}) async {
  try {
    final response = await http.put(
      Uri.parse(
        '$baseUrl/Taxonomy/$id',
      ),
      headers: {
        'Content-Type':
            'application/json',
        if (authToken != null)
          'Authorization':
              'Bearer $authToken',
      },
      body: jsonEncode({
        'name': name,
      }),
    );

    if (response.statusCode == 200) {
      return {
        'success': true,
        'taxon':
            jsonDecode(response.body),
      };
    }

    final data =
        jsonDecode(response.body);

    return {
      'success': false,
      'message':
          data['message'] ??
              'Não foi possível atualizar o táxon.',
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
// VALIDAR OBSERVAÇÃO
// =========================

static Future<Map<String, dynamic>>
    approveObservation({
  required int observationId,
  required int taxonId,
  required String commonName,
  required String scientificName,
  String? notes,
}) async {
  try {
    final response = await http.put(
      Uri.parse(
        '$baseUrl/Validation/$observationId/approve',
      ),
      headers: {
        'Content-Type': 'application/json',
        if (authToken != null)
          'Authorization':
              'Bearer $authToken',
      },
      body: jsonEncode({
        'taxonId': taxonId,
        'commonName': commonName,
        'scientificName': scientificName,
        'notes': notes,
      }),
    );

    if (response.statusCode == 200) {
      return {
        'success': true,
      };
    }

    final data = jsonDecode(
      response.body,
    );

    return {
      'success': false,
      'message':
          data['message'] ??
              'Não foi possível validar a observação.',
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
// REJEITAR OBSERVAÇÃO
// =========================

static Future<Map<String, dynamic>>
    rejectObservation({
  required int observationId,
  required String reason,
  String? notes,
}) async {
  try {
    final response = await http.put(
      Uri.parse(
        '$baseUrl/Validation/$observationId/reject',
      ),
      headers: {
        'Content-Type': 'application/json',
        if (authToken != null)
          'Authorization':
              'Bearer $authToken',
      },
      body: jsonEncode({
        'reason': reason,
        'notes': notes,
      }),
    );

    if (response.statusCode == 200) {
      return {
        'success': true,
      };
    }

    final data = jsonDecode(
      response.body,
    );

    return {
      'success': false,
      'message':
          data['message'] ??
              'Não foi possível rejeitar a observação.',
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
// ESTATÍSTICAS DO VALIDADOR
// =========================

static Future<Map<String, dynamic>>
    getValidatorStats() async {
  final response = await http.get(
    Uri.parse(
      '$baseUrl/Validation/stats',
    ),
    headers: {
      if (authToken != null)
        'Authorization':
            'Bearer $authToken',
    },
  );

  if (response.statusCode == 200) {
    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }

  throw Exception(
    'Não foi possível carregar as estatísticas.',
  );
}
// =========================
// HISTÓRICO DE VALIDAÇÕES
// =========================

static Future<List<dynamic>>
    getValidationHistory() async {
  final response = await http.get(
    Uri.parse(
      '$baseUrl/Validation/history',
    ),
    headers: {
      if (authToken != null)
        'Authorization':
            'Bearer $authToken',
    },
  );

  if (response.statusCode == 200) {
    return List<dynamic>.from(
      jsonDecode(response.body),
    );
  }

  throw Exception(
    'Não foi possível carregar o histórico de validações.',
  );
}
}
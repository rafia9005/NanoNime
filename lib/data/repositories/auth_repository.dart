import '../../utils/fetch.dart';
import 'dart:convert';
import '../models/auth.dart';

class AuthRepository {
  Future<AuthResponse> login(String identity, String password) async {
    final response = await Fetch.post(
      '/auth/login',
      body: jsonEncode({'identity': identity, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      // backend: { data: { token, user }, message, ... }
      return AuthResponse.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Login failed');
    }
  }

  Future<Map<String, dynamic>?> checkToken() async {
    final response = await Fetch.get('/user/token');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    }
    return null;
  }

  Future<void> register({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await Fetch.post(
      '/auth/register',
      body: jsonEncode({
        'name': name,
        'username': username,
        'email': email,
        'password': password,
      }),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception(
        jsonDecode(response.body)['message'] ?? 'Register failed',
      );
    }
  }
}

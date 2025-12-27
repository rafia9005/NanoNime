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
    final body = jsonDecode(response.body);
    if (response.statusCode == 200) {
      // backend: { data: { token, user }, message, ... }
      return AuthResponse.fromJson(body['data']);
    } else {
      // Tampilkan error dari field 'error' jika ada, jika tidak pakai 'message'
      final errorMsg = body['error'] ?? body['message'] ?? 'Login failed';
      throw errorMsg;
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
      final body = jsonDecode(response.body);
      final errorMsg = body['error'] ?? body['message'] ?? 'Register failed';
      throw errorMsg;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/auth_repository.dart';
import '../data/models/auth.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _repo = AuthRepository();
  String? _token;
  User? _user;

  String? get token => _token;
  User? get user => _user;

  /// Login dengan identity (username/email) dan password.
  Future<void> login(String identity, String password) async {
    final res = await _repo.login(identity, password);
    _token = res.token;
    // Simpan token ke SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', _token!);
    notifyListeners();
  }

  /// Register user baru dengan named arguments.
  Future<void> register({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    await _repo.register(
      name: name,
      username: username,
      email: email,
      password: password,
    );
    // Tidak simpan token, user harus login manual setelah register
    notifyListeners();
  }

  /// Cek validitas token dengan endpoint /user/token.
  Future<bool> checkToken() async {
    try {
      final userData = await _repo.checkToken();
      if (userData != null) {
        notifyListeners();
        return true;
      }
      await logout();
      return false;
    } catch (_) {
      await logout();
      return false;
    }
  }

  /// Logout user, hapus token dari SharedPreferences.
  Future<void> logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }
}

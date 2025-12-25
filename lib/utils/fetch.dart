import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Fetch {
  static final String _baseUrl = dotenv.get("API_URL");
  static final String _apiVersion = dotenv.get("API_VERSION");

  /// Build the full URL by prepending `/api/v{version}` if not already present.
  static String buildUrl(String path) {
    // Remove leading slash if present
    String cleanPath = path.startsWith('/') ? path.substring(1) : path;
    // Ensure /api/v{version} is only prepended if not already present
    final versionPrefix = 'api/v$_apiVersion/';
    if (cleanPath.startsWith(versionPrefix)) {
      cleanPath = cleanPath.substring(versionPrefix.length);
    }
    // Remove trailing slash from baseUrl if present
    String base = _baseUrl.endsWith('/')
        ? _baseUrl.substring(0, _baseUrl.length - 1)
        : _baseUrl;
    return '$base/$versionPrefix$cleanPath';
  }

  /// HTTP GET request with auto `/api/v1` prepend.
  static Future<http.Response> get(
    String path, {
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse(buildUrl(path));
    final mergedHeaders = await _withAuthHeader(headers);
    return http.get(url, headers: mergedHeaders);
  }

  /// HTTP POST request with auto `/api/v1` prepend.
  static Future<http.Response> post(
    String path, {
    Object? body,
    Map<String, String>? headers,
    Encoding? encoding,
  }) async {
    final url = Uri.parse(buildUrl(path));
    final mergedHeaders = await _withAuthHeader(headers);
    return http.post(
      url,
      body: body,
      headers: mergedHeaders,
      encoding: encoding,
    );
  }

  /// HTTP PUT request with auto `/api/v1` prepend.
  static Future<http.Response> put(
    String path, {
    Object? body,
    Map<String, String>? headers,
    Encoding? encoding,
  }) async {
    final url = Uri.parse(buildUrl(path));
    final mergedHeaders = await _withAuthHeader(headers);
    return http.put(
      url,
      body: body,
      headers: mergedHeaders,
      encoding: encoding,
    );
  }

  /// HTTP DELETE request with auto `/api/v1` prepend.
  static Future<http.Response> delete(
    String path, {
    Object? body,
    Map<String, String>? headers,
    Encoding? encoding,
  }) async {
    final url = Uri.parse(buildUrl(path));
    final mergedHeaders = await _withAuthHeader(headers);
    return http.delete(
      url,
      body: body,
      headers: mergedHeaders,
      encoding: encoding,
    );
  }

  /// Helper to always add Authorization Bearer token if available
  static Future<Map<String, String>> _withAuthHeader(
    Map<String, String>? headers,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final Map<String, String> merged = {...?headers};
    if (token != null && token.isNotEmpty) {
      merged['Authorization'] = 'Bearer $token';
    }
    return merged;
  }
}

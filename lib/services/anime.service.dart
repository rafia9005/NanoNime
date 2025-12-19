import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/anime.dart';

class ApiService {
  static String baseUrl = dotenv.get("API_URL");

  /// Fetch list of ongoing anime.
  Future<List<Anime>> fetchOngoingAnime() async {
    final uri = Uri.parse('$baseUrl/otakudesu/home');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'fetchOngoingAnime failed: ${response.statusCode} ${response.reasonPhrase}',
      );
    }

    final Map<String, dynamic> body = jsonDecode(response.body);
    final List<dynamic> list =
        (body['data']?['ongoing']?['animeList']) as List<dynamic>? ?? [];

    return list
        .map((item) => Anime.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  /// Fetch detailed info for an anime by its id/slug.
  Future<AnimeDetail> fetchAnimeDetail(String id) async {
    final uri = Uri.parse('$baseUrl/otakudesu/anime/$id');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'fetchAnimeDetail failed: ${response.statusCode} ${response.reasonPhrase}',
      );
    }

    final Map<String, dynamic> body = jsonDecode(response.body);
    // Normalize top-level data map
    final Map<String, dynamic> data = Map<String, dynamic>.from(
      body['data'] ?? <String, dynamic>{},
    );

    // Prefer the nested 'details' map when present — pass that to the model.
    final dynamic maybeDetails = data['details'];
    final Map<String, dynamic> detailsMap = (maybeDetails is Map)
        ? Map<String, dynamic>.from(maybeDetails)
        : data;

    return AnimeDetail.fromJson(detailsMap);
  }

  /// Fetch episode detail by episodeId (slug).
  Future<EpisodeDetail> fetchEpisodeDetail(String episodeId) async {
    final uri = Uri.parse('$baseUrl/otakudesu/episode/$episodeId');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'fetchEpisodeDetail failed: ${response.statusCode} ${response.reasonPhrase}',
      );
    }

    final Map<String, dynamic> body = jsonDecode(response.body);
    final Map<String, dynamic> data = Map<String, dynamic>.from(
      body['data'] ?? <String, dynamic>{},
    );
    return EpisodeDetail.fromJson(data);
  }

  /// Resolve a serverId to a streaming URL by calling the backend endpoint:
  ///   GET {baseUrl}/otakudesu/server/<serverId>
  ///
  /// Returns the resolved URL string on success, or null if resolution fails.
  Future<String?> resolveServerUrl(String serverId) async {
    if (serverId.isEmpty) return null;

    // serverId may contain characters that need encoding when used in a path segment
    final encoded = Uri.encodeComponent(serverId);
    final uri = Uri.parse('$baseUrl/otakudesu/server/$encoded');

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      // Caller can decide how to handle null (show error / fallback)
      return null;
    }

    try {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final dynamic data = body['data'];
      if (data is Map && data['details'] is Map) {
        final details = Map<String, dynamic>.from(data['details']);
        final dynamic url = details['url'];
        if (url is String && url.isNotEmpty) {
          return url;
        }
      }
    } catch (_) {
      // fall through and return null on parsing error
    }
    return null;
  }

  /// Search anime by query string
  Future<List<Anime>> searchAnime(String query) async {
    if (query.isEmpty) {
      return [];
    }

    final uri = Uri.parse(
      '$baseUrl/otakudesu/search',
    ).replace(queryParameters: {'q': query});
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'searchAnime failed: ${response.statusCode} ${response.reasonPhrase}',
      );
    }

    final Map<String, dynamic> body = jsonDecode(response.body);
    final List<dynamic> list =
        (body['data']?['animeList']) as List<dynamic>? ?? [];

    return list
        .map((item) => Anime.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}

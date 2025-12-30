import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:nanonime/utils/fetch.dart';

class MangaService {
  /// Fetches the list of popular manga from the API.
  /// [page] is the page number for pagination (default: 1).
  Future<List<dynamic>> fetchMangaList({int page = 1}) async {
    try {
      final response = await Fetch.get('/manga/popular/$page');
      if (response.statusCode == 200) {
        final data = Fetch.safeDecode(response);
        if (data is Map && data['manga_list'] is List) {
          return data['manga_list'];
        } else if (data is List) {
          return data;
        }
      }
    } catch (e) {
      debugPrint('Error fetching popular manga: $e');
    }
    return [];
  }

  /// Fetches the list of latest manga updates.
  Future<List<dynamic>> fetchLatestManga({int page = 1}) async {
    try {
      final response = await Fetch.get('/manga/latest/$page');
      if (response.statusCode == 200) {
        final data = Fetch.safeDecode(response);
        if (data is Map) {
          if (data['manga_list'] is List) return data['manga_list'];
          if (data['list_up'] is List)
            return data['list_up']; // Common in some APIs
          if (data['latest_list'] is List) return data['latest_list'];
          if (data['data'] is List) return data['data'];
        } else if (data is List) {
          return data;
        }
      }

      // Fallback to popular if latest endpoint is empty/broken
      debugPrint('Latest manga list empty, falling back to popular list.');
      return await fetchMangaList(page: page);
    } catch (e) {
      debugPrint('Error fetching latest manga: $e');
    }
    return [];
  }

  /// Fetches details for a specific manga.
  Future<Map<String, dynamic>> fetchMangaDetail(String endpoint) async {
    final response = await Fetch.get('/manga/detail/$endpoint');
    if (response.statusCode == 200) {
      return Fetch.safeDecode(response);
    } else {
      throw Exception('Failed to fetch manga detail');
    }
  }

  /// Fetches images for a specific chapter.
  Future<List<dynamic>> fetchChapter(String endpoint) async {
    final response = await Fetch.get('/manga/chapter/$endpoint');
    if (response.statusCode == 200) {
      final data = Fetch.safeDecode(response);
      // Assuming structure { "image_list": [...] } or similar
      if (data is Map && data['image_list'] is List) {
        return data['image_list'];
      } else if (data is List) {
        return data;
      }
      return [];
    } else {
      throw Exception('Failed to fetch chapter images');
    }
  }

  /// Searches for manga.
  Future<List<dynamic>> searchManga(String query) async {
    final response = await Fetch.get('/manga/search/$query');
    if (response.statusCode == 200) {
      final data = Fetch.safeDecode(response);
      if (data is Map && data['manga_list'] is List) {
        return data['manga_list'];
      }
      return [];
    } else {
      throw Exception('Failed to search manga');
    }
  }

  /// Fetches list of manga genres.
  Future<List<dynamic>> fetchGenres() async {
    try {
      final response = await Fetch.get('/manga/genres');
      if (response.statusCode == 200) {
        final data = Fetch.safeDecode(response);
        if (data is Map && data['list_genre'] is List) {
          return data['list_genre'];
        } else if (data is List) {
          return data;
        }
      }
    } catch (e) {
      debugPrint('Error fetching manga genres: $e');
    }
    return [];
  }
}

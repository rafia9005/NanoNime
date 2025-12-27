import 'dart:convert';
import 'package:nanonime/utils/fetch.dart';

class MangaService {
  /// Fetches the list of popular manga from the API.
  /// [page] is the page number for pagination (default: 1).
  Future<List<dynamic>> fetchMangaList({int page = 1}) async {
    final response = await Fetch.get('/manga/popular/$page');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map && data['manga_list'] is List) {
        return data['manga_list'];
      } else {
        throw Exception('Unexpected response format: manga_list not found');
      }
    } else {
      throw Exception('Failed to fetch manga list: ${response.statusCode}');
    }
  }

  /// Fetches the list of latest manga updates.
  Future<List<dynamic>> fetchLatestManga({int page = 1}) async {
    // Assuming the endpoint for latest is /manga/latest/{page} matching the popular one
    final response = await Fetch.get('/manga/latest/$page');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Depending on the proxy, structure might vary. 
      // Assuming same structure as popular for now.
      if (data is Map && data['manga_list'] is List) {
        return data['manga_list'];
      } else if (data is List) {
         return data;
      } else {
         return []; // Fail silently or return empty
      }
    } else {
      throw Exception('Failed to fetch latest manga: ${response.statusCode}');
    }
  }
}

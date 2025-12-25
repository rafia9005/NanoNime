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
}

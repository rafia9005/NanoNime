import 'package:nanonime/data/models/manga.dart';
import 'package:nanonime/data/services/manga_service.dart';

class MangaRepository {
  final MangaService _mangaService;

  MangaRepository({MangaService? mangaService})
    : _mangaService = mangaService ?? MangaService();

  Future<List<Manga>> fetchMangaList({int page = 1}) async {
    try {
      final List<dynamic> data = await _mangaService.fetchMangaList(page: page);
      return data.map((json) => Manga.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}

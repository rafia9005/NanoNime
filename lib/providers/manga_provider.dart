import 'package:flutter/material.dart';
import 'package:nanonime/data/models/manga.dart';
import 'package:nanonime/data/repositories/manga_repository.dart';

enum MangaState { initial, loading, loaded, error }

class MangaProvider extends ChangeNotifier {
  final MangaRepository _repository;

  MangaState _state = MangaState.initial;
  List<Manga> _mangaList = [];
  String? _errorMessage;

  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  MangaProvider({MangaRepository? repository})
    : _repository = repository ?? MangaRepository();

  MangaState get state => _state;
  List<Manga> get mangaList => _mangaList;
  String? get errorMessage => _errorMessage;

  int get currentPage => _currentPage;
  bool get isLoading => _state == MangaState.loading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasError => _state == MangaState.error;
  bool get hasMore => _hasMore;

  Future<void> fetchMangaList({int page = 1}) async {
    _state = MangaState.loading;
    _errorMessage = null;
    _currentPage = page;
    _hasMore = true;
    notifyListeners();

    try {
      final mangas = await _repository.fetchMangaList(page: page);
      _mangaList = mangas;
      _state = MangaState.loaded;
      _hasMore = mangas.isNotEmpty;
    } catch (e) {
      _errorMessage = e.toString();
      _state = MangaState.error;
      _hasMore = false;
    }
    notifyListeners();
  }

  Future<void> fetchNextPage() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final mangas = await _repository.fetchMangaList(page: nextPage);
      if (mangas.isNotEmpty) {
        _mangaList.addAll(mangas);
        _currentPage = nextPage;
      }
      _hasMore = mangas.isNotEmpty;
    } catch (e) {
      _hasMore = false;
    }
    _isLoadingMore = false;
    notifyListeners();
  }
}

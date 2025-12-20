/// Anime Provider
///
/// This provider manages the state for anime-related data in the application.
/// It uses ChangeNotifier to notify listeners when data changes.
///
/// This is a placeholder/example implementation. You can use this with Provider,
/// or replace it with Riverpod, Bloc, or other state management solutions.
///
/// Usage with Provider package:
/// ```dart
/// ChangeNotifierProvider(
///   create: (_) => AnimeProvider(),
///   child: MyApp(),
/// )
/// ```

import 'package:flutter/foundation.dart';
import '../data/models/anime.dart';
import '../data/repositories/anime_repository.dart';
import '../data/services/anime_service.dart';

class AnimeProvider extends ChangeNotifier {
  final AnimeRepository _repository;

  // State variables
  List<Anime> _ongoingAnime = [];
  List<Anime> _searchResults = [];
  List<Anime> _favoriteAnime = [];
  AnimeDetail? _currentAnimeDetail;
  EpisodeDetail? _currentEpisodeDetail;

  // Loading states
  bool _isLoadingOngoing = false;
  bool _isLoadingDetail = false;
  bool _isLoadingEpisode = false;
  bool _isSearching = false;

  // Error states
  String? _error;
  String? _searchError;

  // Constructor
  AnimeProvider({AnimeRepository? repository})
    : _repository = repository ?? AnimeRepository(apiService: ApiService());

  // Getters
  List<Anime> get ongoingAnime => _ongoingAnime;
  List<Anime> get searchResults => _searchResults;
  List<Anime> get favoriteAnime => _favoriteAnime;
  AnimeDetail? get currentAnimeDetail => _currentAnimeDetail;
  EpisodeDetail? get currentEpisodeDetail => _currentEpisodeDetail;

  bool get isLoadingOngoing => _isLoadingOngoing;
  bool get isLoadingDetail => _isLoadingDetail;
  bool get isLoadingEpisode => _isLoadingEpisode;
  bool get isSearching => _isSearching;

  String? get error => _error;
  String? get searchError => _searchError;

  bool get hasError => _error != null;
  bool get hasSearchError => _searchError != null;

  /// Fetch ongoing anime list
  Future<void> fetchOngoingAnime({bool forceRefresh = false}) async {
    _isLoadingOngoing = true;
    _error = null;
    notifyListeners();

    try {
      final animeList = await _repository.getOngoingAnime(
        forceRefresh: forceRefresh,
      );
      _ongoingAnime = animeList;
      _error = null;
    } catch (e) {
      _error = 'Failed to load ongoing anime: ${e.toString()}';
      debugPrint(_error);
    } finally {
      _isLoadingOngoing = false;
      notifyListeners();
    }
  }

  /// Fetch anime detail by ID
  Future<void> fetchAnimeDetail(String id, {bool forceRefresh = false}) async {
    _isLoadingDetail = true;
    _error = null;
    notifyListeners();

    try {
      final detail = await _repository.getAnimeDetail(
        id,
        forceRefresh: forceRefresh,
      );
      _currentAnimeDetail = detail;
      _error = null;
    } catch (e) {
      _error = 'Failed to load anime detail: ${e.toString()}';
      _currentAnimeDetail = null;
      debugPrint(_error);
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  /// Fetch episode detail by ID
  Future<void> fetchEpisodeDetail(
    String episodeId, {
    bool forceRefresh = false,
  }) async {
    _isLoadingEpisode = true;
    _error = null;
    notifyListeners();

    try {
      final episodeDetail = await _repository.getEpisodeDetail(
        episodeId,
        forceRefresh: forceRefresh,
      );
      _currentEpisodeDetail = episodeDetail;
      _error = null;
    } catch (e) {
      _error = 'Failed to load episode: ${e.toString()}';
      _currentEpisodeDetail = null;
      debugPrint(_error);
    } finally {
      _isLoadingEpisode = false;
      notifyListeners();
    }
  }

  /// Search anime by query
  Future<void> searchAnime(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _searchError = null;
      notifyListeners();
      return;
    }

    _isSearching = true;
    _searchError = null;
    notifyListeners();

    try {
      final results = await _repository.searchAnime(query);
      _searchResults = results;
      _searchError = null;
    } catch (e) {
      _searchError = 'Search failed: ${e.toString()}';
      _searchResults = [];
      debugPrint(_searchError);
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Clear search results
  void clearSearchResults() {
    _searchResults = [];
    _searchError = null;
    notifyListeners();
  }

  /// Clear current anime detail
  void clearAnimeDetail() {
    _currentAnimeDetail = null;
    _error = null;
    notifyListeners();
  }

  /// Clear current episode detail
  void clearEpisodeDetail() {
    _currentEpisodeDetail = null;
    _error = null;
    notifyListeners();
  }

  /// Clear all errors
  void clearErrors() {
    _error = null;
    _searchError = null;
    notifyListeners();
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    await fetchOngoingAnime(forceRefresh: true);
  }

  // Future implementations for user features:

  /// Toggle favorite status of an anime
  Future<void> toggleFavorite(String animeId) async {
    // TODO: Implement toggle favorite
    // final isFav = await _repository.isFavorite(animeId);
    // if (isFav) {
    //   await _repository.removeFromFavorites(animeId);
    // } else {
    //   await _repository.addToFavorites(animeId);
    // }
    // await fetchFavorites();
    throw UnimplementedError('Favorites not yet implemented');
  }

  /// Fetch user's favorite anime
  Future<void> fetchFavorites() async {
    // TODO: Implement fetch favorites
    // try {
    //   _favoriteAnime = await _repository.getFavoriteAnime();
    //   notifyListeners();
    // } catch (e) {
    //   debugPrint('Failed to load favorites: $e');
    // }
    throw UnimplementedError('Favorites not yet implemented');
  }

  /// Check if an anime is favorited
  Future<bool> isFavorite(String animeId) async {
    // TODO: Implement favorite check
    // return await _repository.isFavorite(animeId);
    return false;
  }

  /// Add episode to watch history
  Future<void> markAsWatched({
    required String animeId,
    required String episodeId,
    required int watchedSeconds,
    required int totalSeconds,
  }) async {
    // TODO: Implement watch history tracking
    // await _repository.addToWatchHistory(
    //   animeId: animeId,
    //   episodeId: episodeId,
    //   watchedSeconds: watchedSeconds,
    //   totalSeconds: totalSeconds,
    // );
  }

  /// Get continue watching list
  Future<List<Map<String, dynamic>>> getContinueWatching() async {
    // TODO: Implement continue watching
    // return await _repository.getContinueWatching();
    return [];
  }

  /// Clear cache
  Future<void> clearCache() async {
    await _repository.clearCache();
    _ongoingAnime = [];
    _searchResults = [];
    _currentAnimeDetail = null;
    _currentEpisodeDetail = null;
    notifyListeners();
  }
}

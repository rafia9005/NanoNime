/// Anime Repository
///
/// This repository acts as a single source of truth for anime data.
/// It manages data from multiple sources (API, local cache, database)
/// and provides a clean API for the UI layer.
///
/// Benefits of using Repository pattern:
/// - Abstracts data sources from UI
/// - Enables easy caching implementation
/// - Simplifies testing with mock repositories
/// - Centralizes data logic

import 'package:nanonime/data/models/anime.dart';
import '../services/anime_service.dart';

class AnimeRepository {
  final ApiService _apiService;

  // Optional: Add cache or local database here
  // final CacheService _cacheService;
  // final DatabaseService _databaseService;

  AnimeRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  /// Fetch anime schedule
  Future<List<AnimeScheduleDay>> getSchedule() async {
    return await _apiService.fetchSchedule();
  }

  /// Fetch ongoing anime with optional caching
  Future<List<Anime>> getOngoingAnime({bool forceRefresh = false}) async {
    try {
      // TODO: Check cache first if not forcing refresh
      // if (!forceRefresh) {
      //   final cachedData = await _cacheService.getOngoingAnime();
      //   if (cachedData != null && cachedData.isNotEmpty) {
      //     return cachedData;
      //   }
      // }

      // Fetch from API
      final animeList = await _apiService.fetchOngoingAnime();

      // TODO: Save to cache
      // await _cacheService.saveOngoingAnime(animeList);

      return animeList;
    } catch (e) {
      // TODO: Return cached data on error as fallback
      // final cachedData = await _cacheService.getOngoingAnime();
      // if (cachedData != null && cachedData.isNotEmpty) {
      //   return cachedData;
      // }

      rethrow;
    }
  }

  /// Get anime detail by ID with caching
  Future<AnimeDetail> getAnimeDetail(
    String id, {
    bool forceRefresh = false,
  }) async {
    try {
      // TODO: Check cache first
      // if (!forceRefresh) {
      //   final cachedDetail = await _cacheService.getAnimeDetail(id);
      //   if (cachedDetail != null) {
      //     return cachedDetail;
      //   }
      // }

      // Fetch from API
      final detail = await _apiService.fetchAnimeDetail(id);

      // TODO: Save to cache
      // await _cacheService.saveAnimeDetail(id, detail);

      return detail;
    } catch (e) {
      // TODO: Return cached data on error
      // final cachedDetail = await _cacheService.getAnimeDetail(id);
      // if (cachedDetail != null) {
      //   return cachedDetail;
      // }

      rethrow;
    }
  }

  /// Get episode detail by ID
  Future<EpisodeDetail> getEpisodeDetail(
    String episodeId, {
    bool forceRefresh = false,
  }) async {
    try {
      // Episode details are usually fresh, but cache can be added
      final episodeDetail = await _apiService.fetchEpisodeDetail(episodeId);
      return episodeDetail;
    } catch (e) {
      rethrow;
    }
  }

  /// Resolve server URL for streaming
  Future<String?> resolveStreamingUrl(String serverId) async {
    try {
      final url = await _apiService.resolveServerUrl(serverId);
      return url;
    } catch (e) {
      // Return null on error, caller should handle fallback
      return null;
    }
  }

  /// Search anime with optional caching for recent searches
  Future<List<Anime>> searchAnime(
    String query, {
    bool saveToHistory = true,
  }) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }

      // TODO: Check if this exact query was searched recently
      // final cachedResults = await _cacheService.getSearchResults(query);
      // if (cachedResults != null) {
      //   return cachedResults;
      // }

      // Fetch from API
      final results = await _apiService.searchAnime(query);

      // TODO: Cache search results
      // await _cacheService.saveSearchResults(query, results);

      // TODO: Save to search history if enabled
      // if (saveToHistory) {
      //   await _databaseService.addSearchHistory(query);
      // }

      return results;
    } catch (e) {
      rethrow;
    }
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    // TODO: Implement cache clearing
    // await _cacheService.clearAll();
  }

  /// Get cache size for settings/debug
  Future<int> getCacheSize() async {
    // TODO: Implement cache size calculation
    // return await _cacheService.getSize();
    return 0;
  }

  // Future implementations for user-specific features:

  /// Get favorite anime list (requires authentication)
  Future<List<Anime>> getFavoriteAnime() async {
    // TODO: Implement favorites
    throw UnimplementedError('Favorites not yet implemented');
  }

  /// Add anime to favorites
  Future<void> addToFavorites(String animeId) async {
    // TODO: Implement add to favorites
    throw UnimplementedError('Favorites not yet implemented');
  }

  /// Remove anime from favorites
  Future<void> removeFromFavorites(String animeId) async {
    // TODO: Implement remove from favorites
    throw UnimplementedError('Favorites not yet implemented');
  }

  /// Check if anime is in favorites
  Future<bool> isFavorite(String animeId) async {
    // TODO: Implement favorite check
    // return await _databaseService.isFavorite(animeId);
    return false;
  }

  /// Get watch history
  Future<List<Map<String, dynamic>>> getWatchHistory() async {
    // TODO: Implement watch history
    throw UnimplementedError('Watch history not yet implemented');
  }

  /// Add episode to watch history
  Future<void> addToWatchHistory({
    required String animeId,
    required String episodeId,
    required int watchedSeconds,
    required int totalSeconds,
  }) async {
    // TODO: Implement watch history tracking
    // await _databaseService.addWatchHistory(
    //   animeId: animeId,
    //   episodeId: episodeId,
    //   watchedSeconds: watchedSeconds,
    //   totalSeconds: totalSeconds,
    //   timestamp: DateTime.now(),
    // );
  }

  /// Get last watched episode for an anime
  Future<String?> getLastWatchedEpisode(String animeId) async {
    // TODO: Implement last watched lookup
    // return await _databaseService.getLastWatchedEpisode(animeId);
    return null;
  }

  /// Get continue watching list
  Future<List<Map<String, dynamic>>> getContinueWatching() async {
    // TODO: Implement continue watching
    // Returns list of anime with last watched episode and progress
    throw UnimplementedError('Continue watching not yet implemented');
  }
}
